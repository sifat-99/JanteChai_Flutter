import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jante_chai/features/auth/login_screen.dart';
import 'package:jante_chai/features/auth/register_screen.dart';
import 'package:jante_chai/features/categories/categories_screen.dart';
import 'package:jante_chai/features/home/home_screen.dart';
import 'package:jante_chai/features/main_shell.dart';
import 'package:jante_chai/features/profile/profile_screen.dart';
import 'package:jante_chai/features/saved/saved_screen.dart';
import 'package:jante_chai/features/welcome/welcome_screen.dart';
import 'package:jante_chai/features/news_details/news_details_screen.dart'; // New import
import 'package:jante_chai/models/article_model.dart'; // New import

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
        ),
        GoRoute(
          path: '/categories',
          builder: (context, state) => const CategoriesScreen(),
        ),
        GoRoute(
          path: '/saved',
          builder: (context, state) => const SavedScreen(),
        ),
        GoRoute(path: '/profile',
            builder: (context, state) => const ProfileScreen()
        ),
        GoRoute(path: '/register'
            ,builder: (context, state) => const RegisterScreen()
        ),

        // New route for news details
        GoRoute(
          path: '/details',
          builder: (context, state) {
            final article = state.extra as Article; // Cast the extra to Article
            return NewsDetailsScreen(article: article);
          },
        ),
        // Add more routes as needed
      ],
    ),
  ],
);
