import 'dart:io';

import 'package:english_research_data_collecting_app/globals.dart';
import 'package:english_research_data_collecting_app/screen/clarity_chart.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ClarityListView extends StatefulWidget {
  const ClarityListView({Key? key}) : super(key: key);

  @override
  State<ClarityListView> createState() => _ClarityListViewState();
}

class _ClarityListViewState extends State<ClarityListView> {
  var searchController = TextEditingController();
  List<String> _clarityRecordList = [];
  List<String> _foundClarityRecord = [];
  Directory externalDirPath = Directory('');
  static const String CLARITY_FOLDER_NAME = 'Clarity';

  @override
  void initState() {
    super.initState();
    requestWritePermission();
    initClarityList();
  }

  Future<void> initClarityList() async {
    final directory = await getExternalStorageDirectory();
    final clarityFolderDir =
        Directory("${directory!.path}/$CLARITY_FOLDER_NAME");
    updateClarityRecordList(clarityFolderDir.listSync());
    externalDirPath = clarityFolderDir;
  }

  void _runFilter(String enteredKeyword) {
    List<String> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = _clarityRecordList;
    } else {
      results = _clarityRecordList
          .where((audio) =>
              audio.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI
    setState(() {
      _foundClarityRecord = results;
    });
  }

  // Update clarityRecordList
  void updateClarityRecordList(List<FileSystemEntity> recordList) {
    _clarityRecordList.clear();
    for (var i = 0; i < recordList.length; i++) {
      var temp = recordList[i].toString();
      temp = basenameWithoutExtension(temp);
      _clarityRecordList.add(temp);
      _clarityRecordList.sort();
      print('Print list: ' + temp);
      setState(() {
        _foundClarityRecord = _clarityRecordList;
      });
    }
  }

  // Request permission for file accessing and writing
  requestWritePermission() async {
    await Permission.storage.request();
    // await Permission.manageExternalStorage.request();
    if (await Permission.storage.request().isGranted) {
      print('External manage agreed!!!!!!!');
    } else {
      print('External manage denied.');
    }
  }

  Directory pathToPassNextScreen = Directory('');

  @override
  Widget build(BuildContext context) {
    // updateClarityRecordList(externalDirPath.listSync());
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(children: [
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
            child: _foundClarityRecord.isNotEmpty
                ? ListView.builder(
                    itemCount: _foundClarityRecord.length,
                    itemBuilder: (context, index) => Dismissible(
                      direction: GlobalVar.isEditorMode
                          ? DismissDirection.endToStart
                          : DismissDirection.none,
                      key: UniqueKey(),
                      onDismissed: (direction) {
                        setState(() {
                          deleteCertainClarity(_foundClarityRecord[index]);
                          searchAndDelete(_foundClarityRecord[index]);
                          _runFilter(searchController.text);
                          print('_foundAudios : ' +
                              _foundClarityRecord.toString());
                          print(
                              '_audioList : ' + _clarityRecordList.toString());
                        });
                      },
                      child: Card(
                        key: ValueKey(_foundClarityRecord[index]),
                        color: Colors.blueAccent[100],
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          trailing: Visibility(
                              visible: GlobalVar.isEditorMode,
                              child: const Icon(Icons.arrow_back)),
                          title: Center(
                            child: Text(_foundClarityRecord[index]),
                          ),
                          onTap: () {
                            setFilePathForPassing(_foundClarityRecord[index]);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ClarityChart(
                                          clarityFileName:
                                              _foundClarityRecord[index],
                                          clarityFilePath: pathToPassNextScreen,
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
              onPressed: () async {
                _showAlertDialog(context);
              },
              child: const Text('Delete all clarity records'),
              style: OutlinedButton.styleFrom(
                shape: const StadiumBorder(),
                side: const BorderSide(width: 2, color: Colors.red),
              ),
            ),
          )
        ]),
      ),
    );
  }

  void setFilePathForPassing(String foundClarity) async {
    final externalStorage = await getExternalStorageDirectory();
    final clarityFolder =
        Directory("${externalStorage!.path}/$CLARITY_FOLDER_NAME");
    var clarityList = clarityFolder.listSync();
    String filePath = '';
    for (var i = 0; i < clarityList.length; i++) {
      var temp = clarityList[i].toString();
      temp = basenameWithoutExtension(temp);
      if (temp == foundClarity) {
        filePath = clarityList[i].path;
        break;
      }
    }
    pathToPassNextScreen = Directory(filePath);
  }

  Future<int> deleteAllClarityRecords() async {
    final externalStorage = await getExternalStorageDirectory();
    final clarityFolder =
        Directory("${externalStorage!.path}/$CLARITY_FOLDER_NAME");
    if (await clarityFolder.exists()) {
      clarityFolder.deleteSync(recursive: true);
      setState(() {
        _clarityRecordList.clear();
        _foundClarityRecord = _clarityRecordList;
      });
    }
    return 0;
  }

  // Delete certain clarity
  Future<int> deleteCertainClarity(String fileName) async {
    final externalStorage = await getExternalStorageDirectory();
    final clarityFolder =
        Directory("${externalStorage!.path}/$CLARITY_FOLDER_NAME");
    try {
      final file = await findFileWithExtension(fileName);
      await file.delete();
      print(clarityFolder.listSync());
    } catch (e) {
      print(e);
    }
    return 0;
  }

  // Find file with extension
  Future<File> findFileWithExtension(String fileName) async {
    final externalStorage = await getExternalStorageDirectory();
    final clarityFolder =
        Directory("${externalStorage!.path}/$CLARITY_FOLDER_NAME");
    var clarityRecordList = clarityFolder.listSync();
    String fileNameWithExt = '';
    for (var i = 0; i < clarityRecordList.length; i++) {
      var temp = clarityRecordList[i].toString();
      temp = basenameWithoutExtension(temp);
      if (temp == fileName) {
        temp = clarityRecordList[i].toString();
        fileNameWithExt = basename(temp);
        //Remove last char
        if (fileNameWithExt.isNotEmpty) {
          fileNameWithExt =
              fileNameWithExt.substring(0, fileNameWithExt.length - 1);
        }
        break;
      }
    }
    return File('${clarityFolder.path}/$fileNameWithExt');
  }

  void searchAndDelete(String deleteItem) {
    for (var i = 0; i < _clarityRecordList.length; i++) {
      if (_clarityRecordList[i] == deleteItem) {
        _clarityRecordList.removeAt(i);
      }
    }
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
        deleteAllClarityRecords();
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
