import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jante_chai/features/auth/login_screen.dart';
import 'package:jante_chai/features/auth/register_screen.dart';
import 'package:jante_chai/features/categories/categories_screen.dart';
import 'package:jante_chai/features/dashboard/admin_dashboard.dart';
import 'package:jante_chai/features/dashboard/publish_news_screen.dart';
import 'package:jante_chai/features/dashboard/published_news_screen.dart';
import 'package:jante_chai/features/dashboard/reporter_dashboard.dart';
import 'package:jante_chai/features/dashboard/user_dashboard.dart';
import 'package:jante_chai/features/home/home_screen.dart';
import 'package:jante_chai/features/main_shell.dart';
import 'package:jante_chai/features/my_comments/my_comments_screen.dart';
import 'package:jante_chai/features/profile/profile_screen.dart';
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
      builder: (context, state) => const WelcomeScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainShell(child: child);
      },
      routes: [
        GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'details',
                builder: (context, state) {
                  final article = state.extra as Article;
                  return NewsDetailsScreen(article: article);
                },
              ),
            ]),
        GoRoute(
          path: '/categories',
          builder: (context, state) => const CategoriesScreen(),
        ),
        GoRoute(
          path: '/saved',
          builder: (context, state) => const SavedScreen(),
        ),
        GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
        GoRoute(
            path: '/register', builder: (context, state) => const RegisterScreen()),
        GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(
          path: '/admin_dashboard',
          builder: (context, state) => const AdminDashboard(),
        ),
        GoRoute(
          path: '/user_dashboard',
          builder: (context, state) => const UserDashboard(),
        ),
        GoRoute(
          path: '/reporter_dashboard',
          builder: (context, state) => const ReporterDashboard(),
        ),
        GoRoute(
          path: '/publish_news',
          builder: (context, state) => const PublishNewsScreen(),
        ),
        GoRoute(
          path: '/published_news',
          builder: (context, state) => const PublishedNewsScreen(),
        ),
        GoRoute(
          path: '/saved-news',
          builder: (context, state) => const SavedNewsScreen(),
        ),
        GoRoute(
          path: '/my-comments',
          builder: (context, state) => const MyCommentsScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);
