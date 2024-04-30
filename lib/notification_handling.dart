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
      if (message.data.isNotEmpty) {
        print("Message data: ${message.data}");
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessageHandler);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle when the user taps on a notification when the app is in the background
      print("Notification tapped");
      if (message.notification != null) {
        print("Tapped notification title: ${message.notification!.title}");
        print("Tapped notification body: ${message.notification!.body}");
      }
      if (message.data.isNotEmpty) {
        print("Tapped message data: ${message.data}");
      }
      // Navigate to a specific page or perform some action
    });
  }

  static Future<void> _firebaseBackgroundMessageHandler(
      RemoteMessage message) async {
    // Handle background notification
    print("Background notification received");
    if (message.notification != null) {
      print("Background notification title: ${message.notification!.title}");
      print("Background notification body: ${message.notification!.body}");
    }
    if (message.data.isNotEmpty) {
      print("Background message data: ${message.data}");
    }
  }
}
