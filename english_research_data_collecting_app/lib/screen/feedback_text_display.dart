import 'dart:io';

import 'package:flutter/material.dart';

class FeedbackTextDisplay extends StatefulWidget {
  final String feedbackFileName;
  final Directory feedbackFilePath;
  const FeedbackTextDisplay(
      {Key? key,
      required this.feedbackFileName,
      required this.feedbackFilePath})
      : super(key: key);

  @override
  State<FeedbackTextDisplay> createState() => _FeedbackTextDisplayState();
}

class _FeedbackTextDisplayState extends State<FeedbackTextDisplay> {
  String feedbackContent = '';
  double textFontSize = 15.0;

  @override
  void initState() {
    super.initState();
    readFeedbackFromTxt();
  }

  void readFeedbackFromTxt() async {
    File feedbackFile = File(widget.feedbackFilePath.path);
    setState(() {
      feedbackContent = feedbackFile.readAsStringSync();
    });

    print('$feedbackContent');
  }

  Widget slider(double screenWidth) {
    return SizedBox(
      width: screenWidth * 0.9,
      child: Slider.adaptive(
          value: textFontSize,
          min: 5,
          max: 100,
          label: textFontSize.round().toString(),
          divisions: 95,
          onChanged: (value) {
            setState(() {
              textFontSize = value;
            });
            print(textFontSize);
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(widget.feedbackFileName),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [
              Center(
                child: Text(
                  widget.feedbackFileName,
                  style: const TextStyle(fontSize: 30),
                ),
              ),
              slider(screenWidth),
              Container(
                  decoration: const BoxDecoration(
                      border: Border(
                    top: BorderSide(width: 3.0, color: Colors.blue),
                    left: BorderSide(width: 3.0, color: Colors.blue),
                    right: BorderSide(width: 3.0, color: Colors.blue),
                    bottom: BorderSide(width: 3.0, color: Colors.blue),
                  )),
                  padding: const EdgeInsets.all(3.0),
                  alignment: Alignment.topLeft,
                  child: Text(
                    feedbackContent,
                    style: TextStyle(fontSize: textFontSize),
                  ))
            ]),
          ),
        ),
      ),
    );
  }
}
