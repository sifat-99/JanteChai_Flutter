import 'package:flutter/material.dart';
import 'package:jante_chai/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
  late UserRole _userRole;

  @override
  void initState() {
    super.initState();
    _currentUser = authService.currentUser.value;
    _userRole = _currentUser?.role ?? UserRole.unknown;
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      endDrawer: _buildDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(isLoggedIn),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (isLoggedIn) ...[
                    _buildInfoSection(),
                    const SizedBox(height: 16),
                    _buildBioSection(),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/edit-profile'),
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Profile'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ] else
                    _buildGuestView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestView() {
    return Center(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Guest User',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please login to view your profile details.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.push('/login'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isLoggedIn) {
    final String displayName = _currentUser?.name ?? 'Guest User';
    final String displayHandle =
        _currentUser?.reporterId ?? (_currentUser?.email ?? 'Not logged in');
    final String? avatarUrl = _currentUser?.avatarUrl;

    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 280,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.7),
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Theme.of(context).cardColor,
                  backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: avatarUrl == null || avatarUrl.isEmpty
                      ? const Icon(Icons.person, size: 60, color: Colors.grey)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                displayName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              Text(
                displayHandle,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              _InfoTile(label: 'Posts', value: '0'),
              _VerticalDivider(),
              _InfoTile(label: 'Followers', value: '0'),
              _VerticalDivider(),
              _InfoTile(label: 'Following', value: '0'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBioSection() {
    final String displayBio = _currentUser?.bio ?? 'No bio available.';
    final String displayEmail = _currentUser?.email ?? 'N/A';
    final String displayGithub = _currentUser?.github ?? 'N/A';
    final String? createdAt = _currentUser?.createdAt;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About Me',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              displayBio,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const Divider(height: 32),
            _buildDetailRow(Icons.email_outlined, 'Email', displayEmail),
            const SizedBox(height: 12),
            _buildDetailRow(FontAwesomeIcons.github, 'GitHub', displayGithub),
            if (createdAt != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.calendar_today_outlined,
                'Joined',
                createdAt,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final bool isLoggedIn = authService.isLoggedIn.value;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30,
                  backgroundImage:
                      _currentUser?.avatarUrl != null &&
                          _currentUser!.avatarUrl!.isNotEmpty
                      ? NetworkImage(_currentUser!.avatarUrl!)
                      : null,
                  child:
                      _currentUser?.avatarUrl == null ||
                          _currentUser!.avatarUrl!.isEmpty
                      ? Icon(
                          Icons.person,
                          size: 30,
                          color: Theme.of(context).primaryColor,
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  isLoggedIn
                      ? 'Welcome, ${_currentUser?.name ?? 'User'}'
                      : 'Guest User',
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
          ..._buildDrawerItems(context, isLoggedIn),
        ],
      ),
    );
  }

  List<Widget> _buildDrawerItems(BuildContext context, bool isLoggedIn) {
    List<Widget> items = [];

    items.add(
      ListTile(
        leading: const Icon(Icons.home),
        title: const Text('Home'),
        onTap: () {
          Navigator.pop(context);
          context.go('/');
        },
      ),
    );
    items.add(
      ListTile(
        leading: const Icon(Icons.settings),
        title: const Text('Settings'),
        onTap: () {
          Navigator.pop(context);
          context.go('/settings');
        },
      ),
    );

    if (isLoggedIn && _currentUser != null) {
      if (_userRole == UserRole.user) {
        items.add(
          ListTile(
            leading: const Icon(Icons.bookmark),
            title: const Text('Saved Posts'),
            onTap: () {
              Navigator.pop(context);
              context.push('/saved');
            },
          ),
        );
      } else if (_userRole == UserRole.admin) {
        items.add(
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Admin Dashboard'),
            onTap: () {
              Navigator.pop(context);
              context.push('/admin_dashboard');
            },
          ),
        );
      } else if (_userRole == UserRole.reporter) {
        items.add(
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Reporter Dashboard'),
            onTap: () {
              Navigator.pop(context);
              context.push('/reporter_dashboard');
            },
          ),
        );
      }

      items.add(const Divider());
      items.add(
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Logout', style: TextStyle(color: Colors.red)),
          onTap: () async {
            Navigator.pop(context);
            await authService.logout();
          },
        ),
      );
    } else {
      items.add(const Divider());
      items.add(
        ListTile(
          leading: const Icon(Icons.login),
          title: const Text('Login'),
          onTap: () {
            Navigator.pop(context);
            context.push('/login');
          },
        ),
      );
      items.add(
        ListTile(
          leading: const Icon(Icons.person_add),
          title: const Text('Register'),
          onTap: () {
            Navigator.pop(context);
            context.push('/register');
          },
        ),
      );
    }

    return items;
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
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 30, width: 1, color: Colors.grey[300]);
  }
}
