import 'package:flutter/material.dart';

class InfoPill extends StatelessWidget {
  const InfoPill({
    super.key,
    required this.label,
    required this.value,
    required this.highlight,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final baseColor =
        highlight ? const Color(0xFF1F6F6D) : const Color(0xFF7A6257);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: baseColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w600,
              color: baseColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1A17),
              fontFamily: 'Courier New',
              fontFamilyFallback: [
                'Menlo',
                'Monaco',
                'Courier',
              ],
            ),
          ),
        ],
      ),
    );
  }
}
