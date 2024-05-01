import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'package:gtk_flutter/services/notification_handling.dart'; // Make sure this import points to your NotificationState file
import 'package:gtk_flutter/pages/user/category_page.dart';
import 'package:gtk_flutter/pages/user/message_page.dart';
import 'package:gtk_flutter/pages/login_page.dart';
import 'package:gtk_flutter/pages/admin/category_page_admin.dart';
import 'package:gtk_flutter/pages/admin/message_page_admin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase

  // Initialize your NotificationState
  NotificationState notificationState = NotificationState();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => ApplicationState()),
      Provider(
          create: (context) =>
              notificationState), // You could also use ChangeNotifierProvider if NotificationState was a ChangeNotifier
    ],
    child: const App(),
  ));
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => LoginPage(),
    ),
    GoRoute(
      path: '/categories',
      builder: (context, state) => CategoryPage(),
    ),
    GoRoute(
      path: '/messages',
      builder: (context, state) => MessagePage(),
    ),
    GoRoute(
      path: '/categories/admin',
      builder: (context, state) => CategoryPageAdmin(),
    ),
    GoRoute(
      path: '/messages/admin',
      builder: (context, state) => MessagePageAdmin(),
    ),
  ],
);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}
