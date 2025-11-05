import 'package:flutter/material.dart';

enum UserRole { user, reporter, admin }

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Placeholder for user role, this would typically come from an authentication service or similar.
  UserRole _userRole = UserRole.admin; // Default role

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      endDrawer: _buildDrawer(context), // Added endDrawer
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildInfoSection(),
          const SizedBox(height: 24),
          _buildBioSection(),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to edit profile screen
            },
            child: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Text(
              'User Routes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ..._buildDrawerItems(context),
        ],
      ),
    );
  }

  List<Widget> _buildDrawerItems(BuildContext context) {
    List<Widget> items = [];

    // Common routes for all roles
    items.add(ListTile(
      leading: const Icon(Icons.home),
      title: const Text('Home'),
      onTap: () {
        Navigator.pop(context); // Close the drawer
        // Navigate to Home
      },
    ));
    items.add(ListTile(
      leading: const Icon(Icons.settings),
      title: const Text('Settings'),
      onTap: () {
        Navigator.pop(context);
        // Navigate to Settings
      },
    ));

    // Role-specific routes
    if (_userRole == UserRole.user) {
      items.add(ListTile(
        leading: const Icon(Icons.bookmark),
        title: const Text('Saved Posts'),
        onTap: () {
          Navigator.pop(context);
          // Navigate to Saved Posts
        },
      ));
    } else if (_userRole == UserRole.reporter) {
      items.add(ListTile(
        leading: const Icon(Icons.article),
        title: const Text('Manage Articles'),
        onTap: () {
          Navigator.pop(context);
          // Navigate to Manage Articles
        },
      ));
      items.add(ListTile(
        leading: const Icon(Icons.analytics),
        title: const Text('View Reports'),
        onTap: () {
          Navigator.pop(context);
          // Navigate to View Reports
        },
      ));
    } else if (_userRole == UserRole.admin) {
      items.add(ListTile(
        leading: const Icon(Icons.people),
        title: const Text('Manage Users'),
        onTap: () {
          Navigator.pop(context);
          // Navigate to Manage Users
        },
      ));
      items.add(ListTile(
        leading: const Icon(Icons.dashboard),
        title: const Text('Admin Dashboard'),
        onTap: () {
          Navigator.pop(context);
          // Navigate to Admin Dashboard
        },
      ));
      items.add(ListTile(
        leading: const Icon(Icons.analytics_outlined),
        title: const Text('System Logs'),
        onTap: () {
          Navigator.pop(context);
          // Navigate to System Logs
        },
      ));
    }

    items.add(const Divider()); // A separator
    items.add(ListTile(
      leading: const Icon(Icons.logout),
      title: const Text('Logout'),
      onTap: () {
        Navigator.pop(context);
        // Perform Logout
      },
    ));

    return items;
  }

  Widget _buildProfileHeader() {
    return const Column(
      children: <Widget>[
        CircleAvatar(
          radius: 60,
          backgroundImage: NetworkImage('https://avatars.githubusercontent.com/u/125875734?s=400&u=97d6e212b84dae4c960dbbcdf48c9e9f5f069dc4&v=4'), // Fake avatar
        ),
        SizedBox(height: 16),
        Text(
          'Md Abdur Rahman Sifat',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          '@sifat-99',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        _InfoTile(label: 'Posts', value: '142'),
        _InfoTile(label: 'Followers', value: '1.2k'),
        _InfoTile(label: 'Following', value: '350'),
      ],
    );
  }

  Widget _buildBioSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('About Me', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text(
          'Flutter Developer| NextJs Developer | Coffee Enthusiast ☕ | Lifelong Learner 📚\nBuilding beautiful and performant apps.\n📍 Dhaka, Bangladesh',
          style: TextStyle(fontSize: 16, height: 1.4),
        ),
        SizedBox(height: 16),
        Row(children: [Icon(Icons.email_outlined, size: 20), SizedBox(width: 8), Text('mdabdurrahmansifat@gmail.com', style: TextStyle(fontSize: 16))]),
        SizedBox(height: 8),
        Row(children: [Icon(Icons.link_outlined, size: 20), SizedBox(width: 8), Text('mdabdurrahmansifat.vercel.app', style: TextStyle(fontSize: 16, color: Colors.blue))]),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}