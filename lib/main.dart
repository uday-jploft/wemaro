import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wemaro/providers/auth_provider.dart';
import 'package:wemaro/view/home_screen.dart';
import 'package:wemaro/view/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Load initial state asynchronously
    Future.microtask(() async {
      await ref.read(authProvider.notifier).loadInitialState();
    });

    final authState = ref.watch(authProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WebRTC Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,

      ),
      home: authState.isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}