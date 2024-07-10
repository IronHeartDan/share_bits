import 'dart:io';

String? getServer() {
  bool isProduction = false;

  if (isProduction) {
    return 'https://share-bits.onrender.com';
  }

  if (Platform.isAndroid) {
    return 'http://10.0.2.2:3000';
  }
  return 'http://localhost:3000';
}

final serverURL = getServer();
