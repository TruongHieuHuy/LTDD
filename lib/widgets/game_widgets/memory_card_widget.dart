import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/memory_card_model.dart';

/// Widget hiển thị 1 thẻ trong Memory Match game
/// Có animation lật 3D perspective
class MemoryCardWidget extends StatefulWidget {
  final MemoryCard card;
  final VoidCallback onTap;
  final bool isDisabled;

  const MemoryCardWidget({
    Key? key,
    required this.card,
    required this.onTap,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  State<MemoryCardWidget> createState() => _MemoryCardWidgetState();
}

class _MemoryCardWidgetState extends State<MemoryCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _flipAnimation = Tween<double>(
      begin: 0,
      end: pi,
    ).animate(CurvedAnimation(parent: _flipController, curve: Curves.easeOut));

    // Set initial animation state
    if (widget.card.isFlipped) {
      _flipController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(MemoryCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Force sync animation with card state
    // Since card is mutated in-place, we need to check current state
    if (widget.card.isFlipped && _flipController.value < 0.5) {
      _flipController.forward();
    } else if (!widget.card.isFlipped && _flipController.value > 0.5) {
      _flipController.reverse();
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: widget.isDisabled ? null : widget.onTap,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final angle = _flipAnimation.value;
          final isFront = angle > pi / 2;

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective
              ..rotateY(angle),
            alignment: Alignment.center,
            child: isFront
                ? Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: _buildCardFront(theme),
                  )
                : _buildCardBack(theme),
          );
        },
      ),
    );
  }

  /// Build card back (hidden state)
  Widget _buildCardBack(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Center(
        child: Text(
          '?',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  /// Build card front (revealed state)
  Widget _buildCardFront(ThemeData theme) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: widget.card.isMatched
            ? Colors.green.withOpacity(0.2)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.card.showHintGlow
              ? Colors.amber
              : widget.card.isMatched
              ? Colors.green
              : theme.primaryColor,
          width: widget.card.showHintGlow ? 4 : 3,
        ),
        boxShadow: widget.card.showHintGlow
            ? [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
      ),
      child: Center(
        child: Icon(
          widget.card.iconData,
          size: 48,
          color: widget.card.iconColor ?? theme.primaryColor,
        ),
      ),
    );
  }
}
