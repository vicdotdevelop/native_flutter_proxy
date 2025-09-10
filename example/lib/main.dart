// ignore_for_file: unused_local_variable
import 'package:flutter/material.dart';
import 'package:native_flutter_proxy/native_flutter_proxy.dart';

void main() async {
  // Ensure that the WidgetsBinding is initialized before calling the
  // [NativeProxyReader.proxySetting] method.
  WidgetsFlutterBinding.ensureInitialized();

  // Get the proxy settings from the native platform.
  var enabled = false;
  String? host;
  int? port;

  try {
    final settings = await NativeProxyReader.proxySetting;
    NativeProxyReader.setProxyChangedCallback((a) async => debugPrint('Callback for proxy change'));
    enabled = settings.enabled;
    host = settings.host;
    port = settings.port;
  } catch (e) {
    // Using debugPrint instead of print for production code
    debugPrint('Error fetching proxy settings: $e');
  }

  // Enable the proxy if it is enabled and the host is not null.
  if (enabled && host != null) {
    final proxy = CustomProxy(ipAddress: host, port: port).enable();
    debugPrint('proxy enabled');
  }

  runApp(const MyApp());
}

/// The main application widget.
///
/// This widget is the root of the application.
class MyApp extends StatelessWidget {
  /// Creates a new instance of [MyApp].
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

/// A widget that displays the home page of the application.
///
/// This widget is stateful and keeps track of a counter value.
class MyHomePage extends StatefulWidget {
  /// Creates a new instance of [MyHomePage].
  ///
  /// The [title] parameter is required and displayed in the app bar.
  const MyHomePage({required this.title, super.key});

  /// The title displayed in the app bar.
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int counter = 0;

  /// Increments the counter value.
  void _incrementCounter() => setState(() => counter++);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
