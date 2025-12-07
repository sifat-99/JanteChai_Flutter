import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jante_chai/services/auth_service.dart';
import 'package:go_router/go_router.dart';

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  Future<void> _handleSocialLogin(
    BuildContext context,
    Future<String?> Function() signInMethod,
  ) async {
    final result = await signInMethod();
    if (result == 'Success' && context.mounted) {
      // Check if we need to redirect, usually Dashboard or Role Selection if not yet set
      // Since the service logic auto-creates 'user', we go to user_dashboard by default
      // Or we can check the role from AuthService
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
            if (Platform.isIOS) ...[
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
