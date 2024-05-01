import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationState extends ChangeNotifier {
  NotificationState() {
    _configureFirebaseListeners();
  }

  Future<void> _configureFirebaseListeners() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground notification received");
      if (message.notification != null) {
        print("Notification title: ${message.notification!.title}");
        print("Notification body: ${message.notification!.body}");
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessageHandler);
  }

  static Future<void> _firebaseBackgroundMessageHandler(
      RemoteMessage message) async {
    // Handle background notification
    print("Background notification received");
    if (message.notification != null) {
      print("Background notification title: ${message.notification!.title}");
      print("Background notification body: ${message.notification!.body}");
    }
  }
}
