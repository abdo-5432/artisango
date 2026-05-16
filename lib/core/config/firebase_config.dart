import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    await Firebase.initializeApp();

    // Setup Firebase Messaging handlers (foreground/background)
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission on iOS
    if (!kIsWeb) {
      await messaging.requestPermission();
    }

    // You can configure background message handler if you implement cloud functions
    FirebaseMessaging.onMessage.listen((message) {
      // TODO: handle foreground messages
    });
  }
}
