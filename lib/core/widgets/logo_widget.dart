import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LogoWidget extends StatelessWidget {
  final double fontSize;
  final Color color;
  final String subtitle;
  final bool isCompact;

  const LogoWidget({
    super.key,
    this.fontSize = 42,
    this.color = Colors.black,
    this.subtitle = '',
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.task_outlined, size: 30, color: Colors.black),
          const SizedBox(width: 8),
          Text(
            'Taskly',
            style: GoogleFonts.mulish(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        Icon(Icons.task_outlined, size: 80, color: Colors.orange),
        Text(
          'Taskly',
          style: GoogleFonts.mulish(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: const TextStyle(fontSize: 20),
          ),
        const SizedBox(height: 40),
      ],
    );
  }
}
