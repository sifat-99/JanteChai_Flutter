import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Jante Chai',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () {
                context.go('/'); // Navigate to the home screen
              },
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: SizedBox(
                height: 100, // Set a fixed height for the animation
                width: 300, // Set a fixed width for the animation
                child: Lottie.asset(
                  'assets/lottie/start_btn.json',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
