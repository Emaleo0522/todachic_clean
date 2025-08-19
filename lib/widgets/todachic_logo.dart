import 'package:flutter/material.dart';

class TODAChicLogo extends StatelessWidget {
  final double fontSize;
  final Color? color;
  final bool showButterflies;
  final bool isLight;

  const TODAChicLogo({
    super.key,
    required this.fontSize,
    this.color,
    this.showButterflies = false,
    this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? Theme.of(context).colorScheme.primary;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showButterflies) ...[
          Icon(
            Icons.flutter_dash, // Podría usar un icono de mariposa si estuviera disponible
            size: fontSize * 0.6,
            color: textColor.withOpacity(0.8),
          ),
          SizedBox(width: fontSize * 0.15),
        ],
        Text(
          'TODA',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: textColor,
            letterSpacing: 1.2,
          ),
        ),
        Text(
          'Chic',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w400, // Un poco más bold
            color: textColor.withOpacity(0.95), // Mejor contraste
            fontStyle: FontStyle.italic,
            letterSpacing: 0.5,
          ),
        ),
        if (showButterflies) ...[
          SizedBox(width: fontSize * 0.15),
          Icon(
            Icons.flutter_dash, // Podría usar un icono de mariposa si estuviera disponible
            size: fontSize * 0.6,
            color: textColor.withOpacity(0.8),
          ),
        ],
      ],
    );
  }
}