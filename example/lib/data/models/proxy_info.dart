class ProxyInfo {
  const ProxyInfo({
    required this.enabled,
    required this.applied,
    this.host,
    this.port,
    this.error,
  });

  final bool enabled;
  final bool applied;
  final String? host;
  final int? port;
  final String? error;

  bool get hasError => error != null && error!.isNotEmpty;

  String get hostLabel => host ?? 'Not detected';

  String get portLabel => port?.toString() ?? 'Auto';

  String get statusTitle {
    if (applied) {
      return 'Proxy enabled';
    }
    if (enabled) {
      return 'Proxy needs attention';
    }
    return 'Proxy disabled';
  }

  String get statusSubtitle {
    if (hasError) {
      return 'Unable to read the system proxy. Check permissions or try again.';
    }
    if (applied) {
      return 'Traffic is routed through your system proxy configuration.';
    }
    if (enabled) {
      return 'The system proxy is on, but the host is missing or invalid.';
    }
    return 'No proxy detected in system settings.';
  }

  String get appliedLabel => applied ? 'Applied' : 'Not applied';
}
