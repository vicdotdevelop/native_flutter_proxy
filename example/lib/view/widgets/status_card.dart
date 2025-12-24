import 'package:flutter/material.dart';

import '../../data/models/proxy_info.dart';
import 'error_panel.dart';
import 'info_pill.dart';
import 'status_dot.dart';

class StatusCard extends StatelessWidget {
  const StatusCard({
    super.key,
    required this.info,
    required this.statusColor,
  });

  final ProxyInfo info;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF6).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2A2018).withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              StatusDot(color: statusColor, size: 14),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  info.statusTitle,
                  style: textTheme.headlineMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(info.statusSubtitle, style: textTheme.bodyLarge),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              InfoPill(
                label: 'Host',
                value: info.hostLabel,
                highlight: info.host != null,
              ),
              InfoPill(
                label: 'Port',
                value: info.portLabel,
                highlight: info.port != null,
              ),
              InfoPill(
                label: 'App routing',
                value: info.appliedLabel,
                highlight: info.applied,
              ),
            ],
          ),
          if (info.hasError) ...[
            const SizedBox(height: 18),
            ErrorPanel(error: info.error ?? 'Unknown error'),
          ],
        ],
      ),
    );
  }
}
