import 'package:flutter/material.dart';
import 'package:jante_chai/services/auth_service.dart'; // Import AuthService
import 'package:go_router/go_router.dart'; // Import go_router

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser; // Holds the current user data
  late UserRole _userRole; // User role for drawer items

  @override
  void initState() {
    super.initState();
    // Initialize current user and role from AuthService
    _currentUser = authService.currentUser.value;
    _userRole = _currentUser?.role ?? UserRole.unknown;

    // Listen to changes in login status and current user
    authService.isLoggedIn.addListener(_onAuthChanged);
    authService.currentUser.addListener(_onUserChanged);
  }

  @override
  void dispose() {
    authService.isLoggedIn.removeListener(_onAuthChanged);
    authService.currentUser.removeListener(_onUserChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    setState(() {
      // Re-fetch user details when login status changes
      _currentUser = authService.currentUser.value;
      _userRole = _currentUser?.role ?? UserRole.unknown;
    });
  }

  void _onUserChanged() {
    setState(() {
      _currentUser = authService.currentUser.value;
      _userRole = _currentUser?.role ?? UserRole.unknown;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = authService.isLoggedIn.value;

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
          _buildProfileHeader(isLoggedIn),
          const SizedBox(height: 24),
          _buildInfoSection(isLoggedIn),
          const SizedBox(height: 24),
          _buildBioSection(isLoggedIn),
          const SizedBox(height: 24),
          if (isLoggedIn) // Show Edit Profile button only if logged in
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to edit profile screen
              },
              child: const Text('Edit Profile'),
            ) 
          else // Show Login button if not logged in
            ElevatedButton(
              onPressed: () {
                context.push('/login'); // Navigate to Login screen
              },
              child: const Text('Login'),
            ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final bool isLoggedIn = authService.isLoggedIn.value;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Text(
              isLoggedIn ? 'Welcome, ${_currentUser?.name ?? 'User'}' : 'Guest User',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ..._buildDrawerItems(context, isLoggedIn),
        ],
      ),
    );
  }

  List<Widget> _buildDrawerItems(BuildContext context, bool isLoggedIn) {
    List<Widget> items = [];

    // Common routes for all (logged in or not)
    items.add(ListTile(
      leading: const Icon(Icons.home),
      title: const Text('Home'),
      onTap: () {
        Navigator.pop(context); // Close the drawer
        context.go('/'); // Navigate to Home
      },
    ));
    items.add(ListTile(
      leading: const Icon(Icons.settings),
      title: const Text('Settings'),
      onTap: () {
        Navigator.pop(context);
      },
    ));

    if (isLoggedIn && _currentUser != null) {
      // Role-specific routes for logged-in users
      if (_userRole == UserRole.user) {
        items.add(ListTile(
          leading: const Icon(Icons.bookmark),
          title: const Text('Saved Posts'),
          onTap: () {
            Navigator.pop(context);
            // TODO: Navigate to Saved Posts
          },
        ));
      } else if (_userRole == UserRole.reporter) {
        items.add(ListTile(
          leading: const Icon(Icons.article),
          title: const Text('Manage Articles'),
          onTap: () {
            Navigator.pop(context);
            // TODO: Navigate to Manage Articles
          },
        ));
        items.add(ListTile(
          leading: const Icon(Icons.analytics),
          title: const Text('View Reports'),
          onTap: () {
            Navigator.pop(context);
            // TODO: Navigate to View Reports
          },
        ));
      } else if (_userRole == UserRole.admin) {
        items.add(ListTile(
          leading: const Icon(Icons.people),
          title: const Text('Manage Users'),
          onTap: () {
            Navigator.pop(context);
            // TODO: Navigate to Manage Users
          },
        ));
        items.add(ListTile(
          leading: const Icon(Icons.dashboard),
          title: const Text('Admin Dashboard'),
          onTap: () {
            Navigator.pop(context);
            // TODO: Navigate to Admin Dashboard
          },
        ));
        items.add(ListTile(
          leading: const Icon(Icons.analytics_outlined),
          title: const Text('System Logs'),
          onTap: () {
            Navigator.pop(context);
            // TODO: Navigate to System Logs
          },
        ));
      }

      items.add(const Divider()); // A separator
      items.add(ListTile(
        leading: const Icon(Icons.logout),
        title: const Text('Logout'),
        onTap: () async {
          Navigator.pop(context); // Close the drawer
          await authService.logout(); // Perform Logout
        },
      ));
    } else {
      // Add login/registration options for logged-out users in drawer if desired
      items.add(const Divider());
      items.add(ListTile(
        leading: const Icon(Icons.login),
        title: const Text('Login'),
        onTap: () {
          Navigator.pop(context);
          context.push('/login'); // Navigate to Login screen
        },
      ));
      items.add(ListTile(
        leading: const Icon(Icons.person_add),
        title: const Text('Register'),
        onTap: () {
          Navigator.pop(context);
          // TODO: Navigate to Register screen
          print('Navigate to Register from Drawer');
        },
      ));
    }

    return items;
  }

  Widget _buildProfileHeader(bool isLoggedIn) {
    final String displayName = _currentUser?.name ?? 'Guest User';
    final String displayHandle = _currentUser?.reporterId ?? (_currentUser?.email ?? 'Not logged in');
    final String? avatarUrl = _currentUser?.avatarUrl;

    return Column(
      children: <Widget>[
        CircleAvatar(
          radius: 60,
          child: avatarUrl != null && avatarUrl.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    width: 120.0,
                    height: 120.0,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.person, size: 60);
                    },
                  ),
                )
              : const Icon(Icons.person, size: 60),
        ),
        const SizedBox(height: 16),
        Text(
          displayName,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          displayHandle,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildInfoSection(bool isLoggedIn) {
    // Placeholder data for now, as backend doesn't provide posts/followers/following directly
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        _InfoTile(label: 'Posts', value: '0'),
        _InfoTile(label: 'Followers', value: '0'),
        _InfoTile(label: 'Following', value: '0'),
      ],
    );
  }

  Widget _buildBioSection(bool isLoggedIn) {
    final String displayBio = _currentUser?.bio ?? 'Please log in to see your profile details.';
    final String displayEmail = _currentUser?.email ?? 'N/A';
    final String displayGithub = _currentUser?.github != null ? 'github.com/${_currentUser!.github}' : 'N/A';
    final String? createdAt = _currentUser?.createdAt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('About Me', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          displayBio,
          style: const TextStyle(fontSize: 16, height: 1.4),
        ),
        const SizedBox(height: 16),
        Row(children: [const Icon(Icons.email_outlined, size: 20), const SizedBox(width: 8), Text(displayEmail, style: const TextStyle(fontSize: 16))]),
        const SizedBox(height: 8),
        Row(children: [const Icon(Icons.link_outlined, size: 20), const SizedBox(width: 8), Text(displayGithub, style: const TextStyle(fontSize: 16, color: Colors.blue))]),
        if (createdAt != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(children: [const Icon(Icons.calendar_today_outlined, size: 20), const SizedBox(width: 8), Text('Member since: $createdAt', style: const TextStyle(fontSize: 16))]),
          ),
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
