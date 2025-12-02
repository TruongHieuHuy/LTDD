import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import 'screens/translate_screen.dart';
import 'screens/alarm_screen.dart';
import 'screens/group_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'utils/database_service.dart';
import 'providers/alarm_provider.dart';
import 'providers/translation_provider.dart';
import 'providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        ChangeNotifierProvider(create: (_) => AlarmProvider()),
        ChangeNotifierProvider(create: (_) => TranslationProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: 'Smart Student Tools',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme(
                brightness: Brightness.light,
                primary: const Color(0xFF2196F3), // Xanh lạnh
                onPrimary: Colors.white,
                secondary: const Color(0xFF00BCD4), // Xanh ngọc
                onSecondary: Colors.white,
                error: const Color(0xFFB71C1C),
                onError: Colors.white,
                surface: const Color(0xFFB3E5FC), // Bề mặt xanh mát
                onSurface: Colors.black,
              ),
              scaffoldBackgroundColor: const Color(0xFFE3F2FD),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF2196F3),
                foregroundColor: Colors.white,
                elevation: 2,
                titleTextStyle: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.1,
                ),
              ),
              textTheme: const TextTheme(
                headlineMedium: TextStyle(
                  color: Color(0xFF1565C0),
                  fontWeight: FontWeight.bold,
                ),
                titleMedium: TextStyle(
                  color: Color(0xFF1976D2),
                  fontWeight: FontWeight.w600,
                ),
                bodyMedium: TextStyle(color: Color(0xFF263238)),
              ),
              fontFamily: 'Roboto',
            ),
            home: const MainNavigation(),
            routes: {
              '/profile': (context) => const ProfileScreen(),
              '/translate': (context) => const TranslateScreen(),
            },
          );
        },
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const TranslateScreen(),
    const AlarmScreen(),
    const GroupScreen(),
    const ProfileScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFB3E5FC),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black.withValues(alpha: 0.08),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: GNav(
            gap: 4,
            activeColor: const Color(0xFF2196F3),
            color: const Color(0xFF607D8B),
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            tabBackgroundColor: const Color(0xFF2196F3).withValues(alpha: 0.12),
            tabs: const [
              GButton(icon: Icons.translate, text: 'Dịch'),
              GButton(icon: Icons.alarm, text: 'Báo thức'),
              GButton(icon: Icons.group, text: 'Nhóm'),
              GButton(icon: Icons.person, text: 'Cá nhân'),
              GButton(icon: Icons.settings, text: 'Cài đặt'),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
