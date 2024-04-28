import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart'
    hide
        EmailAuthProvider,
        PhoneAuthProvider; // Since it's hidden, let's assume it's managed elsewhere if needed
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  String _email = '';
  String get email => _email;

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _loggedIn = true;
        _email = user.email!;
      } else {
        _loggedIn = false;
        _email = '';
      }
      notifyListeners();
    });

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
      // Add other providers you might be using
    ]);
  }

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
