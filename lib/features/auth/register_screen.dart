import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jante_chai/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _profilePicController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _profilePicController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _register(UserRole role) async {
    final username = _usernameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final profilePic = _profilePicController.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _showErrorSnackBar('Please fill in all fields.');
      return;
    }

    final dynamic didRegister = await authService.register(
      username,
      email,
      password,
      profilePic,
      role,
    );

    if (didRegister != null && mounted) {
      // Assuming a successful registration will return a non-null object
      context.pop(); // Navigate back to login
    } else if (mounted) {
      _showErrorSnackBar('Registration failed. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _profilePicController,
              decoration: const InputDecoration(
                labelText: 'Profile Picture URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _register(UserRole.user),
                  child: const Text('Register as User'),
                ),
                ElevatedButton(
                  onPressed: () => _register(UserRole.reporter),
                  child: const Text('Register as Reporter'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () {
                context.pop(); // Navigate back to login
              },
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
