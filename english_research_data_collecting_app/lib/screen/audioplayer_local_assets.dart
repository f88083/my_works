import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:english_research_data_collecting_app/appUtil/create_folder.dart';
import 'package:english_research_data_collecting_app/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioPlayerWithLocalAsset extends StatefulWidget {
  final String audioName;
  final Directory audioPath;
  const AudioPlayerWithLocalAsset(
      {Key? key, required this.audioName, required this.audioPath})
      : super(key: key);

  @override
  _AudioPlayerWithLocalAssetState createState() =>
      _AudioPlayerWithLocalAssetState();
}

class _AudioPlayerWithLocalAssetState extends State<AudioPlayerWithLocalAsset> {
  AudioPlayer audioPlayer = AudioPlayer();
  PlayerState playerState = PlayerState.PAUSED;
  int timeProgress = 0;
  int audioDuration = 0;
  int clarity = 0;
  final textController = TextEditingController();
  List<String> clarityAndTimestamp = [];
  FileManager fileManager = FileManager();
  static const String CLARITY_FOLDER_NAME = 'Clarity';
  static const String FEEDBACK_FOLDER_NAME = 'Feedback';
  int notificationIndicator = 0;
  String externalStoragePath = '';

  bool isListeningMode = false;

  DateTime now = DateTime.now();
  bool fileDateUpdate = false;

  /*
  maxValue = maxValue >0?maxValue:0;
progress = maxValue>progress?progress:maxValue;

max value and progress always set positive and progress always <= max value

Slider(
max:maxValue,
value: progress,
onChanged: onSeek,
)
  */

  // Slider of clarity
  Widget slider(double screenWidth) {
    return Container(
      width: screenWidth * 0.7,
      child: Slider.adaptive(
          value: ((audioDuration / 1000).floorToDouble()) >
                  (timeProgress / 1000).floorToDouble()
              ? (timeProgress / 1000).floorToDouble()
              : ((audioDuration / 1000).floorToDouble()),
          // min: 0.0,
          max: ((audioDuration / 1000).floorToDouble()),
          onChanged: (value) {
            if (playerState == PlayerState.PLAYING) {
              seekToSec(value.toInt());
            }
          }),
    );
  }

  int lastTime =
      0; // last time stamp (in order to prevent continuously writing file)
  int previousMillisecFloored =
      -1; // last millisecond (prevent duplicate values)
  void audioPositionChangeWriteFile() {
    if (!isListeningMode) {
      // Not in listening mode
      audioPlayer.onAudioPositionChanged.listen((Duration p) {
        timeProgress = p.inMilliseconds;
        // Write file every 5 secs and time duration over 1 sec
        if (timeProgress > 1000 &&
            (timeProgress / 1000).floor() % 5 == 0 &&
            lastTime != (timeProgress / 1000).floor()) {
          fileManager.saveFromListToFile(
              clarityAndTimestamp, widget.audioName, CLARITY_FOLDER_NAME, now);
          lastTime = (timeProgress / 1000).floor();
          // print('timeProgress: ' + timeProgress.toString());
          // print('/1000.floor: ' + (timeProgress / 1000).floor().toString());
          // print('(timeProgress / 1000).floor() % 5 = ' +
          //     ((timeProgress / 1000).floor() % 5).toString());
          // print('EXECUTED');
        }
        String currentTimeString = getTimeStringForCollect(timeProgress);
        // Only store when last floored millisec is different from previous one
        // Otherwise there will be lots of duplicate values
        if (previousMillisecFloored !=
            int.parse(
                (currentTimeString.substring(currentTimeString.length - 1)))) {
          setState(() {
            clarityAndTimestamp.add('$currentTimeString, $clarity\n');
          });
          print('ADDDDDDDDDDDDDEDDDDDDDDDDDDDDD');
          previousMillisecFloored = int.parse(
              (currentTimeString.substring(currentTimeString.length - 1)));
        }
        // print(clarityAndTimestamp);
      });
    } else {
      audioPlayer.onAudioPositionChanged.listen((Duration p) {
        setState(() {
          timeProgress = p.inMilliseconds;
        });
      });
    }
  }

  // Create folder in external storage
  _callFolderCreationInExternalWithFolderName(String folderName) async {
    await AppUtil.createFolderInExternalDocDir(folderName);
  }

  @override
  void initState() {
    super.initState();
    requestWritePermission();
    initExternalStoragePath();
    _callFolderCreationInExternalWithFolderName(FEEDBACK_FOLDER_NAME);
    audioPlayer.onPlayerStateChanged.listen((PlayerState s) {
      if (mounted) {
        setState(() {
          playerState = s;
        });
      }
    });

    audioPlayer.onAudioPositionChanged.listen((event) {
      audioPositionChangeWriteFile();
    });

    // Events are sent every time an audio is finished
    audioPlayer.onPlayerCompletion.listen((event) {
      completeMusic();
      print('wrote file after compeletion');
    });
  }

  // Initialize external storage path
  void initExternalStoragePath() async {
    final directory = await getExternalStorageDirectory();
    externalStoragePath = directory!.path;
  }

  // Request permission for file accessing and writing
  requestWritePermission() async {
    await Permission.storage.request();
    // await Permission.manageExternalStorage.request();
    if (await Permission.storage.request().isGranted) {
      print('External manage agreed.');
    } else {
      print('External manage denied.');
    }
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.release();
    audioPlayer.dispose();
  }

  playMusic() async {
    if (await Permission.storage.request().isGranted) {
      int result = await audioPlayer.play(widget.audioPath.path, isLocal: true);
      // First time play the audio and not in listening mode
      if (fileDateUpdate && !isListeningMode) {
        now = DateTime.now();
        fileDateUpdate = false;
      }
    } else {
      await Permission.storage.request();
    }
  }

  pauseMusic() async {
    int result = await audioPlayer.pause();
    // When pause and not in listening mode, write record to the file again
    if (!isListeningMode) {
      fileManager.saveFromListToFile(
          clarityAndTimestamp, widget.audioName, CLARITY_FOLDER_NAME, now);
      print('wrote file after pasued aduio');
    }
  }

  stopMusic() async {
    setState(() {
      clarityAndTimestamp.clear();
    });
    print('Cleared record after stopped audio');
    await audioPlayer.stop();
    fileDateUpdate = true; // Date ready for updating
  }

  completeMusic() async {
    if (!isListeningMode) {
      fileManager.saveFromListToFile(
          clarityAndTimestamp, widget.audioName, CLARITY_FOLDER_NAME, now);
      fileDateUpdate = true; // Date ready for updating
      _showAlertDialog(context, 'Audio playing complete!',
          "Record has been saved to '$externalStoragePath' successfully.");
      await audioPlayer.stop();
      setState(() {
        clarityAndTimestamp.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth =
        MediaQuery.of(context).size.width; // calculate the screen size
    // For keyboard dismission
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      // Keep widget in safe area of the screen, prevent overflow
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: SingleChildScrollView(
            child: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.audioName,
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(getTimeString(timeProgress)),
                      slider(screenWidth),
                      audioDuration == 0
                          ? getFileAudioDuration()
                          : Text(getTimeString(audioDuration)),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (playerState == PlayerState.PLAYING) {
                            pauseMusic();
                            if (!isListeningMode) {
                              _showAlertDialog(context, 'Audio paused!',
                                  "Record has been saved to '$externalStoragePath' successfully.");
                            }
                          } else {
                            playMusic();
                          }
                        },
                        icon: Icon(playerState == PlayerState.PLAYING
                            ? Icons.pause_circle_outlined
                            : Icons.play_circle_outlined),
                        iconSize: 60,
                      ),
                      IconButton(
                        onPressed: () {
                          stopMusic();
                          if (!isListeningMode) {
                            _showAlertDialog(context, 'Audio stopped!',
                                'Record cache is empty now');
                          }
                        },
                        icon: const Icon(Icons.stop_circle_outlined),
                        iconSize: 60,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text(
                    'Clarity',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      claritySlider(screenWidth),
                    ],
                  ),
                  Wrap(
                      spacing: screenWidth * 0.8,
                      direction: Axis.horizontal,
                      children: const [
                        Text('Low'),
                        Text('High'),
                      ]),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Listening Mode'),
                      Switch(
                          value: isListeningMode,
                          onChanged: (value) {
                            setState(() {
                              isListeningMode = value;
                              if (isListeningMode == false) {
                                stopMusic();
                                _showAlertDialog(context, 'Listening Mode off!',
                                    'Audio stopped!');
                              } else {
                                _showAlertDialog(context, 'Listening Mode on!',
                                    'No clarity data will be recorded');
                              }
                              print('Listening mode now is : ' +
                                  isListeningMode.toString());
                            });
                          }),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text('Feedback',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  feedbackTextField(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _showAlertDialog(BuildContext context, String infoTitle, String infoDetail) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(infoTitle),
      content: Text(infoDetail),
      actions: [
        okButton,
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

  // Yes or no dialog for submission
  _showSubmitConfirmDialog(
      BuildContext context, String infoTitle, String infoDetail) {
    // set up the button
    Widget yesButton = TextButton(
      child: const Text("Yes"),
      onPressed: () {
        setState(() {
          fileManager.saveFeedbackText(
              textController.text, widget.audioName, FEEDBACK_FOLDER_NAME);
        });

        Navigator.pop(context);
        _showAlertDialog(
            context, 'Feedback submitted', 'Feedback saved successfully!');
      },
    );

    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(infoTitle),
      content: Text(infoDetail),
      actions: [yesButton, cancelButton],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget feedbackTextField() {
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: 'Please write your feedback here',
                border: const OutlineInputBorder(),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                suffixIcon: IconButton(
                  onPressed: () {
                    textController.clear();
                  },
                  icon: const Icon(Icons.clear),
                ),
              ),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              onChanged: (value) {
                pauseMusic();
              },
            ),
            const SizedBox(
              height: 10,
            ),
            TextButton(
              onPressed: () {
                _showSubmitConfirmDialog(context, 'Confirmation!',
                    'Are you sure to submit the feedback? (You can submit a new feedback after submission.)');
              },
              child: const Text('Submit'),
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Colors.blue,
                onSurface: Colors.grey,
                elevation: 5,
              ),
            )
          ],
        ));
  }

  // Slider for clarity recording
  Widget claritySlider(double screenWidth) {
    return Container(
      width: screenWidth * 0.98,
      child: Slider.adaptive(
        value: clarity.floorToDouble(),
        min: 0,
        max: 100,
        onChanged: (newClarity) {
          setState(() {
            clarity = newClarity.toInt();
          });
        },
      ),
    );
  }

  // Get audio duration
  Widget getFileAudioDuration() {
    return FutureBuilder(
        future: _getAudioDuration(),
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Text(getTimeString(snapshot.data!));
          }
          return const Text('');
        });
  }

  Future<int> _getAudioDuration() async {
    await audioPlayer.setUrl(widget.audioPath.path);
    audioDuration = await Future.delayed(
        const Duration(seconds: 1), () => audioPlayer.getDuration());
    return audioDuration;
  }

  String getTimeString(int milliseconds) {
    if (milliseconds == null) {
      milliseconds = 0;
    }
    String hours =
        '${(milliseconds / 3600000).floor() < 10 ? 0 : ''}${(milliseconds / 3600000).floor()}';
    String minutes =
        '${(milliseconds / 60000).floor() < 10 ? 0 : ''}${(milliseconds / 60000).floor()}';
    String seconds =
        '${(milliseconds / 1000).floor() % 60 < 10 ? 0 : ''}${(milliseconds / 1000).floor() % 60}';
    return '$hours:$minutes:$seconds';
  }

  String getTimeStringForCollect(int milliseconds) {
    if (milliseconds == null) {
      milliseconds = 0;
    }
    String hours =
        '${(milliseconds / 3600000).floor() < 10 ? 0 : ''}${(milliseconds / 3600000).floor()}';
    String minutes =
        '${(milliseconds / 60000).floor() < 10 ? 0 : ''}${(milliseconds / 60000).floor()}';
    String seconds =
        '${(milliseconds / 1000).floor() % 60 < 10 ? 0 : ''}${(milliseconds / 1000).floor() % 60}';
    String oneTenSeconds = '${(milliseconds / 100).floor() % 10}';
    return '$hours:$minutes:$seconds.$oneTenSeconds';
  }

  void seekToSec(int sec) {
    Duration newPosition = Duration(seconds: sec);
    audioPlayer.seek(newPosition);
  }
}
