import 'package:flutter/material.dart';

class PublishedNewsScreen extends StatelessWidget {
  const PublishedNewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Published News'),
      ),
      body: const Center(
        child: Text('Published News Screen'),
      ),
    );
  }
}
