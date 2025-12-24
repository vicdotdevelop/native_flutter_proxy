import 'package:flutter/material.dart';

import '../../data/models/proxy_info.dart';
import '../widgets/decorated_background.dart';
import '../widgets/footer_note.dart';
import '../widgets/header_section.dart';
import '../widgets/status_card.dart';

class ProxyScreen extends StatefulWidget {
  const ProxyScreen({super.key, required this.info});

  final ProxyInfo info;

  @override
  State<ProxyScreen> createState() => _ProxyScreenState();
}

class _ProxyScreenState extends State<ProxyScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _headerOpacity;
  late final Animation<double> _cardOpacity;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _footerOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _headerOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    _cardOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.9, curve: Curves.easeOut),
    );
    _footerOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.2, 0.9, curve: Curves.easeOutCubic),
          ),
        );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.info;
    final statusColor = info.applied
        ? const Color(0xFF1F6F6D)
        : const Color(0xFFC45B3A);

    return Scaffold(
      body: Stack(
        children: [
          const DecoratedBackground(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 28,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 56,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FadeTransition(
                              opacity: _headerOpacity,
                              child: HeaderSection(info: info),
                            ),
                            const SizedBox(height: 24),
                            SlideTransition(
                              position: _cardSlide,
                              child: FadeTransition(
                                opacity: _cardOpacity,
                                child: StatusCard(
                                  info: info,
                                  statusColor: statusColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            FadeTransition(
                              opacity: _footerOpacity,
                              child: FooterNote(info: info),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
