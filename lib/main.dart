import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// The main application entry point widget.
class MyApp extends StatelessWidget {
  /// Creates a new [MyApp] instance.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'RadioApp',
      home: Scaffold(body: Center(child: Text('RadioApp Shell'))),
    );
  }
}
