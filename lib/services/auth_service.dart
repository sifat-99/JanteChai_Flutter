import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // Added for JWT decoding

// Define a UserRole enum for consistency across the app
enum UserRole { user, reporter, admin, unknown }

// Basic User model to hold user data
class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? avatarUrl; // Optional avatar URL
  final String? bio;
  final String? github;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.role = UserRole.user,
    this.avatarUrl,
    this.bio,
    this.github,
  });

  // Factory constructor to create a User from a JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: _stringToUserRole(json['role']),
      avatarUrl: json['avatarUrl'],
      bio: json['bio'],
      github: json['github'],
    );
  }

  // Helper to convert string role to UserRole enum
  static UserRole _stringToUserRole(String? roleString) {
    switch (roleString?.toLowerCase()) {
      case 'user':
        return UserRole.user;
      case 'reporter':
      case 'author': // Assuming 'author' might also be a reporter role
        return UserRole.reporter;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.unknown;
    }
  }
}

class AuthService {
  final ValueNotifier<bool> isLoggedIn = ValueNotifier(false);
  final ValueNotifier<User?> currentUser = ValueNotifier(null);

  // SharedPreferences keys
  static const String _authTokenKey = 'authToken';
  static const String _userIdKey = 'userId';
  static const String _userNameKey = 'userName';
  static const String _userEmailKey = 'userEmail';
  static const String _userRoleKey = 'userRole'; // Added for user role
  static const String _userAvatarUrlKey = 'userAvatarUrl'; // Added for avatar
  static const String _userBioKey = 'userBio'; // Added for bio
  static const String _userGithubKey = 'userGithub'; // Added for github

  AuthService() {
    _loadUserSession();
  }

  Future<void> _loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString(_authTokenKey);

    if (authToken != null && authToken.isNotEmpty) {
      try {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(authToken);

        final userId = decodedToken['id'] as String?;
        final userEmail = decodedToken['email'] as String?;
        final userRoleString = decodedToken['role'] as String?;

        // Fallback for userName, use email if not explicitly in token claims
        final userName = decodedToken['name'] as String? ?? userEmail?.split('@').first;

        final userAvatarUrl = prefs.getString(_userAvatarUrlKey);
        final userBio = prefs.getString(_userBioKey);
        final userGithub = prefs.getString(_userGithubKey);

        if (userId != null && userName != null && userEmail != null) {
          currentUser.value = User(
            id: userId,
            name: userName,
            email: userEmail,
            role: User._stringToUserRole(userRoleString),
            avatarUrl: userAvatarUrl,
            bio: userBio,
            github: userGithub,
          );
          isLoggedIn.value = true;
          debugPrint('User session loaded for ${userName}');
        } else {
          // Inconsistent data from token or shared preferences, clear and log out
          await logout();
          debugPrint('Incomplete user data from token or prefs, logged out.');
        }
      } catch (e) {
        debugPrint('Error decoding token during session load: $e');
        await logout(); // Clear invalid token
      }
    } else {
      isLoggedIn.value = false;
      currentUser.value = null;
      debugPrint('No active user session found.');
    }
  }

  // Simulate a login operation
  Future<bool> login(String email, String password) async {
    final url = Uri.parse('https://jante-chaii.vercel.app/api/users/login'); // Assuming a login endpoint

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final String? token = responseData['token'];

        if (token != null && token.isNotEmpty) {
          Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

          final String? userId = decodedToken['id'] as String?;
          final String? userEmail = decodedToken['email'] as String?;
          final String? userRoleString = decodedToken['role'] as String?;
          // Fallback for userName, use email if not explicitly in token claims
          final String? userName = decodedToken['name'] as String? ?? userEmail?.split('@').first;

          // These fields are not in the current JWT, so they will be null
          final String? userAvatarUrl = null;
          final String? userBio = null;
          final String? userGithub = null;

          if (userId != null && userName != null && userEmail != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_authTokenKey, token);
            await prefs.setString(_userIdKey, userId);
            await prefs.setString(_userNameKey, userName);
            await prefs.setString(_userEmailKey, userEmail);
            if (userRoleString != null) await prefs.setString(_userRoleKey, userRoleString);
            // Note: avatarUrl, bio, github are not saved if null/not provided by backend
            // if (userAvatarUrl != null) await prefs.setString(_userAvatarUrlKey, userAvatarUrl);
            // if (userBio != null) await prefs.setString(_userBioKey, userBio);
            // if (userGithub != null) await prefs.setString(_userGithubKey, userGithub);

            currentUser.value = User(
              id: userId,
              name: userName,
              email: userEmail,
              role: User._stringToUserRole(userRoleString),
              avatarUrl: userAvatarUrl,
              bio: userBio,
              github: userGithub,
            );
            isLoggedIn.value = true;
            debugPrint('User logged in successfully');
            return true;
          } else {
            debugPrint('Login failed: Incomplete data from JWT token.');
            isLoggedIn.value = false;
            currentUser.value = null;
            return false;
          }
        } else {
          debugPrint('Login failed: Token not received from backend.');
          isLoggedIn.value = false;
          currentUser.value = null;
          return false;
        }
      } else {
        debugPrint('Login failed: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        isLoggedIn.value = false;
        currentUser.value = null;
        return false;
      }
    } catch (e) {
      debugPrint('An error occurred during login: $e');
      isLoggedIn.value = false;
      currentUser.value = null;
      return false;
    }
  }

  // Simulate a registration operation
  Future<Object?> register(String username, String email, String password) async{
    final url = Uri.parse('https://jante-chaii.vercel.app/api/users/register');

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'name': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Registration successful');
        // Optionally, you might want to log the user in automatically after registration
        // or navigate to a login screen.
        return response;

      } else {
        print('Registration failed: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('An error occurred during registration: $e');
    }
    return null;
  }

  // Simulate a logout operation
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_userAvatarUrlKey);
    await prefs.remove(_userBioKey);
    await prefs.remove(_userGithubKey);

    isLoggedIn.value = false;
    currentUser.value = null;
    debugPrint('User logged out');
  }
}

// Create a singleton instance for easy access throughout the app
final authService = AuthService();