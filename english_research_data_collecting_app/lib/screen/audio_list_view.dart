import 'dart:io';

import 'package:english_research_data_collecting_app/appUtil/create_folder.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import 'audioplayer_local_assets.dart';
import 'package:english_research_data_collecting_app/globals.dart';

//import 'package:flutter_file_manager/flutter_file_manager.dart';
//import 'package:path_provider_ex/path_provider_ex.dart';

class AudioList extends StatefulWidget {
  const AudioList({Key? key}) : super(key: key);

  @override
  State<AudioList> createState() => _AudioListState();
}

const String USER_AUDIO_FOLDER_NAME = 'audios';
List<String> _audioList = [];
List<String> _foundAudios = [];
const String CLARITY_FOLDER_NAME = 'Clarity';

class _AudioListState extends State<AudioList> {
  @override
  void initState() {
    super.initState();
    _callFolderCreationMethod();
    initAudioList();
    _callFolderCreationInExternalWithFolderName(CLARITY_FOLDER_NAME);
  }

  Future<void> initAudioList() async {
    final appStorage = await getApplicationDocumentsDirectory();
    final audioFolder = Directory("${appStorage.path}/$USER_AUDIO_FOLDER_NAME");
    updateAudioList(audioFolder.listSync());
  }

  // Update audioList
  void updateAudioList(List<FileSystemEntity> audioList) {
    _audioList.clear();
    for (var i = 0; i < audioList.length; i++) {
      var temp = audioList[i].toString();
      temp = basenameWithoutExtension(temp);
      _audioList.add(temp);
      _audioList.sort();
      print('Print list: ' + temp);
      setState(() {
        _foundAudios = _audioList;
      });
    }
    print('Editor Mode at home is: ${GlobalVar.isEditorMode}');
  }

  // Whenever the text field changes
  void _runFilter(String enteredKeyword) {
    List<String> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, display all users
      results = _audioList;
    } else {
      results = _audioList
          .where((audio) =>
              audio.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
      // make it case-insensitive
    }

    // Refresh the UI
    setState(() {
      _foundAudios = results;
    });
  }

  // Remove deleted item from list
  void searchAndDelete(String deleteItem) {
    for (var i = 0; i < _audioList.length; i++) {
      if (_audioList[i] == deleteItem) {
        _audioList.removeAt(i);
      }
    }
  }

  var searchController = TextEditingController();
  Directory pathToPassNextScreen = Directory('');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              const SizedBox(
                height: 5,
              ),
              TextField(
                controller: searchController,
                onChanged: (value) => _runFilter(value),
                decoration: const InputDecoration(
                    labelText: 'Search', suffixIcon: Icon(Icons.search)),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: _foundAudios.isNotEmpty
                    ? ListView.builder(
                        itemCount: _foundAudios.length,
                        itemBuilder: (context, index) => Dismissible(
                          key: UniqueKey(),
                          direction: GlobalVar.isEditorMode
                              ? DismissDirection.endToStart
                              : DismissDirection.none,
                          onDismissed: (direction) {
                            setState(() {
                              deleteCertainAudio(_foundAudios[index]);
                              searchAndDelete(_foundAudios[index]);
                              _runFilter(searchController.text);
                              print(
                                  '_foundAudios : ' + _foundAudios.toString());
                              print('_audioList : ' + _audioList.toString());
                            });
                          },
                          child: Card(
                            key: ValueKey(_foundAudios[index]),
                            color: Colors.amberAccent,
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: ListTile(
                              trailing: Visibility(
                                  visible: GlobalVar.isEditorMode,
                                  child: const Icon(Icons.arrow_back)),
                              title: Center(
                                child: Text(_foundAudios[index]),
                              ),
                              onTap: () {
                                setFilePathForPassing(_foundAudios[index]);
                                // Pass information to next screen
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AudioPlayerWithLocalAsset(
                                              audioName: _foundAudios[index],
                                              audioPath: pathToPassNextScreen,
                                            )));
                              },
                            ),
                          ),
                          // This will show up when the user performs dismissal action
                          // It is a red background with a trash icon
                          background: Container(
                            color: Colors.red,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.centerRight,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    : const Text(
                        'No results found',
                        style: TextStyle(fontSize: 24),
                      ),
              ),
              Visibility(
                visible: GlobalVar.isEditorMode,
                child: OutlinedButton(
                  // Button for testing
                  onPressed: () async {
                    _showAlertDialog(context);
                  },
                  child: const Text('Delete All Audios'),
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                    side: const BorderSide(width: 2, color: Colors.red),
                  ),
                ),
              )
            ],
          ),
        ),
        floatingActionButton: Visibility(
          visible: GlobalVar.isEditorMode,
          child: FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Add File'),
              onPressed: () async {
                final result = await FilePicker.platform
                    .pickFiles(allowMultiple: true, type: FileType.audio);
                if (result == null) return;

                Directory audioFolder = Directory('');
                for (var i = 0; i < result.count; i++) {
                  // Open a file
                  final file = result.files[i];
                  print('Name: ${file.name}');
                  // Save file permanently in app storage
                  final newFile = await saveFilePermanently(file);
                  final appStorage = await getApplicationDocumentsDirectory();
                  audioFolder =
                      Directory("${appStorage.path}/$USER_AUDIO_FOLDER_NAME");
                  print(audioFolder.listSync());
                }

                // Update audio list
                setState(() {
                  updateAudioList(audioFolder.listSync());
                  _foundAudios = _audioList;
                  searchController.clear();
                });
              }),
        ));
  }

  Future<File> saveFilePermanently(PlatformFile file) async {
    final appStorage = await getApplicationDocumentsDirectory();
    final newFile =
        File('${appStorage.path}/$USER_AUDIO_FOLDER_NAME/${file.name}');
    await _callFolderCreationMethod();
    // Copy cache into storage location
    return File(file.path!).copy(newFile.path);
  }

  // Delete the entire directory of audios
  Future<int> deleteAllFiles() async {
    final appStorage = await getApplicationDocumentsDirectory();
    final audioFolder = Directory("${appStorage.path}/$USER_AUDIO_FOLDER_NAME");
    if (await audioFolder.exists()) {
      audioFolder.deleteSync(recursive: true);
      setState(() {
        _audioList.clear();
        _foundAudios = _audioList;
      });
    }
    print('Files Deleted');
    return 0;
  }

  // Delete certain audio
  Future<int> deleteCertainAudio(String fileName) async {
    final appStorage = await getApplicationDocumentsDirectory();
    final audioFolder = Directory("${appStorage.path}/$USER_AUDIO_FOLDER_NAME");
    try {
      final file = await findFileWithExtension(fileName);
      await file.delete();
      print(audioFolder.listSync());
    } catch (e) {
      print(e);
    }
    return 0;
  }

  // Find file with extension
  Future<File> findFileWithExtension(String fileName) async {
    final appStorage = await getApplicationDocumentsDirectory();
    final audioFolder = Directory("${appStorage.path}/$USER_AUDIO_FOLDER_NAME");
    var audioList = audioFolder.listSync();
    String fileNameWithExt = '';
    for (var i = 0; i < audioList.length; i++) {
      var temp = audioList[i].toString();
      temp = basenameWithoutExtension(temp);
      if (temp == fileName) {
        temp = audioList[i].toString();
        fileNameWithExt = basename(temp);
        //Remove last char
        if (fileNameWithExt.isNotEmpty) {
          fileNameWithExt =
              fileNameWithExt.substring(0, fileNameWithExt.length - 1);
        }
        break;
      }
    }
    return File('${audioFolder.path}/$fileNameWithExt');
  }

  // Set file path for passing
  void setFilePathForPassing(String fileName) async {
    final appStorage = await getApplicationDocumentsDirectory();
    final audioFolder = Directory("${appStorage.path}/$USER_AUDIO_FOLDER_NAME");
    var audioList = audioFolder.listSync();
    String filePath = '';
    for (var i = 0; i < audioList.length; i++) {
      var temp = audioList[i].toString();
      temp = basenameWithoutExtension(temp);
      if (temp == fileName) {
        filePath = audioList[i].path;
        break;
      }
    }
    pathToPassNextScreen = Directory(filePath);
  }

  // Create folder
  _callFolderCreationMethod() async {
    String folderInAppDocDir =
        await AppUtil.createFolderInAppDocDir('$USER_AUDIO_FOLDER_NAME');
  }

  // Create folder in external storage
  _callFolderCreationInExternalWithFolderName(String folderName) async {
    await AppUtil.createFolderInExternalDocDir(folderName);
  }

  _showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Yes, I'm sure"),
      onPressed: () {
        deleteAllFiles();
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Warning"),
      content: const Text("Are you sure to delete all the files?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
