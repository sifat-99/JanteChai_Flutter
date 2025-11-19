import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.newspaper),
            title: const Text('Manage News'),
            onTap: () {
              context.go('/manage-news');
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.users),
            title: const Text('Manage Users'),
            onTap: () {
              context.go('/manage-users');
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.userSecret),
            title: const Text('Manage Reporters'),
            onTap: () {
              context.go('/manage-reporters');
            },
          ),
        ],
      ),
    );
  }
}
