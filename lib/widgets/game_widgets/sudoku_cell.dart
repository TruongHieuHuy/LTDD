import 'package:flutter/material.dart';

class SudokuCell extends StatelessWidget {
  final int value;
  final bool isInitial;
  final bool isSelected;
  final bool isMistake;
  final bool isHighlighted;
  final VoidCallback onTap;

  const SudokuCell({
    Key? key,
    required this.value,
    required this.isInitial,
    required this.isSelected,
    required this.isMistake,
    required this.isHighlighted,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.white;
    Color textColor = Colors.black87;
    FontWeight fontWeight = FontWeight.normal;

    if (isSelected) {
      bgColor = Colors.blue.shade100;
    } else if (isMistake) {
      bgColor = Colors.red.shade100;
    } else if (isHighlighted) {
      bgColor = Colors.blue.shade50;
    }

    if (isInitial) {
      textColor = Colors.black;
      fontWeight = FontWeight.bold;
    } else {
      textColor = Colors.blue.shade700;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade400,
            width: isSelected ? 2 : 0.5,
          ),
        ),
        child: Center(
          child: value == 0
              ? const SizedBox()
              : Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: fontWeight,
                    color: textColor,
                  ),
                ),
        ),
      ),
    );
  }
}