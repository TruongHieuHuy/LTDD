import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'screens/translate_screen.dart';
import 'screens/youtube_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/modular_navigation_screen.dart';
import 'screens/login_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/achievements_screen.dart';
import 'screens/simple_home_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/games/guess_number_game_screen.dart';
import 'screens/games/cows_bulls_game_screen.dart';
import 'screens/games/memory_match_game_screen.dart';
import 'screens/games/quick_math_game_screen.dart';
import 'screens/games/leaderboard_screen.dart';
import 'screens/games/achievement_screen.dart';
import 'screens/chatbot_screen.dart';
import 'screens/posts_screen.dart';
import 'screens/search_friends_screen.dart';
import 'screens/friend_requests_screen.dart';
import 'screens/peer_chat_list_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/saved_posts_screen.dart';
import 'screens/create_post_screen.dart';
import 'screens/products_screen.dart';
import 'screens/categories_screen.dart';
import 'utils/database_service.dart';
import 'services/api_service.dart';
import 'services/api_client.dart';
import 'services/post_service.dart';
import 'providers/post_provider.dart';
import 'providers/alarm_provider.dart';
import 'providers/translation_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/game_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/chatbot_provider.dart';
import 'providers/peer_chat_provider.dart';
import 'providers/friend_provider.dart';
import 'providers/group_provider.dart';
import 'config/gaming_theme.dart';
import 'screens/games/sudoku_screen.dart';
import 'screens/games/caro_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Hive database
  await DatabaseService.init();

  runApp(const SmartStudentApp());
}

class SmartStudentApp extends StatelessWidget {
  const SmartStudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Foundational services
        Provider<ApiClient>(create: (_) => ApiClient()),
        Provider<ApiService>(create: (_) => ApiService()),

        // PostService depends on ApiClient
        ProxyProvider<ApiClient, PostService>(
          update: (context, apiClient, _) => PostService(apiClient),
        ),

        // PostProvider depends on PostService
        ChangeNotifierProxyProvider<PostService, PostProvider>(
          create: (context) => PostProvider(context.read<PostService>()),
          update: (context, postService, previous) =>
              previous ?? PostProvider(postService),
        ),

        // Providers that depend on other providers (e.g., AuthProvider depends on ApiService)
        ChangeNotifierProxyProvider<ApiService, AuthProvider>(
          create: (context) =>
              AuthProvider(context.read<ApiService>())..initialize(),
          update: (context, apiService, previousAuthProvider) {
            return previousAuthProvider ?? AuthProvider(apiService)
              ..initialize();
          },
        ),
        


        // Independent providers
        ChangeNotifierProvider(create: (_) => ThemeProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => AlarmProvider()),
        ChangeNotifierProvider(create: (_) => TranslationProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => ChatbotProvider()),
        ChangeNotifierProvider(create: (_) => PeerChatProvider()),
        ChangeNotifierProvider(create: (_) => FriendProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
      ],
      child: Consumer2<ThemeProvider, AuthProvider>(
        builder: (context, themeProvider, authProvider, child) {
          return MaterialApp(
            title: 'MiniGameCenter - Gaming Hub',
            debugShowCheckedModeBanner: false,
            theme: GamingTheme.darkTheme, // Always use Gaming Hub theme
            darkTheme: GamingTheme.darkTheme,
            themeMode: ThemeMode.dark, // Force dark mode for gaming aesthetic
            // Auto-navigate based on login status and role
            initialRoute: _getInitialRoute(authProvider),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/forgot-password': (context) => const ForgotPasswordScreen(),
              '/modular': (context) => const ModularNavigation(),
              '/admin-dashboard': (context) => const AdminDashboardScreen(),
              '/home': (context) =>
                  const SimpleHomeScreen(), // 🎯 Giao diện đơn giản
              '/profile': (context) => const ProfileScreen(),
              '/products': (context) => const ProductsScreen(),
              '/categories': (context) => const CategoriesScreen(),
              '/translate': (context) => const TranslateScreen(),
              '/youtube': (context) => const YouTubeScreen(),
              '/guess_number_game': (context) => const GuessNumberGameScreen(),
              '/cows_bulls_game': (context) => const CowsBullsGameScreen(),
              '/memory_match_game': (context) => const MemoryMatchGameScreen(),
              '/quick_math_game': (context) => const QuickMathGameScreen(),
              '/leaderboard': (context) => const LeaderboardScreen(),
              '/achievements': (context) => const AchievementScreen(),
              '/chatbot': (context) => const ChatbotScreen(),
              '/search-friends': (context) => const SearchFriendsScreen(),
              '/friend-requests': (context) => const FriendRequestsScreen(),
              '/posts': (context) => const PostsScreen(), // Posts feed
              '/peer-chat': (context) => const PeerChatListScreen(),
              '/saved-posts': (context) => const SavedPostsScreen(),
              '/sudoku_game': (context) => const SudokuScreen(),
              '/caro_game': (context) => const CaroScreen(),
            },
            onGenerateRoute: (settings) {
              // Handle user profile route with userId parameter
              if (settings.name == '/user-profile') {
                final userId = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (context) => UserProfileScreen(userId: userId),
                );
              }
              // Handle backend achievements screen with userId
              if (settings.name == '/backend-achievements') {
                final userId = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (context) => AchievementsScreen(userId: userId),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }


  /// Determine initial route based on login status and user role
  String _getInitialRoute(AuthProvider authProvider) {
    if (!authProvider.isLoggedIn) {
      return '/login';
    }

    // Check user role - CRITICAL: Must check role from both sources
    final role = authProvider.userRole;
    debugPrint(
      'Initial route check - Role: $role, isAdmin: ${authProvider.isAdmin}',
    );

    if (role == 'ADMIN' || role == 'MODERATOR') {
      return '/admin-dashboard';
    }

    return '/modular';
  }
}
