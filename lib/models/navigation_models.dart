import 'package:flutter/material.dart';

/// Category model for modular navigation system
class NavigationCategory {
  final String id;
  final String name;
  final IconData icon;
  final List<NavigationItem> items;

  NavigationCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.items,
  });
}

/// Navigation item within a category
class NavigationItem {
  final String id;
  final String name;
  final IconData icon;
  final Widget screen;
  final String? route;
  final bool enabled;
  final String? comingSoonMessage;

  NavigationItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.screen,
    this.route,
    this.enabled = true,
    this.comingSoonMessage,
  });
}
