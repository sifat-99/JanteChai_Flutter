import 'package:flutter/material.dart';

class ManageReportersScreen extends StatelessWidget {
  const ManageReportersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Reporters')),
      body: const Center(child: Text('Here you can manage all reporters.')),
    );
  }
}
