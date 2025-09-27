import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class ColorPicker extends StatelessWidget {
  final int selectedColor;
  final Function(int) onColorChanged;

  const ColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          AppTheme.noteColors.length,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => onColorChanged(index),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.noteColors[index],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selectedColor == index
                        ? AppTheme.primaryColor
                        : Colors.grey.shade300,
                    width: selectedColor == index ? 3 : 1,
                  ),
                  boxShadow: [
                    if (selectedColor == index)
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: selectedColor == index
                    ? const Icon(
                        Icons.check,
                        color: AppTheme.primaryColor,
                        size: 18,
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
