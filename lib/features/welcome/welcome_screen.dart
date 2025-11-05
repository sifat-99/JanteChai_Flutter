import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';



class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Text(
                  'Jante Chai',
                  textAlign: TextAlign.center,
                  // style: Theme.of(context).textTheme.headlineLarge,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.blueAccent,
                  )
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context.go('/'); // Navigate to the home screen
                  },
                  child: Lottie.asset('assets/lottie/get_started_animation.json'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
