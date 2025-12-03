import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/translate_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/modular_navigation_screen.dart';
import 'screens/login_screen.dart';
import 'screens/games/guess_number_game_screen.dart';
import 'screens/games/cows_bulls_game_screen.dart';
import 'screens/games/leaderboard_screen.dart';
import 'screens/games/achievement_screen.dart';
import 'utils/database_service.dart';
import 'providers/alarm_provider.dart';
import 'providers/translation_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/game_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive database
  await DatabaseService.init();

  // Initialize ThemeProvider
  final themeProvider = ThemeProvider();
  await themeProvider.initialize();

  // Initialize AuthProvider
  final authProvider = AuthProvider();
  await authProvider.initialize();

  runApp(SmartStudentApp(
    themeProvider: themeProvider,
    authProvider: authProvider,
  ));
}

class SmartStudentApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  final AuthProvider authProvider;

  const SmartStudentApp({
    super.key,
    required this.themeProvider,
    required this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => AlarmProvider()),
        ChangeNotifierProvider(create: (_) => TranslationProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()..initialize()),
      ],
      child: Consumer2<ThemeProvider, AuthProvider>(
        builder: (context, themeProvider, authProvider, child) {
          return MaterialApp(
            title: 'Smart Student Tools',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            home: authProvider.isLoggedIn 
                ? const ModularNavigation() 
                : const LoginScreen(),
            routes: {
              '/profile': (context) => const ProfileScreen(),
              '/translate': (context) => const TranslateScreen(),
              '/guess_number_game': (context) => const GuessNumberGameScreen(),
              '/cows_bulls_game': (context) => const CowsBullsGameScreen(),
              '/leaderboard': (context) => const LeaderboardScreen(),
              '/achievements': (context) => const AchievementScreen(),
            },
          );
        },
      ),
    );
  }
}
