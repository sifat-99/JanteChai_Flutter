# Jante Chai

**Jante Chai** is a modern newspaper application built with Flutter, designed to deliver news efficiently with a focus on user experience and authentication. It features a clean interface, personalized news browsing, and robust user management with different roles.

## Table of Contents
- [Features](#features)
- [Project Structure](#project-structure)
- [Authentication Flow](#authentication-flow)
- [API Keys Setup](#api-keys-setup)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Running the Project](#running-the-project)

## Features

*   **Top Headlines**: Browse the latest news headlines from various sources (currently focused on Bangladesh news).
*   **Categories**: Explore news articles categorized by different topics (Politics, Business & Finance, Technology, Health, etc.).
*   **News Details**: View full article details including description, source, and an option to read the complete article on the web. Users can also add comments to articles.
*   **User Authentication**: Secure login and registration with backend integration.
*   **Role-Based Access**: Supports different user roles (User, Reporter, Admin) with corresponding functionalities on the profile screen and drawer navigation.
*   **User Profile**: View and potentially edit user profiles. Displays basic user information, with placeholder sections for posts, followers, and following.
*   **Welcome Screen**: An engaging introductory screen with a Lottie animation.
*   **Bottom Navigation**: Easy navigation between Home, Categories, Saved (placeholder), and Profile screens.
*   **Pull-to-Refresh**: Refresh news feeds with a simple pull gesture on the home screen.
*   **Responsive UI**: Built with Flutter for a consistent experience across different devices.

## Project Structure

The project follows a modular structure to ensure maintainability and scalability:

```
jante_chai/
├── lib/
│   ├── features/              # Contains individual feature modules (e.g., auth, home, profile)
│   │   ├── auth/              # Login, Register screens and related logic
│   │   ├── categories/        # Categories screen
│   │   ├── home/              # Home screen displaying news
│   │   ├── main_shell.dart    # Main app shell with bottom navigation
│   │   ├── news_details/      # News details screen
│   │   ├── profile/           # User profile screen
│   │   ├── saved/             # Saved articles screen (placeholder)
│   │   └── welcome/           # Welcome/Onboarding screen
│   ├── models/                # Data models (e.g., Article, User)
│   ├── routing/               # GoRouter configuration for navigation
│   ├── services/              # API services (e.g., AuthService, NewsApiService, ApiService)
│   ├── widgets/               # Reusable UI widgets (e.g., ArticleCard)
│   └── main.dart              # Main application entry point
├── assets/
│   └── lottie/                # Lottie animation files
├── .env                       # Environment variables (e.g., API keys)
├── pubspec.yaml               # Project dependencies and metadata
└── README.md                  # Project documentation
```

## Authentication Flow

The application implements a robust authentication system through the `AuthService`:

1.  **Registration**: Users can create new accounts via the `RegisterScreen`. The `AuthService.register` method sends user credentials to the backend API (`https://jante-chaii.vercel.app/api/users/register`).
2.  **Login**: Existing users can log in via the `LoginScreen`. The `AuthService.login` method authenticates users against the backend API (`https://jante-chaii.vercel.app/api/users/login`). Upon successful login, a JWT (JSON Web Token) is received.
3.  **Session Management**: The JWT is decoded using `jwt_decoder` and relevant user information (ID, name, email, role) is extracted and stored in `SharedPreferences` for persistent sessions.
4.  **User State**: The `AuthService` uses `ValueNotifier`s (`isLoggedIn`, `currentUser`) to notify the UI about authentication status and current user details, allowing for dynamic UI updates (e.g., showing login/logout buttons, role-specific content).
5.  **Logout**: Users can log out, which clears the stored authentication token and user data from `SharedPreferences`, effectively ending the session.
6.  **Role-Based Features**: The `UserRole` enum (`user`, `reporter`, `admin`, `unknown`) is used to manage different access levels and tailor the profile screen and drawer navigation based on the logged-in user's role.

## API Keys Setup

This project uses an API key for fetching news data.

1.  **NewsData.io API Key**:
    *   Obtain a free API key from [NewsData.io](https://newsdata.io/).
    *   Create a file named `.env` in the root directory of your project (e.g., `/Users/sifat/StudioProjects/jante_chai/.env`).
    *   Add your API key to this file in the following format:
        ```
        NEWSAPI=your_newsdata_io_api_key_here
        ```
    *   The `NewsApiService` reads this key to fetch news.

2.  **Backend API Base URL**:
    *   The backend API base URL is configured in `lib/services/api_service.dart`:
        ```dart
        static const String _baseUrl = 'https://jante-chaii.vercel.app/api';
        ```
    *   If you are running your own backend, update this URL accordingly.

## Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

*   Flutter SDK installed ([Installation Guide](https://flutter.dev/docs/get-started/install))
*   Dart SDK (comes with Flutter)
*   An IDE like Android Studio or VS Code with Flutter and Dart plugins.

### Installation

1.  Clone the repository:
    ```bash
    git clone https://github.com/your_username/jante_chai.git
    cd jante_chai
    ```
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  Set up your API keys as described in the [API Keys Setup](#api-keys-setup) section.

### Running the Project

1.  Connect a device or start an emulator.
2.  Run the app:
    ```bash
    flutter run
    ```

For help getting started with Flutter development, view the [online documentation](https://docs.flutter.dev/), which offers tutorials, samples, guidance on mobile development, and a full API reference.
