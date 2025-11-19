import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:jante_chai/services/api_service.dart';
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
  final String? reporterId;
  final String? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.role = UserRole.user,
    this.avatarUrl,
    this.bio,
    this.github,
    this.reporterId,
    this.createdAt,
  });

  // Factory constructor to create a User from a JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: _stringToUserRole(json['role']),
      avatarUrl: json['profilePic'],
      bio: json['bio'],
      github: json['github'],
      reporterId: json['reporterId'],
      createdAt: json['createdAt'],
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

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, role: $role, avatarUrl: $avatarUrl, bio: $bio, github: $github, reporterId: $reporterId, createdAt: $createdAt)';
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
  static const String _userProfilePicKey = 'profilePic'; // Added for avatar
  static const String _userBioKey = 'userBio'; // Added for bio
  static const String _userGithubKey = 'userGithub'; // Added for github
  static const String _userReporterIdKey = 'reporterId';
  static const String _userCreatedAtKey = 'createdAt';

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
        final userName =
            decodedToken['name'] as String? ?? userEmail?.split('@').first;

        final userAvatarUrl = prefs.getString(_userProfilePicKey);
        final userBio = prefs.getString(_userBioKey);
        final userGithub = prefs.getString(_userGithubKey);
        final reporterId = prefs.getString(_userReporterIdKey);
        final createdAt = prefs.getString(_userCreatedAtKey);

        if (userId != null && userName != null && userEmail != null) {
          currentUser.value = User(
            id: userId,
            name: userName,
            email: userEmail,
            role: User._stringToUserRole(userRoleString),
            avatarUrl: userAvatarUrl,
            bio: userBio,
            github: userGithub,
            reporterId: reporterId,
            createdAt: createdAt,
          );
          isLoggedIn.value = true;
          debugPrint('User session loaded for ${userName}');
          debugPrint('Loaded user: ${currentUser.value}');
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

  Future<String?> login(String email, String password, UserRole role) async {
    String endpoint = "";
    if (role == UserRole.reporter) {
      endpoint = 'reporters/login';
    } else if (role == UserRole.user) {
      endpoint = 'users/login';
    } else if (role == UserRole.admin) {
      endpoint = 'admins/login';
    } else {
      debugPrint('Invalid role provided for login: $role');
      return null;
    }
    try {
      final responseData = await ApiService.post(endpoint, {
        'email': email,
        'password': password,
      });

      final String? token = responseData['token'];

      if (token != null && token.isNotEmpty) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

        final String? userId = decodedToken['id'] as String?;
        final String? userEmail = decodedToken['email'] as String?;
        final String? userRoleString = decodedToken['role'] as String?;
        final String? userName =
            decodedToken['name'] as String? ?? userEmail?.split('@').first;
        final String? userAvatarUrl = decodedToken['profilePic'] as String?;
        final String? reporterId = decodedToken['reporterId'] as String?;
        final String? createdAt = decodedToken['createdAt'] as String?;

        final String? userBio = null;
        final String? userGithub = null;

        if (userId != null && userName != null && userEmail != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_authTokenKey, token);
          await prefs.setString(_userIdKey, userId);
          await prefs.setString(_userNameKey, userName);
          await prefs.setString(_userEmailKey, userEmail);
          if (userRoleString != null) {
            await prefs.setString(_userRoleKey, userRoleString);
          }
          if (userAvatarUrl != null) {
            await prefs.setString(_userProfilePicKey, userAvatarUrl);
          }
          if (reporterId != null) {
            await prefs.setString(_userReporterIdKey, reporterId);
          }
          if (createdAt != null) {
            await prefs.setString(_userCreatedAtKey, createdAt);
          }

          currentUser.value = User(
            id: userId,
            name: userName,
            email: userEmail,
            role: User._stringToUserRole(userRoleString),
            avatarUrl: userAvatarUrl,
            bio: userBio,
            github: userGithub,
            reporterId: reporterId,
            createdAt: createdAt,
          );
          isLoggedIn.value = true;
          debugPrint('User logged in successfully');
          debugPrint('Logged in user: ${currentUser.value}');
          return userRoleString;
        } else {
          debugPrint('Login failed: Incomplete data from JWT token.');
          isLoggedIn.value = false;
          currentUser.value = null;
          return null;
        }
      } else {
        debugPrint('Login failed: Token not received from backend.');
        isLoggedIn.value = false;
        currentUser.value = null;
        return null;
      }
    } catch (e) {
      debugPrint('An error occurred during login: $e');
      isLoggedIn.value = false;
      currentUser.value = null;
      return null;
    }
  }

  Future<dynamic> register(
      String username, String email, String password, String profilePic, UserRole role) async {
    fb_auth.UserCredential? userCredential;
    try {
      userCredential = await fb_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      String endpoint =
          role == UserRole.reporter ? 'reporters/register' : 'users/register';

      final backendResponse = await ApiService.post(endpoint, {
        'name': username,
        'email': email,
        'password': password,
        'profilePic': profilePic,
      });

      return backendResponse;
    } on fb_auth.FirebaseAuthException catch (e) {
      print(e.message);
      return null;
    } catch (e) {
      // If backend registration fails, delete the Firebase user.
      if (userCredential != null) {
        await userCredential.user?.delete();
      }
      print('An error occurred during registration: $e');
      return null;
    }
  }

  // Simulate a logout operation
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_userProfilePicKey);
    await prefs.remove(_userBioKey);
    await prefs.remove(_userGithubKey);
    await prefs.remove(_userReporterIdKey);
    await prefs.remove(_userCreatedAtKey);

    isLoggedIn.value = false;
    currentUser.value = null;
    debugPrint('User logged out');
  }
}

// Create a singleton instance for easy access throughout the app
final authService = AuthService();