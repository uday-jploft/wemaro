import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Profile model to hold user details
class Profile {
  final String uid;
  final String? email;
  final String? displayName;

  const Profile({
    required this.uid,
    this.email,
    this.displayName,
  });

  factory Profile.fromFirebaseUser(User user) {
    return Profile(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
    );
  }
}

/// State to manage auth + profile
class AuthState {
  final bool isLoggedIn;
  final String? error;
  final Profile? profile;

  const AuthState({
    required this.isLoggedIn,
    this.error,
    this.profile,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    String? error,
    Profile? profile,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      error: error,
      profile: profile ?? this.profile,
    );
  }
}

/// Auth Notifier
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState(isLoggedIn: false);

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      state = AuthState(isLoggedIn: false, error: 'Fields cannot be empty');
      return;
    }
    if (!email.contains('@')) {
      state = AuthState(isLoggedIn: false, error: 'Invalid email format');
      return;
    }

    try {
      final userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCred.user;
      if (user != null) {
        state = AuthState(
          isLoggedIn: true,
          profile: Profile.fromFirebaseUser(user),
          error: null,
        );
      } else {
        state = AuthState(isLoggedIn: false, error: "User not found");
      }
    } on FirebaseAuthException catch (e) {
      state = AuthState(isLoggedIn: false, error: e.message ?? 'Login failed');
    } catch (e) {
      state = AuthState(isLoggedIn: false, error: 'Network error: $e');
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    state = const AuthState(isLoggedIn: false);
  }
}

/// Provider
final authProvider =
NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
