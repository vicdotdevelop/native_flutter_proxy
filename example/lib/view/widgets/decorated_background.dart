import 'package:flutter/material.dart';

class DecoratedBackground extends StatelessWidget {
  const DecoratedBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF9F1E8), Color(0xFFEFE1D3)],
        ),
      ),
      child: const Stack(
        children: [
          Positioned(
            right: -60,
            top: -40,
            child: _SoftOrb(color: Color(0xFFF5C48A), size: 180),
          ),
          Positioned(
            left: -40,
            bottom: 40,
            child: _SoftOrb(color: Color(0xFF9FC7B3), size: 160),
          ),
          Positioned(
            right: 20,
            bottom: -60,
            child: _SoftOrb(color: Color(0xFFD8A3A1), size: 200),
          ),
        ],
      ),
    );
  }
}

class _SoftOrb extends StatelessWidget {
  const _SoftOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.22),
        shape: BoxShape.circle,
      ),
    );
  }
}
