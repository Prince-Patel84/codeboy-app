import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:3000/api';
    } else {
      try {
        if (Platform.isAndroid) {
          return 'http://10.0.2.2:3000/api';
        }
      } catch (e) {
         // fallback
      }
      return 'http://127.0.0.1:3000/api';
    }
  }
}
