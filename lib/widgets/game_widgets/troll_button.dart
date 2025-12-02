import 'package:flutter/material.dart';
import 'dart:math';
import '../../utils/game_utils/game_colors.dart';

/// Nút bấm TROLL - Tự động chạy trốn khi gần chạm 🤡
class TrollButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool enableTroll; // Bật/tắt hiệu ứng troll
  final double trollProbability; // Tỷ lệ né (0.0 - 1.0)

  const TrollButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.enableTroll = true,
    this.trollProbability = 0.3,
  });

  @override
  State<TrollButton> createState() => _TrollButtonState();
}

class _TrollButtonState extends State<TrollButton>
    with SingleTickerProviderStateMixin {
  double _offsetX = 0;
  double _offsetY = 0;
  final _random = Random();
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _handlePointerMove(PointerEvent details) {
    if (!widget.enableTroll) return;

    // Random quyết định có né hay không
    if (_random.nextDouble() > widget.trollProbability) return;

    setState(() {
      // Di chuyển ngẫu nhiên trong bán kính 150px
      _offsetX = _random.nextDouble() * 100 - 50;
      _offsetY = _random.nextDouble() * 100 - 50;
    });

    // Rung nhẹ
    _shakeController.forward(from: 0);
  }

  void _handleTap() {
    // Reset vị trí về giữa
    setState(() {
      _offsetX = 0;
      _offsetY = 0;
    });
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      left: MediaQuery.of(context).size.width / 2 - 100 + _offsetX,
      top: _offsetY,
      child: MouseRegion(
        onHover: widget.enableTroll ? _handlePointerMove : null,
        child: AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            final shake = sin(_shakeController.value * pi * 4) * 2;
            return Transform.translate(offset: Offset(shake, 0), child: child);
          },
          child: ElevatedButton(
            onPressed: _handleTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: GameColors.neonPink,
              foregroundColor: GameColors.textWhite,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 8,
              shadowColor: GameColors.neonPink.withOpacity(0.5),
            ),
            child: Text(
              widget.text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
