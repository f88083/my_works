import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'screen/audioplayer_local_assets.dart';

import 'package:intl/intl.dart';

class FileManager {
  Future<String> _getFilePath(String folderName) async {
    final directory = await getExternalStorageDirectory();
    final folder = Directory('${directory!.path}/$folderName');
    return folder.path;
  }

  Future<File> _getFileWithFileName(
      String fileName, String folderName, DateTime now) async {
    final path = await _getFilePath(folderName);
    String formattedDate = DateFormat('dd-MM-yyyy–HH-mm-ss').format(now);
    return File('$path/${fileName}_${folderName}_$formattedDate.txt');
  }

  void saveFromListToFile(
      List data, String fileName, String folderName, DateTime now) async {
    final file = await _getFileWithFileName(fileName, folderName, now);

    file.writeAsString(data.toString());
  }

  // To save feedback text after submit
  void saveFeedbackText(String data, String fileName, String folderName) async {
    DateTime now = DateTime.now();
    final file = await _getFileWithFileName(fileName, folderName, now);
    file.writeAsString(data.toString());
  }
}
