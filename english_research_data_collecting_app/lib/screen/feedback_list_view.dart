import 'dart:io';

import 'package:english_research_data_collecting_app/globals.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'feedback_text_display.dart';

class FeedbackListView extends StatefulWidget {
  const FeedbackListView({Key? key}) : super(key: key);

  @override
  State<FeedbackListView> createState() => _FeedbackListViewState();
}

class _FeedbackListViewState extends State<FeedbackListView> {
  var searchController = TextEditingController();
  List<String> _feedbackRecordList = [];
  List<String> _foundFeedbackRecord = [];
  Directory externalDirPath = Directory('');
  static const String FEEDBACK_FOLDER_NAME = 'Feedback';

  @override
  void initState() {
    super.initState();
    requestWritePermission();
    initFeedbackList();
  }

  Future<void> initFeedbackList() async {
    final directory = await getExternalStorageDirectory();
    final feedbackFolderDir =
        Directory("${directory!.path}/$FEEDBACK_FOLDER_NAME");
    updateFeedbackRecordList(feedbackFolderDir.listSync());
    externalDirPath = feedbackFolderDir;
  }

  void _runFilter(String enteredKeyword) {
    List<String> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = _feedbackRecordList;
    } else {
      results = _feedbackRecordList
          .where((audio) =>
              audio.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI
    setState(() {
      _foundFeedbackRecord = results;
    });
  }

  // Update FeedbackRecordList
  void updateFeedbackRecordList(List<FileSystemEntity> recordList) {
    _feedbackRecordList.clear();
    for (var i = 0; i < recordList.length; i++) {
      var temp = recordList[i].toString();
      temp = basenameWithoutExtension(temp);
      _feedbackRecordList.add(temp);
      _feedbackRecordList.sort();
      print('Print list: ' + temp);
      setState(() {
        _foundFeedbackRecord = _feedbackRecordList;
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
            child: _foundFeedbackRecord.isNotEmpty
                ? ListView.builder(
                    itemCount: _foundFeedbackRecord.length,
                    itemBuilder: (context, index) => Dismissible(
                      direction: GlobalVar.isEditorMode
                          ? DismissDirection.endToStart
                          : DismissDirection.none,
                      key: UniqueKey(),
                      onDismissed: (direction) {
                        setState(() {
                          deleteCertainFeedback(_foundFeedbackRecord[index]);
                          searchAndDelete(_foundFeedbackRecord[index]);
                          _runFilter(searchController.text);
                        });
                      },
                      child: Card(
                        key: ValueKey(_foundFeedbackRecord[index]),
                        color: Colors.greenAccent[100],
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          trailing: Visibility(
                              visible: GlobalVar.isEditorMode,
                              child: const Icon(Icons.arrow_back)),
                          title: Center(
                            child: Text(_foundFeedbackRecord[index]),
                          ),
                          onTap: () {
                            setFilePathForPassing(_foundFeedbackRecord[index]);
                            //TODO: push to text reader
                            //FIXME:
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FeedbackTextDisplay(
                                          feedbackFileName:
                                              _foundFeedbackRecord[index],
                                          feedbackFilePath:
                                              pathToPassNextScreen,
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
              child: const Text('Delete all feedback records'),
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
    final feedbackFolder =
        Directory("${externalStorage!.path}/$FEEDBACK_FOLDER_NAME");
    var feedbackList = feedbackFolder.listSync();
    String filePath = '';
    for (var i = 0; i < feedbackList.length; i++) {
      var temp = feedbackList[i].toString();
      temp = basenameWithoutExtension(temp);
      if (temp == foundClarity) {
        filePath = feedbackList[i].path;
        break;
      }
    }
    pathToPassNextScreen = Directory(filePath);
  }

  Future<int> deleteAllFeedbackRecords() async {
    final externalStorage = await getExternalStorageDirectory();
    final feedbackFolder =
        Directory("${externalStorage!.path}/$FEEDBACK_FOLDER_NAME");
    if (await feedbackFolder.exists()) {
      feedbackFolder.deleteSync(recursive: true);
      setState(() {
        _feedbackRecordList.clear();
        _foundFeedbackRecord = _feedbackRecordList;
      });
    }
    return 0;
  }

  // Delete certain audio
  Future<int> deleteCertainFeedback(String fileName) async {
    final externalStorage = await getExternalStorageDirectory();
    final feedbackFolder =
        Directory("${externalStorage!.path}/$FEEDBACK_FOLDER_NAME");
    try {
      final file = await findFileWithExtension(fileName);
      await file.delete();
      print(feedbackFolder.listSync());
    } catch (e) {
      print(e);
    }
    return 0;
  }

  // Find file with extension
  Future<File> findFileWithExtension(String fileName) async {
    final externalStorage = await getExternalStorageDirectory();
    final feedbackFolder =
        Directory("${externalStorage!.path}/$FEEDBACK_FOLDER_NAME");
    var feedbackRecordList = feedbackFolder.listSync();
    String fileNameWithExt = '';
    for (var i = 0; i < feedbackRecordList.length; i++) {
      var temp = feedbackRecordList[i].toString();
      temp = basenameWithoutExtension(temp);
      if (temp == fileName) {
        temp = feedbackRecordList[i].toString();
        fileNameWithExt = basename(temp);
        //Remove last char
        if (fileNameWithExt.isNotEmpty) {
          fileNameWithExt =
              fileNameWithExt.substring(0, fileNameWithExt.length - 1);
        }
        break;
      }
    }
    return File('${feedbackFolder.path}/$fileNameWithExt');
  }

  void searchAndDelete(String deleteItem) {
    for (var i = 0; i < _feedbackRecordList.length; i++) {
      if (_feedbackRecordList[i] == deleteItem) {
        _feedbackRecordList.removeAt(i);
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
        deleteAllFeedbackRecords();
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
