import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // For now, let's use Firebase directly to get the app working
  // We can migrate to Laravel API later when the network issues are resolved
  static bool get useFirebase {
    return true; // Set to false when Laravel is working
  }

  static String get baseUrl {
    if (useFirebase) {
      // Use Firebase directly
      return 'firebase';
    }

    // Laravel API (when working)
    if (kIsWeb) return 'http://localhost:8000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api';
    return 'http://127.0.0.1:8000/api';
  }
}
