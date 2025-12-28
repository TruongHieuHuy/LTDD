import 'package:flutter/material.dart';
import '../config/navigation_config.dart';
import '../models/navigation_models.dart';
import '../config/gaming_theme.dart';

/// Modern bottom navigation - Mobile UX optimized
class ModularNavigation extends StatefulWidget {
  const ModularNavigation({super.key});

  @override
  State<ModularNavigation> createState() => _ModularNavigationState();
}

class _ModularNavigationState extends State<ModularNavigation> {
  int _selectedCategoryIndex = 0;
  late List<NavigationCategory> _categories;

  @override
  void initState() {
    super.initState();
    _categories = NavigationConfig.getCategories();
  }

  void _onCategoryTapped(int index) {
    final category = _categories[index];

    // If category has multiple items, show bottom sheet menu
    if (category.items.length > 1) {
      _showCategoryMenu(context, category);
    } else {
      // Single item - navigate directly
      setState(() {
        _selectedCategoryIndex = index;
      });
    }
  }

  void _showCategoryMenu(BuildContext context, NavigationCategory category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: GamingTheme.surfaceDark,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                category.name,
                style: GamingTheme.h2.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 20),
              // Menu items with constrained height
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: category.items
                        .map(
                          (item) => _buildMenuItem(context, item),
                        )
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    NavigationItem item,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => item.screen),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: GamingTheme.surfaceLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0891B2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  color: const Color(0xFF0891B2),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: GamingTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: GamingTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  NavigationCategory get _currentCategory =>
      _categories[_selectedCategoryIndex];

  @override
  Widget build(BuildContext context) {

    // Get first item screen from current category
    final currentScreen = _currentCategory.items.isNotEmpty
        ? _currentCategory.items[0].screen
        : const Center(child: Text('No content'));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // Khi nhấn back ở trang chính - hiển thị dialog xác nhận thoát
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Thoát ứng dụng'),
            content: const Text('Bạn có muốn thoát khỏi ứng dụng?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Thoát'),
              ),
            ],
          ),
        );

        if (shouldExit == true && context.mounted) {
          // Thoát app bằng cách đăng xuất và về login
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      },
      child: Scaffold(
        backgroundColor: GamingTheme.primaryDark,
        body: currentScreen,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: GamingTheme.cardShadow,
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedCategoryIndex,
            onTap: _onCategoryTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: GamingTheme.primaryAccent,
            unselectedItemColor: GamingTheme.textSecondary,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            elevation: 8,
            backgroundColor: GamingTheme.surfaceDark,
            items: _categories.map((category) {
              return BottomNavigationBarItem(
                icon: Icon(category.icon),
                label: category.name,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
