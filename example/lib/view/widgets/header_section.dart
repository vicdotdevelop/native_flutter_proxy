import 'package:flutter/material.dart';

import '../../data/models/proxy_info.dart';
import 'status_dot.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key, required this.info});

  final ProxyInfo info;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final status = info.applied ? 'ACTIVE' : 'STANDBY';
    final statusColor = info.applied
        ? const Color(0xFF1F6F6D)
        : const Color(0xFFC45B3A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatusDot(color: statusColor),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                status,
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 12,
                  letterSpacing: 1.2,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text('Native proxy monitor', style: textTheme.headlineLarge),
        const SizedBox(height: 10),
        Text(
          'Live readout from the system proxy settings captured at launch.',
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }
}
