import 'package:flutter/material.dart';
import '../../utils/game_utils/game_colors.dart';
import '../../utils/game_utils/meme_texts.dart';

/// Thanh "Độ Kiên Nhẫn" - HP bar cho game với avatar đổi biểu cảm
class PatienceBar extends StatelessWidget {
  final int currentAttempts;
  final int maxAttempts;

  const PatienceBar({
    super.key,
    required this.currentAttempts,
    required this.maxAttempts,
  });

  double get _percentage => 1 - (currentAttempts / maxAttempts);

  String get _emoji {
    if (_percentage > 0.7) return '😊';
    if (_percentage > 0.4) return '😐';
    if (_percentage > 0.2) return '😰';
    if (_percentage > 0.1) return '😡';
    return '💀';
  }

  Color get _barColor {
    if (_percentage > 0.5) return GameColors.successGreen;
    if (_percentage > 0.3) return GameColors.warningOrange;
    return GameColors.trollRed;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GameColors.darkGray.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _barColor.withOpacity(0.5), width: 2),
      ),
      child: Column(
        children: [
          // Avatar với emoji
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_emoji, style: const TextStyle(fontSize: 40)),
              Text(
                'Lượt: $currentAttempts/$maxAttempts',
                style: TextStyle(
                  color: GameColors.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _percentage,
              minHeight: 20,
              backgroundColor: GameColors.darkCharcoal,
              valueColor: AlwaysStoppedAnimation<Color>(_barColor),
            ),
          ),
          const SizedBox(height: 8),

          // Feedback text mặn
          Text(
            MemeTexts.patienceLevel(_percentage),
            style: TextStyle(
              color: _barColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
