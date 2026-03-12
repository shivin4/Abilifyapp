import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class AppBootstrap {
  static bool _initialized = false;
  static bool get initialized => _initialized;
  static bool get supabaseEnabled => true; // temp compatibility
  static bool get firebaseEnabled => true;

  static Future<void> init() async {
    if (_initialized) return;
    await dotenv.load(fileName: '.env');

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e, st) {
      log('Firebase init failed: $e', stackTrace: st);
    }

    _initialized = true;
  }
}
