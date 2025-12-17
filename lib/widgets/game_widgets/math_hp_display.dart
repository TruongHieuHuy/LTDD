import 'package:flutter/material.dart';

/// Math HP Display
/// Hiển thị 3 trái tim máu
class MathHPDisplay extends StatelessWidget {
  final int currentHP;
  final int maxHP;

  const MathHPDisplay({Key? key, required this.currentHP, this.maxHP = 3})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxHP, (index) {
        final isAlive = index < currentHP;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            isAlive ? Icons.favorite : Icons.favorite_border,
            color: isAlive ? Colors.red : Colors.grey,
            size: 32,
          ),
        );
      }),
    );
  }
}
