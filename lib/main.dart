import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:word_explorer/presentation/screens/home_screen.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    log('FlutterError: ${details.exceptionAsString()}',
        stackTrace: details.stack);
  };
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); // Key hinzugefügt

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Word Explorer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(), // Hinzufügen von const
    );
  }
}
