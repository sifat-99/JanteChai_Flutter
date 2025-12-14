import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jante_chai/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  Future<void> _handleSocialLogin(
    BuildContext context,
    Future<String?> Function() signInMethod,
  ) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Logging in... Please wait'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final result = await signInMethod();

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Dismiss dialog
        if (result == 'Success') {
          // Check if we need to redirect, usually Dashboard or Role Selection if not yet set
          // Since the service logic auto-creates 'user', we go to user_dashboard by default
          // Or we check the role from AuthService
          final user = authService.currentUser.value;
          if (user != null) {
            if (user.role == UserRole.admin) {
              context.go('/admin_dashboard');
            } else if (user.role == UserRole.reporter) {
              context.go('/reporter_dashboard');
            } else {
              context.go('/user_dashboard');
            }
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pop(); // Dismiss dialog on error
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('OR'),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialButton(
              icon: FontAwesomeIcons.google,
              color: Colors.red,
              onPressed: () =>
                  _handleSocialLogin(context, authService.signInWithGoogle),
            ),
            const SizedBox(width: 20),
            _SocialButton(
              icon: FontAwesomeIcons.github,
              color: Colors.white,
              onPressed: () =>
                  _handleSocialLogin(context, authService.signInWithGitHub),
            ),
            if (!kIsWeb && Platform.isIOS) ...[
              const SizedBox(width: 20),
              _SocialButton(
                icon: FontAwesomeIcons.apple,
                color: Colors.black,
                onPressed: () =>
                    _handleSocialLogin(context, authService.signInWithApple),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, color: color),
      ),
    );
  }
}
