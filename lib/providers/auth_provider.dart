import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile {
  final String uid;
  final String? email;
  final String? displayName;

  const Profile({
    required this.uid,
    this.email,
    this.displayName,
  });

  factory Profile.fromMock(String email, String displayName) {
    return Profile(
      uid: DateTime.now().millisecondsSinceEpoch.toString(), // Mock UID
      email: email,
      displayName: displayName,
    );
  }
}

class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final String? error;
  final Profile? profile;

  const AuthState({
    required this.isLoggedIn,
    this.isLoading = false,
    this.error,
    this.profile,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    String? error,
    Profile? profile,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      profile: profile ?? this.profile,
    );
  }
}

/// Auth Notifier
class AuthNotifier extends Notifier<AuthState> {
  static const String _isLoggedInKey = 'isLoggedIn';

  static const String _mockDisplayName = 'Mock User';

  @override
  AuthState build() {
    // Initial synchronous state
    return const AuthState(isLoggedIn: false);
  }

  // Load initial state asynchronously
  Future<void> loadInitialState() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    state = AuthState(
      isLoggedIn: isLoggedIn,
      profile: isLoggedIn ? Profile.fromMock("user@email.com", _mockDisplayName) : null,
    );
  }

  Future<void> login(String email, String password) async {
    // Start loading
    state = state.copyWith(isLoading: true, error: null);


    // Input validation
    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(isLoading: false, error: 'All fields are required');
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      state = state.copyWith(isLoading: false, error: 'Please enter a valid email');
      return;
    }
    if (password.length < 6) {
      state = state.copyWith(isLoading: false, error: 'Password must be at least 6 characters');
      return;
    }


    // Mock authentication
    if (email.isNotEmpty && password.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      state = state.copyWith(
        isLoggedIn: true,
        isLoading: false,
        profile: Profile.fromMock(email, _mockDisplayName),
        error: null,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: 'Invalid email or password',
      );
    }
  }

  Future<void> logout() async {
    // Start loading
    state = state.copyWith(isLoading: true, error: null);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
    state = const AuthState(isLoggedIn: false, isLoading: false);
  }
}

/// Provider
final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new, dependencies: []);