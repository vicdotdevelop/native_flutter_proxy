import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'data/models/proxy_info.dart';
import 'view/screens/proxy_screen.dart';

export 'data/models/proxy_info.dart';

class App extends StatelessWidget {
  const App({super.key, required this.proxyInfoListenable});

  final ValueListenable<ProxyInfo> proxyInfoListenable;

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFFC45B3A);
    const onSurface = Color(0xFF201A17);

    final textTheme = ThemeData.light().textTheme.copyWith(
      headlineLarge: const TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.6,
        color: onSurface,
      ),
      headlineMedium: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: onSurface,
      ),
      titleMedium: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: onSurface,
      ),
      bodyLarge: const TextStyle(fontSize: 16, height: 1.5, color: onSurface),
      bodyMedium: const TextStyle(
        fontSize: 14,
        height: 1.45,
        color: Color(0xFF5A4A42),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Native Proxy',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
        fontFamily: 'Georgia',
        fontFamilyFallback: const [
          'Baskerville',
          'Times New Roman',
          'Noto Serif',
        ],
        scaffoldBackgroundColor: const Color(0xFFF7EFE6),
        textTheme: textTheme,
      ),
      home: ValueListenableBuilder<ProxyInfo>(
        valueListenable: proxyInfoListenable,
        builder: (context, info, _) {
          return ProxyScreen(info: info);
        },
      ),
    );
  }
}
