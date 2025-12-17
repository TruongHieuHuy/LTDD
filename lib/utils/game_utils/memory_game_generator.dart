import 'dart:math';
import '../../models/memory_card_model.dart';
import 'memory_icon_provider.dart';

/// Generator tạo và xáo trộn các thẻ cho Memory Match game
class MemoryGameGenerator {
  static final _random = Random();

  /// Generate shuffled card pairs based on difficulty
  static List<MemoryCard> generateCards(String difficulty) {
    final gridSize = MemoryIconProvider.getGridSize(difficulty);
    final List<MemoryCard> cards = [];

    if (difficulty.toLowerCase() == 'hard') {
      // Hard mode: Use Double Coding (shape + color)
      final hardIcons = MemoryIconProvider.hardIcons;
      final selectedIcons = _selectRandomIcons(hardIcons, gridSize.pairs);

      int cardId = 0;
      for (var iconData in selectedIcons) {
        // Create 2 identical cards (pair)
        cards.add(
          MemoryCard(
            id: cardId++,
            iconData: iconData.shape,
            iconColor: iconData.color,
          ),
        );
        cards.add(
          MemoryCard(
            id: cardId++,
            iconData: iconData.shape,
            iconColor: iconData.color,
          ),
        );
      }
    } else {
      // Easy/Normal mode: Simple icons
      final icons = MemoryIconProvider.getIconsForDifficulty(difficulty);
      final selectedIcons = _selectRandomIcons(icons, gridSize.pairs);

      int cardId = 0;
      for (var iconData in selectedIcons) {
        // Create 2 identical cards (pair)
        cards.add(MemoryCard(id: cardId++, iconData: iconData));
        cards.add(MemoryCard(id: cardId++, iconData: iconData));
      }
    }

    // Shuffle using Fisher-Yates algorithm
    _shuffleCards(cards);

    return cards;
  }

  /// Select random icons from the list
  static List<T> _selectRandomIcons<T>(List<T> icons, int count) {
    final shuffled = List<T>.from(icons);
    shuffled.shuffle(_random);
    return shuffled.take(count).toList();
  }

  /// Shuffle cards using Fisher-Yates algorithm
  static void _shuffleCards(List<MemoryCard> cards) {
    for (int i = cards.length - 1; i > 0; i--) {
      int j = _random.nextInt(i + 1);
      // Swap
      final temp = cards[i];
      cards[i] = cards[j];
      cards[j] = temp;
    }
  }

  /// Get a random unmatched card for hint power-up
  static MemoryCard? getRandomUnmatchedCard(List<MemoryCard> cards) {
    final unmatched = cards.where((card) => !card.isMatched).toList();
    if (unmatched.isEmpty) return null;
    return unmatched[_random.nextInt(unmatched.length)];
  }
}
