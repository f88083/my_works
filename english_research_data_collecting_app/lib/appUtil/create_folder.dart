import 'dart:io';

import 'package:path_provider/path_provider.dart';

class AppUtil {
  static Future<String> createFolderInAppDocDir(String folderName) async {
    //Get this App Document Directory
    final Directory _appDocDir = await getApplicationDocumentsDirectory();
    //App Document Directory + folder name
    final Directory _appDocDirFolder =
        Directory('${_appDocDir.path}/$folderName/');

    if (await _appDocDirFolder.exists()) {
      //if folder already exists return path
      return _appDocDirFolder.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory _appDocDirNewFolder =
          await _appDocDirFolder.create(recursive: true);
      return _appDocDirNewFolder.path;
    }
  }

  static Future<String> createFolderInExternalDocDir(String folderName) async {
    //Get this App Document Directory
    final Directory? _externalDocDir = await getExternalStorageDirectory();
    //App Document Directory + folder name
    final Directory _externalDocDirFolder =
        Directory('${_externalDocDir!.path}/$folderName/');

    if (await _externalDocDirFolder.exists()) {
      //if folder already exists return path
      return _externalDocDirFolder.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory _externalDocDirNewFolder =
          await _externalDocDirFolder.create(recursive: true);
      return _externalDocDirNewFolder.path;
    }
  }
}
