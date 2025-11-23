import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jante_chai/services/auth_service.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _calculateSelectedIndex(context),
        onTap: (int index) => _onItemTapped(index, context),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/categories')) {
      return 1;
    }
    if (location.startsWith('/user_dashboard') ||
        location.startsWith('/reporter_dashboard')) {
      return 2;
    }
    if (location.startsWith('/profile')) {
      return 3;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/');
        break;
      case 1:
        GoRouter.of(context).go('/categories');
        break;
      case 2:
        final user = authService.currentUser.value;
        if (user != null) {
          switch (user.role) {
            case UserRole.reporter:
              GoRouter.of(context).go('/reporter_dashboard');
              break;
            case UserRole.admin:
              GoRouter.of(context).go('/admin_dashboard');
              break;
            case UserRole.user:
            default:
              GoRouter.of(context).go('/user_dashboard');
              break;
          }
        } else {
          GoRouter.of(context).go('/login');
        }
        break;
      case 3:
        GoRouter.of(context).go('/profile');
        break;
    }
  }
}
