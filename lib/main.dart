import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wemaro/providers/auth_provider.dart';
import 'package:wemaro/screens/home_screen.dart';
import 'package:wemaro/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'WebRTC Flutter App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: authState.isLoggedIn ? const HomeScreeNew() : const HomeScreeNew(),
    );
  }
}