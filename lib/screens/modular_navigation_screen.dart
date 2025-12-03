import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/navigation_config.dart';
import '../models/navigation_models.dart';
import '../providers/theme_provider.dart';

/// Modern modular navigation with category system
class ModularNavigation extends StatefulWidget {
  const ModularNavigation({super.key});

  @override
  State<ModularNavigation> createState() => _ModularNavigationState();
}

class _ModularNavigationState extends State<ModularNavigation> {
  late List<NavigationCategory> _categories;
  late NavigationItem _currentItem;

  @override
  void initState() {
    super.initState();
    _categories = NavigationConfig.getCategories();
    _currentItem = NavigationConfig.getDefaultItem()!;
  }

  void _onItemSelected(NavigationItem item) {
    if (!item.enabled) {
      _showComingSoonDialog(item.comingSoonMessage ?? 'Tính năng đang phát triển');
      return;
    }
    setState(() {
      _currentItem = item;
    });
  }

  void _showComingSoonDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sắp ra mắt'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      body: Row(
        children: [
          // Side navigation rail
          NavigationRail(
            selectedIndex: _getCategoryIndex(),
            onDestinationSelected: (index) {
              final category = _categories[index];
              if (category.items.isNotEmpty) {
                _onItemSelected(category.items[0]);
              }
            },
            extended: MediaQuery.of(context).size.width > 800,
            backgroundColor: isDarkMode ? const Color(0xFF1B263B) : const Color(0xFFF5F5F5),
            selectedIconTheme: IconThemeData(
              color: themeProvider.primaryColor,
              size: 28,
            ),
            unselectedIconTheme: IconThemeData(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              size: 24,
            ),
            selectedLabelTextStyle: TextStyle(
              color: themeProvider.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            unselectedLabelTextStyle: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              fontSize: 12,
            ),
            destinations: _categories.map((category) {
              return NavigationRailDestination(
                icon: Icon(category.icon),
                label: Text(category.name),
              );
            }).toList(),
          ),

          // Vertical divider
          VerticalDivider(
            thickness: 1,
            width: 1,
            color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
          ),

          // Main content area
          Expanded(
            child: Column(
              children: [
                // Secondary horizontal navigation for items within category
                _buildSecondaryNav(isDarkMode, themeProvider),

                // Screen content
                Expanded(child: _currentItem.screen),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getCategoryIndex() {
    for (int i = 0; i < _categories.length; i++) {
      if (_categories[i].items.any((item) => item.id == _currentItem.id)) {
        return i;
      }
    }
    return 0;
  }

  NavigationCategory _getCurrentCategory() {
    final index = _getCategoryIndex();
    return _categories[index];
  }

  Widget _buildSecondaryNav(bool isDarkMode, ThemeProvider themeProvider) {
    final currentCategory = _getCurrentCategory();

    // If category has only one item, don't show secondary nav
    if (currentCategory.items.length <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0D1B2A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: currentCategory.items.length,
        itemBuilder: (context, index) {
          final item = currentCategory.items[index];
          final isSelected = item.id == _currentItem.id;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => _onItemSelected(item),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? themeProvider.primaryColor.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(
                          color: themeProvider.primaryColor,
                          width: 2,
                        )
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      color: isSelected
                          ? themeProvider.primaryColor
                          : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.name,
                      style: TextStyle(
                        color: isSelected
                            ? themeProvider.primaryColor
                            : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
