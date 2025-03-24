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
    enabled = settings.enabled;
    host = settings.host;
    port = settings.port;
  } catch (e) {
    print(e);
  }

  // Enable the proxy if it is enabled and the host is not null.
  if (enabled && host != null) {
    final proxy = CustomProxy(ipAddress: host, port: port).enable();
    debugPrint('proxy enabled');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int counter = 0;

  void _incrementCounter() => setState(() => counter++);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('You have pushed the button this many times:'),
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
        child: Icon(Icons.add),
      ),
    );
  }
}
