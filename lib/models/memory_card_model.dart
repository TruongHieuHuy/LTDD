import 'package:flutter/material.dart';

/// Model đại diện cho 1 thẻ trong game Memory Match
class MemoryCard {
  final int id;
  final IconData iconData;
  final Color? iconColor; // For Hard mode (Double Coding)
  bool isFlipped;
  bool isMatched;
  bool showHintGlow;

  MemoryCard({
    required this.id,
    required this.iconData,
    this.iconColor,
    this.isFlipped = false,
    this.isMatched = false,
    this.showHintGlow = false,
  });

  /// Create copy with modified properties
  MemoryCard copyWith({
    int? id,
    IconData? iconData,
    Color? iconColor,
    bool? isFlipped,
    bool? isMatched,
    bool? showHintGlow,
  }) {
    return MemoryCard(
      id: id ?? this.id,
      iconData: iconData ?? this.iconData,
      iconColor: iconColor ?? this.iconColor,
      isFlipped: isFlipped ?? this.isFlipped,
      isMatched: isMatched ?? this.isMatched,
      showHintGlow: showHintGlow ?? this.showHintGlow,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MemoryCard &&
        other.iconData == iconData &&
        other.iconColor == iconColor;
  }

  @override
  int get hashCode => iconData.hashCode ^ (iconColor?.hashCode ?? 0);

  @override
  String toString() =>
      'MemoryCard(id: $id, flipped: $isFlipped, matched: $isMatched)';
}
