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
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: authService.currentUser,
        builder: (context, user, _) {
          return BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.category),
                label: 'Categories',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                    ? CircleAvatar(
                        radius: 12, // Diameter 24, matches default icon size
                        backgroundImage: NetworkImage(user.avatarUrl!),
                        onBackgroundImageError: (_, __) {},
                        backgroundColor: Colors.grey.shade300,
                      )
                    : const Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            currentIndex: _calculateSelectedIndex(context),
            onTap: (int index) => _onItemTapped(index, context),
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed, // Ensure consistent layout
          );
        },
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/categories') ||
        location.startsWith('/category-news')) {
      return 1;
    }
    if (location.startsWith('/user_dashboard') ||
        location.startsWith('/reporter_dashboard') ||
        location.startsWith('/admin_dashboard')) {
      return 2;
    }
    if (location.startsWith('/profile') ||
        location.startsWith('/login') ||
        location.startsWith('/role_selection') ||
        location.startsWith('/register')) {
      return 3;
    }
    return 0;
  }

  Future<void> _onItemTapped(int index, BuildContext context) async {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/');
        break;
      case 1:
        GoRouter.of(context).go('/categories');
        break;
      case 2:
        if (authService.isLoading.value) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) =>
                const Center(child: CircularProgressIndicator()),
          );

          // Wait for loading to complete
          await Future.doWhile(() async {
            await Future.delayed(const Duration(milliseconds: 100));
            return authService.isLoading.value;
          });

          if (context.mounted) {
            Navigator.of(context).pop(); // Dismiss dialog
          }
        }

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
