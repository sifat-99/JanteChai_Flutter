import 'package:flutter/material.dart';

class AuthService {
  final ValueNotifier<bool> isLoggedIn = ValueNotifier(false);

  // Simulate a login operation
  void login(String username, String password) {
    // In a real app, you would validate credentials against a backend
    if (username == 'test' && password == 'password') {
      isLoggedIn.value = true;
      debugPrint('User logged in');

    } else {
      debugPrint('Login failed');
      // You might want to throw an exception or return a bool to show an error
    }
  }

  // Simulate a registration operation
  void register(String username, String email, String password) {
    // In a real app, you would send this to a backend to create a new user
    debugPrint('User registered: $username, $email');
    // After successful registration, you might automatically log them in
    // For this example, we'll just log in with 'test'/'password' as a mock
    // In a real app, you'd use the newly registered credentials
    if (username.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      // We'll just set logged in to true for this simulation
      // Or, you could have a rule that new users must use 'test'/'password'
      // A better simulation:
      debugPrint('Simulating auto-login after register...');
      isLoggedIn.value = true;
    }
  }

  // Simulate a logout operation
  void logout() {
    isLoggedIn.value = false;
    debugPrint('User logged out');
  }
}

// Create a singleton instance for easy access throughout the app
final authService = AuthService();
