import 'dart:io';
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
import 'screens/settings_screen.dart';
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
import 'providers/challenge_provider.dart';
import 'services/socket_service.dart';
import 'config/gaming_theme.dart';
import 'screens/games/sudoku_screen.dart';
import 'screens/games/caro_screen.dart';
import 'screens/games/puzzle_screen.dart';
import 'screens/games/rubik_cube_game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Hive database
  await DatabaseService.init();
  debugPrint('DatabaseService initialized');

  // Initialize core services
  final apiService = ApiService();
  final socketService = SocketService();

  // Initialize AuthProvider BEFORE runApp to ensure session data is loaded
  final authProvider = AuthProvider(apiService);
  await authProvider.initialize();
  debugPrint('AuthProvider initialized, isLoggedIn=${authProvider.isLoggedIn}');

  debugPrint('Starting app');
  runApp(
    SmartStudentApp(
      apiService: apiService,
      socketService: socketService,
      authProvider: authProvider,
    ),
  );
}

class SmartStudentApp extends StatelessWidget {
  final ApiService apiService;
  final SocketService socketService;
  final AuthProvider authProvider;

  const SmartStudentApp({
    super.key,
    required this.apiService,
    required this.socketService,
    required this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide pre-initialized services
        Provider<ApiService>.value(value: apiService),
        Provider<SocketService>.value(value: socketService),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),

        // Other foundational services
        Provider<ApiClient>(create: (_) => ApiClient()),

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

        // ChallengeProvider depends on ApiService and SocketService
        ChangeNotifierProxyProvider2<
          ApiService,
          SocketService,
          ChallengeProvider
        >(
          create: (context) => ChallengeProvider(
            context.read<ApiService>(),
            context.read<SocketService>(),
          ),
          update: (context, apiService, socketService, previous) =>
              previous ?? ChallengeProvider(apiService, socketService),
        ),

        // Independent providers
        ChangeNotifierProvider(create: (_) {
          debugPrint('Creating ThemeProvider');
          final provider = ThemeProvider();
          provider.initialize();
          debugPrint('ThemeProvider created');
          return provider;
        }),
        ChangeNotifierProvider(create: (_) {
          debugPrint('Creating AlarmProvider');
          return AlarmProvider();
        }),
        ChangeNotifierProvider(create: (_) {
          debugPrint('Creating TranslationProvider');
          return TranslationProvider();
        }),
        ChangeNotifierProvider(create: (_) {
          debugPrint('Creating SettingsProvider');
          return SettingsProvider();
        }),
        ChangeNotifierProvider(create: (_) {
          debugPrint('Creating GameProvider');
          final provider = GameProvider();
          provider.initialize();
          debugPrint('GameProvider created');
          return provider;
        }),
        ChangeNotifierProvider(create: (_) {
          debugPrint('Creating ChatbotProvider');
          return ChatbotProvider();
        }),
        ChangeNotifierProvider(create: (_) {
          debugPrint('Creating PeerChatProvider');
          return PeerChatProvider();
        }),
        ChangeNotifierProvider(create: (_) {
          debugPrint('Creating FriendProvider');
          return FriendProvider();
        }),
        ChangeNotifierProvider(create: (_) {
          debugPrint('Creating GroupProvider');
          return GroupProvider();
        }),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'MiniGameCenter - Gaming Hub',
            debugShowCheckedModeBanner: false,
            theme: GamingTheme.darkTheme,
            darkTheme: GamingTheme.darkTheme,
            themeMode: ThemeMode.dark,
            initialRoute: _getInitialRoute(authProvider),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/forgot-password': (context) => const ForgotPasswordScreen(),
              '/modular': (context) => const ModularNavigation(),
              '/admin-dashboard': (context) => const AdminDashboardScreen(),
              '/home': (context) => const SimpleHomeScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/settings': (context) => SettingsScreen(),
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
              '/posts': (context) => const PostsScreen(),
              '/peer-chat': (context) => const PeerChatListScreen(),
              '/saved-posts': (context) => const SavedPostsScreen(),
              '/sudoku_game': (context) => const SudokuScreen(),
              '/caro_game': (context) => const CaroScreen(),
              '/puzzle_game': (context) => const PuzzleScreen(),
              '/rubik_cube_game': (context) => const RubikCubeGameScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/user-profile') {
                final userId = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (context) => UserProfileScreen(userId: userId),
                );
              }
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
    // Check login status
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
