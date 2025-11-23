import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ThemeOptionWidget extends StatelessWidget {
  final String title;
  final ThemeMode value;
  final ThemeMode groupValue;
  final ValueChanged<ThemeMode?> onChanged;
  final Color backgroundColor;
  final Color textColor;
  final IconData iconData;

  const ThemeOptionWidget({
    Key? key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.backgroundColor,
    required this.textColor,
    required this.iconData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return Animate(
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 500)),
        SlideEffect(begin: Offset(0.2, 0.0), end: Offset.zero),
      ],
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
              width: 2.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Icon(iconData, color: textColor),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              const Spacer(),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                )
            ],
          ),
        ),
      ),
    );
  }
}
