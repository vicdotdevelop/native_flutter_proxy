import 'package:flutter/material.dart';

import '../../data/models/proxy_info.dart';

class FooterNote extends StatelessWidget {
  const FooterNote({super.key, required this.info});

  final ProxyInfo info;

  @override
  Widget build(BuildContext context) {
    final footerText = info.hasError
        ? 'NativeProxyReader returned an error. Check the logs for details.'
        : 'Powered by NativeProxyReader and applied to the app at launch.';

    return Text(footerText, style: Theme.of(context).textTheme.bodyMedium);
  }
}
