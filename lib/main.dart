import 'package:flutter/material.dart';
import 'package:word_explorer/presentation/screens/home_screen.dart';

void main() {
  runApp(WordExplorerApp());
}

class WordExplorerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Word Explorer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}
