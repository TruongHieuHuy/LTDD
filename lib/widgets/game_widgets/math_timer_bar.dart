import 'package:flutter/material.dart';

/// Math Timer Bar
/// Linear progress bar hiển thị thời gian còn lại
class MathTimerBar extends StatelessWidget {
  final int timeRemaining; // milliseconds
  final int timeLimit; // milliseconds

  const MathTimerBar({
    Key? key,
    required this.timeRemaining,
    required this.timeLimit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = timeRemaining / timeLimit;
    final isUrgent = progress < 0.3;

    return Container(
      height: 12,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          color: isUrgent ? Colors.red : Colors.green,
          minHeight: 12,
        ),
      ),
    );
  }
}
