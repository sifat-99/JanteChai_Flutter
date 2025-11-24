import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.solidUser),
            title: const Text('My Profile'),
            onTap: () {
              context.push('/profile');
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.solidBookmark),
            title: const Text('Saved News'),
            onTap: () {
              context.push('/saved-news');
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.solidComment),
            title: const Text('My Comments'),
            onTap: () {
              context.push('/my-comments');
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.gear),
            title: const Text('Settings'),
            onTap: () {
              context.push('/settings');
            },
          ),
        ],
      ),
    );
  }
}
