import 'package:flutter/material.dart';

void main() {
  runApp(const ExpoApp());
}

class ExpoApp extends StatelessWidget {
  const ExpoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'ExpoApp',
      home: Scaffold(
        body: Center(
          child: Text('ExpoApp'),
        ),
      ),
    );
  }
}