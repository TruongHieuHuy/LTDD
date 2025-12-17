import 'package:flutter/material.dart';

/// Math Power Up Bar
/// Hiển thị 3 power-ups: Time Freeze, Skip, 50-50
class MathPowerUpBar extends StatelessWidget {
  final int timeFreezeRemaining;
  final int skipRemaining;
  final int fiftyFiftyRemaining;
  final VoidCallback onTimeFreeze;
  final VoidCallback onSkip;
  final VoidCallback onFiftyFifty;
  final bool isDisabled;

  const MathPowerUpBar({
    Key? key,
    required this.timeFreezeRemaining,
    required this.skipRemaining,
    required this.fiftyFiftyRemaining,
    required this.onTimeFreeze,
    required this.onSkip,
    required this.onFiftyFifty,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildPowerUpButton(
          icon: Icons.pause_circle_outline,
          label: '⏸️ Đóng băng',
          remaining: timeFreezeRemaining,
          color: Colors.blue,
          onTap: onTimeFreeze,
        ),
        _buildPowerUpButton(
          icon: Icons.skip_next,
          label: '⏭️ Bỏ qua',
          remaining: skipRemaining,
          color: Colors.orange,
          onTap: onSkip,
        ),
        _buildPowerUpButton(
          icon: Icons.filter_2,
          label: '50-50',
          remaining: fiftyFiftyRemaining,
          color: Colors.purple,
          onTap: onFiftyFifty,
        ),
      ],
    );
  }

  Widget _buildPowerUpButton({
    required IconData icon,
    required String label,
    required int remaining,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isAvailable = remaining > 0 && !isDisabled;

    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: isAvailable ? color : Colors.grey[400],
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: isAvailable ? onTap : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 24),
                  SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 2),
                  Text(
                    'x$remaining',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
