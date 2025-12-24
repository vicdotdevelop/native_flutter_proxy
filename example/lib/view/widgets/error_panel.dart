import 'package:flutter/material.dart';

class ErrorPanel extends StatelessWidget {
  const ErrorPanel({super.key, required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE3D2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF2A777)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFC45B3A)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Color(0xFF6D3B1E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
