import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'category_page.dart';
import 'message_page.dart';
import 'login_page.dart';
import 'category_page_admin.dart';
import 'message_page_admin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(ChangeNotifierProvider(
    create: (context) => ApplicationState(),
    builder: (context, child) => const App(),
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
