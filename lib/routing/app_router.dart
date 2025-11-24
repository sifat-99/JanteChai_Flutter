import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jante_chai/features/auth/login_screen.dart';
import 'package:jante_chai/features/auth/register_screen.dart';
import 'package:jante_chai/features/categories/categories_screen.dart';
import 'package:jante_chai/features/categories/category_news_screen.dart';
import 'package:jante_chai/features/dashboard/admin_dashboard.dart';
import 'package:jante_chai/features/dashboard/manage_news/edit_news_screen.dart';
import 'package:jante_chai/features/dashboard/manage_news/manage_news_screen.dart';
import 'package:jante_chai/features/dashboard/manage_reporters/manage_reporters_screen.dart';
import 'package:jante_chai/features/dashboard/manage_users/manage_users_screen.dart';
import 'package:jante_chai/features/dashboard/publish_news_screen.dart';
import 'package:jante_chai/features/dashboard/published_news_screen.dart';
import 'package:jante_chai/features/dashboard/reporter_dashboard.dart';
import 'package:jante_chai/features/dashboard/user_dashboard.dart';
import 'package:jante_chai/features/home/home_screen.dart';
import 'package:jante_chai/features/main_shell.dart';
import 'package:jante_chai/features/my_comments/my_comments_screen.dart';
import 'package:jante_chai/features/profile/profile_screen.dart';
import 'package:jante_chai/features/profile/edit_profile_screen.dart';
import 'package:jante_chai/features/saved/saved_screen.dart';
import 'package:jante_chai/features/saved_news/saved_news_screen.dart';
import 'package:jante_chai/features/settings/settings_screen.dart';
import 'package:jante_chai/features/welcome/welcome_screen.dart';
import 'package:jante_chai/features/news_details/news_details_screen.dart';
import 'package:jante_chai/models/article_model.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/welcome',
  routes: [
    GoRoute(
      path: '/welcome',
      pageBuilder: (context, state) => _buildPageWithDefaultTransition(
        context: context,
        state: state,
        child: const WelcomeScreen(),
      ),
    ),
    GoRoute(
      path: '/edit-profile',
      pageBuilder: (context, state) => _buildPageWithDefaultTransition(
        context: context,
        state: state,
        child: const EditProfileScreen(),
      ),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => _buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const HomeScreen(),
          ),
          routes: [
            GoRoute(
              path: 'details',
              pageBuilder: (context, state) {
                final article = state.extra as Article;
                return _buildPageWithDefaultTransition(
                  context: context,
                  state: state,
                  child: NewsDetailsScreen(article: article),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/categories',
          pageBuilder: (context, state) => _buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const CategoriesScreen(),
          ),
        ),
        GoRoute(
          path: '/saved',
          pageBuilder: (context, state) => _buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const SavedScreen(),
          ),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => _buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const ProfileScreen(),
          ),
        ),
        GoRoute(
          path: '/register',
          pageBuilder: (context, state) => _buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const RegisterScreen(),
          ),
        ),
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) => _buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const LoginScreen(),
          ),
        ),
        GoRoute(
          path: '/admin_dashboard',
          pageBuilder: (context, state) => _buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const AdminDashboard(),
          ),
        ),
        GoRoute(
          path: '/user_dashboard',
          pageBuilder: (context, state) => _buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const UserDashboard(),
          ),
        ),
        GoRoute(
          path: '/reporter_dashboard',
          pageBuilder: (context, state) => _buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const ReporterDashboard(),
          ),
        ),
        GoRoute(
          path: '/publish_news',
          pageBuilder: (context, state) => _buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const PublishNewsScreen(),
          ),
        ),
        GoRoute(
          path: '/published_news',
          pageBuilder: (context, state) => _buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const PublishedNewsScreen(),
          ),
        ),
        GoRoute(
          path: '/saved-news',
          pageBuilder: (context, state) => _buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const SavedNewsScreen(),
          ),
        ),
        GoRoute(
          path: '/my-comments',
          pageBuilder: (context, state) => _buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const MyCommentsScreen(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => _buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const SettingsScreen(),
          ),
        ),
        GoRoute(
          path: '/manage-news',
          pageBuilder: (context, state) => _buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const ManageNewsScreen(),
          ),
        ),
        GoRoute(
          path: '/manage-users',
          pageBuilder: (context, state) => _buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const ManageUsersScreen(),
          ),
        ),
        GoRoute(
          path: '/manage-reporters',
          pageBuilder: (context, state) => _buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: const ManageReportersScreen(),
          ),
        ),
        GoRoute(
          path: '/edit-news',
          pageBuilder: (context, state) {
            final article = state.extra as Article;
            return _buildPageWithDefaultTransition(
              context: context,
              state: state,
              child: EditNewsScreen(article: article),
            );
          },
        ),
        GoRoute(
          path: '/category-news',
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            final categoryName = extra['categoryName'] as String;
            final articles = extra['articles'] as List<Article>;
            return _buildPageWithDefaultTransition(
              context: context,
              state: state,
              child: CategoryNewsScreen(
                categoryName: categoryName,
                articles: articles,
              ),
            );
          },
        ),
      ],
    ),
  ],
);

CustomTransitionPage _buildPageWithDefaultTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: FadeTransition(opacity: animation, child: child),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}
