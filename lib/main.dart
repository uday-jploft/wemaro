import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wemaro/providers/auth_provider.dart';
import 'package:wemaro/view/spalsh_screen.dart';
import 'package:wemaro/view/home_screen.dart';
import 'package:wemaro/view/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter WebRTC',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/auth_check': (context) => const AuthCheckScreen(),
      },
    );
  }
}

// Auth Check Screen - Determines where to navigate based on auth state
class AuthCheckScreen extends ConsumerStatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  ConsumerState<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends ConsumerState<AuthCheckScreen> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    // Load initial auth state
    await ref.read(authProvider.notifier).loadInitialState();

    // Wait a bit for smooth transition
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isChecking = false;
      });

      // Navigate to appropriate screen
      final authState = ref.read(authProvider);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => authState.isLoggedIn
              ? const HomeScreen()
              : const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1976D2),
              Color(0xFF2196F3),
              Color(0xFF42A5F5),
            ],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }
}