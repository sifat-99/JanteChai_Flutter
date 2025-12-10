import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:jante_chai/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
// import 'dart:io' show Platform; // Removed unused import
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

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
  final String? status; // Added status field

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
    this.status,
  });

  // Factory constructor to create a User from a JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: _stringToUserRole(json['role']),
      avatarUrl: json['profilePic'],
      bio: json['bio'],
      github: json['github'],
      reporterId: json['reporterId'],
      createdAt: json['createdAt'],
      status: json['status'],
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
    return 'User(id: $id, name: $name, email: $email, role: $role, avatarUrl: $avatarUrl, bio: $bio, github: $github, reporterId: $reporterId, createdAt: $createdAt, status: $status)';
  }
}

class AuthService {
  final ValueNotifier<bool> isLoggedIn = ValueNotifier(false);
  final ValueNotifier<User?> currentUser = ValueNotifier(null);
  final ValueNotifier<bool> isLoading = ValueNotifier(true);

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
  static const String _userStatusKey = 'userStatus';

  AuthService() {
    _loadUserSession();
  }

  Future<void> _loadUserSession() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString(_authTokenKey);

      if (authToken != null && authToken.isNotEmpty) {
        try {
          if (JwtDecoder.isExpired(authToken)) {
            await logout();
            debugPrint('Token expired, logged out.');
            return;
          }
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
          final userStatus = prefs.getString(_userStatusKey);

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
              status: userStatus,
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
    } finally {
      isLoading.value = false;
    }
  }

  // Unified logic to handle backend sync after Firebase Auth
  Future<String> _syncBackendAfterAuth(
    fb_auth.User firebaseUser, {
    String? password,
  }) async {
    // 1. Try to Login to Backend (as User first, then Reporter?)
    final email = firebaseUser.email!;
    final name = firebaseUser.displayName ?? email.split('@').first;
    final photoUrl = firebaseUser.photoURL ?? '';
    final pwd =
        password ??
        firebaseUser.uid; // Use UID as fallback password for social accounts

    // Try login as User
    var token = await _attemptBackendLogin(email, pwd, 'users/login');
    print(token);
    if (token == null) {
      // Try login as Reporter
      token = await _attemptBackendLogin(email, pwd, 'reporters/login');
    }
    if (token == null) {
      token = await _attemptBackendLogin(email, pwd, 'admins/login');
    }

    if (token == null) {
      // User does not exist in backend? Or wrong password?
      // If Social Login (password was null originally), we assume we should REGISTER them as USER now.
      if (password == null) {
        debugPrint(
          'User not found in backend, registering as NEW USER via Social Login...',
        );
        final regSuccess = await _attemptBackendRegister(
          name,
          email,
          pwd,
          photoUrl,
          'users/register',
        );
        if (regSuccess) {
          // Try login again
          token = await _attemptBackendLogin(email, pwd, 'users/login');
        }
      } else {
        // If Email/Pass login and backend login failed, it might mean they registered
        // via Firebase but didn't finish Role Selection (Backend registration).
        // Or specific database issue.
        // We will return 'NeedsRoleSelection' to prompt the UI to send them there.
        return 'NeedsRoleSelection';
      }
    }

    if (token != null) {
      await _saveSession(token);
      return 'Success';
    } else {
      // Only if social registration also failed
      throw Exception('Failed to sync with backend database.');
    }
  }

  Future<String?> _attemptBackendLogin(
    String email,
    String password,
    String endpoint,
  ) async {
    try {
      final responseData = await ApiService.post(endpoint, {
        'email': email,
        'password': password,
      });
      return responseData['token'];
    } catch (e) {
      return null;
    }
  }

  Future<bool> _attemptBackendRegister(
    String name,
    String email,
    String password,
    String photoUrl,
    String endpoint,
  ) async {
    try {
      await ApiService.post(endpoint, {
        'name': name,
        'email': email,
        'password': password,
        'profilePic': photoUrl,
      });
      return true;
    } catch (e) {
      debugPrint('Backend registration failed: $e');
      return false;
    }
  }

  Future<String?> loginWithEmailHelper(String email, String password) async {
    try {
      // 1. Firebase Login
      final credential = await fb_auth.FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      final user = credential.user;
      if (user != null) {
        if (!user.emailVerified) {
          debugPrint('Email not verified');
          return 'EmailNotVerified';
        }

        final result = await _syncBackendAfterAuth(user, password: password);
        return result;
      }
    } catch (e) {
      debugPrint('Firebase Login Failed: $e. Attempting backend fallback...');

      // Fallback: Try backend login directly for all roles

      // 1. Try User
      var token = await _attemptBackendLogin(email, password, 'users/login');

      // 2. Try Reporter
      if (token == null) {
        debugPrint('Reporter Login Failed: $e');
        token = await _attemptBackendLogin(email, password, 'reporters/login');
      }

      // 3. Try Admin
      if (token == null) {
        debugPrint('Admin Login Failed: $e');
        token = await _attemptBackendLogin(email, password, 'admins/login');
      }

      if (token != null) {
        await _saveSession(token);
        return 'Success';
      }

      if (e.toString().contains('Failed to sync')) {
        return 'SyncFailed';
      }
      debugPrint('Login Error (Firebase & Backend): $e');
      return null;
    }
    return null;
  }

  Future<String> loginAsAdmin(String email, String password) async {
    try {
      debugPrint('Attempting direct Admin login for $email');
      final token = await _attemptBackendLogin(email, password, 'admins/login');
      if (token != null) {
        await _saveSession(token);
        return 'Success';
      }
      return 'Invalid Credentials';
    } catch (e) {
      debugPrint('Admin Login Error: $e');
      return 'Error: $e';
    }
  }

  Future<void> sendEmailVerification() async {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      try {
        await user.sendEmailVerification();
        debugPrint('Verification email sent to ${user.email}');
      } catch (e) {
        debugPrint('Failed to send verification email: $e');
      }
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await fb_auth.FirebaseAuth.instance.sendPasswordResetEmail(
        email: email.trim(),
      );
      debugPrint('Password reset email sent to $email');
    } catch (e) {
      debugPrint('Failed to send password reset email: $e');
      rethrow; // Rethrow to let the UI handle specific errors if needed
    }
  }

  // Legacy support or direct role login if needed (Optional, keeping consistent signature for now if used elsewhere)
  // CHANGED: Now uses Firebase internally.
  Future<String?> login(String email, String password, UserRole role) async {
    return await loginWithEmailHelper(email, password);
  }

  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // Cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final fb_auth.AuthCredential credential =
          fb_auth.GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

      final userCredential = await fb_auth.FirebaseAuth.instance
          .signInWithCredential(credential);
      if (userCredential.user != null) {
        return await _syncBackendAfterAuth(userCredential.user!);
      }
    } catch (e) {
      debugPrint('Google Sign In Error: $e');
    }
    return null;
  }

  /*
  Future<String?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final fb_auth.AuthCredential credential =
            fb_auth.FacebookAuthProvider.credential(accessToken.tokenString);

        final userCredential = await fb_auth.FirebaseAuth.instance
            .signInWithCredential(credential);
        if (userCredential.user != null) {
          return await _syncBackendAfterAuth(userCredential.user!);
        }
      }
    } catch (e) {
      debugPrint('Facebook Sign In Error: $e');
    }
    return null;
  }
  */

  Future<String?> signInWithGitHub() async {
    try {
      final fb_auth.OAuthProvider provider = fb_auth.OAuthProvider(
        'github.com',
      );
      provider.addScope('read:user');
      provider.addScope('user:email');

      final fb_auth.UserCredential userCredential = await fb_auth
          .FirebaseAuth
          .instance
          .signInWithProvider(provider);

      if (userCredential.user != null) {
        return await _syncBackendAfterAuth(userCredential.user!);
      }
    } catch (e) {
      debugPrint('GitHub Sign In Error: $e');
    }
    return null;
  }

  Future<String?> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthProvider = fb_auth.OAuthProvider('apple.com');
      final fb_auth.AuthCredential firebaseCredential = oAuthProvider
          .credential(
            idToken: credential.identityToken,
            accessToken: credential.authorizationCode,
          );

      final userCredential = await fb_auth.FirebaseAuth.instance
          .signInWithCredential(firebaseCredential);
      if (userCredential.user != null) {
        return await _syncBackendAfterAuth(userCredential.user!);
      }
    } catch (e) {
      debugPrint('Apple Sign In Error: $e');
    }
    return null;
  }

  // STEP 1 of Registration: Firebase Only
  Future<bool> firebaseSignUp(String email, String password) async {
    try {
      await fb_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return true;
    } catch (e) {
      debugPrint('Firebase SignUp Error: $e');
      return false;
    }
  }

  // STEP 2 of Registration: Backend + Role
  Future<bool> finalizeRegistration(UserRole role) async {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    // We need a password to register in backend according to old logic.
    // But we don't store the password in plain text here easily.
    // Workaround: Use UID as password for backend consistency if we can't get original password?
    // OR: Pass the password from the UI.
    // BETTER: The UI should pass the password to this method?
    // But we are in a multi-step flow.
    // Let's assume we use UID as password for consistency with Social Login pattern,
    // OR we ask the user to input password again? No that's bad UX.
    // We will use the UID as the backend password for this flow.

    final endpoint = role == UserRole.reporter
        ? 'reporters/register'
        : 'users/register';
    final success = await _attemptBackendRegister(
      user.displayName ?? user.email!.split('@')[0],
      user.email!,
      user.uid, // Using UID as password
      user.photoURL ?? '',
      endpoint,
    );

    if (success) {
      // Now login to get the token
      final token = await _attemptBackendLogin(
        user.email!,
        user.uid,
        role == UserRole.reporter ? 'reporters/login' : 'users/login',
      );
      if (token != null) {
        await _saveSession(token);
        return true;
      }
    }
    return false;
  }

  Future<void> _saveSession(String token) async {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

    final String? userId = decodedToken['id'] as String?;
    final String? userEmail = decodedToken['email'] as String?;
    final String? userRoleString = decodedToken['role'] as String?;
    final String? userName = decodedToken['name'] as String?;
    final String? userAvatarUrl = decodedToken['profilePic'] as String?;
    final String? reporterId = decodedToken['reporterId'] as String?;
    final String? createdAt = decodedToken['createdAt'] as String?;
    final String? userStatus = decodedToken['status'] as String?;

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
      if (userStatus != null) {
        await prefs.setString(_userStatusKey, userStatus);
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
        status: userStatus,
      );
      isLoggedIn.value = true;
      debugPrint('User logged in successfully');
    }
  }

  // Deprecated/Modified register to match new flow - kept for compatibility if needed but calls new logic
  Future<dynamic> register(
    String username,
    String email,
    String password,
    String profilePic,
    UserRole role,
  ) async {
    // This was the old "One Step" register.
    // We should ideally use the split flow now.
    // But for backward compatibility or direct calls:
    final fbSuccess = await firebaseSignUp(email, password);
    if (fbSuccess) {
      // Update Profile with name
      await fb_auth.FirebaseAuth.instance.currentUser?.updateDisplayName(
        username,
      );
      await fb_auth.FirebaseAuth.instance.currentUser?.updatePhotoURL(
        profilePic,
      ); // if valid URL

      // Finalize
      final backendSuccess = await finalizeRegistration(
        role,
      ); // NOTE: This uses UID as password.
      return backendSuccess ? {'token': 'simulated_success'} : null;
    }
    return null;
  }

  // Simulate a logout operation
  Future<void> logout() async {
    await fb_auth.FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut(); // Ensure Google is signed out too

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
    await prefs.remove(_userStatusKey);

    isLoggedIn.value = false;
    currentUser.value = null;
    debugPrint('User logged out');
  }

  Future<bool> updateProfile({
    String? name,
    String? bio,
    String? github,
    String? avatarUrl,
  }) async {
    final user = currentUser.value;
    if (user == null) return false;

    String endpoint = "";
    if (user.role == UserRole.reporter) {
      endpoint = 'reporters/${user.id}';
    } else if (user.role == UserRole.user) {
      endpoint = 'users/${user.id}';
    } else if (user.role == UserRole.admin) {
      endpoint = 'admins/${user.id}';
    } else {
      return false;
    }

    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (bio != null) data['bio'] = bio;
    if (github != null) data['github'] = github;
    if (avatarUrl != null) data['profilePic'] = avatarUrl;

    try {
      await ApiService.put(endpoint, data);

      // Update local user data
      final prefs = await SharedPreferences.getInstance();
      if (name != null) {
        await prefs.setString(_userNameKey, name);
      }
      if (bio != null) {
        await prefs.setString(_userBioKey, bio);
      }
      if (github != null) {
        await prefs.setString(_userGithubKey, github);
      }
      if (avatarUrl != null) {
        await prefs.setString(_userProfilePicKey, avatarUrl);
      }

      // Update currentUser value to trigger listeners
      currentUser.value = User(
        id: user.id,
        name: name ?? user.name,
        email: user.email,
        role: user.role,
        avatarUrl: avatarUrl ?? user.avatarUrl,
        bio: bio ?? user.bio,
        github: github ?? user.github,
        reporterId: user.reporterId,
        createdAt: user.createdAt,
      );

      return true;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    }
  }
}

// Create a singleton instance for easy access throughout the app
final authService = AuthService();
