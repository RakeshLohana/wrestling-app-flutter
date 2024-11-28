import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

Future<String> getStorageDirectory() async {
  if (defaultTargetPlatform == TargetPlatform.android) {
    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      throw Exception('External storage directory not found');
    }
    return directory.path;
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  } else {
    throw UnsupportedError('Unsupported platform');
  }
}
