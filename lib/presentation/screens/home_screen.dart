import 'package:flutter/material.dart';
import 'package:word_explorer/presentation/screens/game_screen.dart';
import 'dart:developer';
import '../../domain/usecases/difficulty_level.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedClass = 5;
  String _selectedTopic = 'all';
  String _selectedWordType = 'all';
  Difficulty _selectedDifficulty = Difficulty.easy;

  final List<int> _classOptions = [5, 6];
  final List<String> _topicOptions = [
    'all',
    'school',
    'home',
    'food',
    'animals'
  ];
  final List<String> _wordTypeOptions = ['all', 'noun', 'verb', 'adjective'];
  final List<Difficulty> _difficultyOptions = Difficulty.values;

  void _startGame() {
    if (_selectedTopic.isEmpty || _selectedWordType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte alle Optionen auswählen!')),
      );
      return;
    }

    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameScreen(
            selectedClass: _selectedClass,
            selectedTopic: _selectedTopic,
            selectedWordType: _selectedWordType,
            selectedDifficulty: _selectedDifficulty.toString().split('.').last,
          ),
        ),
      );
    } catch (e, stackTrace) {
      // Fehler protokollieren
      log('Fehler beim Navigieren zum GameScreen: $e', stackTrace: stackTrace);

      // Benutzer informieren
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fehler beim Starten des Spiels.')),
      );
    }
  }

  Widget buildDropdown<T>({
    required String label,
    required T value,
    required List<T> options,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        DropdownButton<T>(
          value: value,
          items: options.map((option) {
            return DropdownMenuItem<T>(
              value: option,
              child: Text(option.toString().split('.').last),
            );
          }).toList(),
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Explorer - Startseite'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildDropdown<int>(
              label: 'Wähle die Klasse:',
              value: _selectedClass,
              options: _classOptions,
              onChanged: (value) {
                setState(() {
                  _selectedClass = value!;
                });
              },
            ),
            buildDropdown<String>(
              label: 'Wähle das Thema:',
              value: _selectedTopic,
              options: _topicOptions,
              onChanged: (value) {
                setState(() {
                  _selectedTopic = value!;
                });
              },
            ),
            buildDropdown<String>(
              label: 'Wähle die Wortart:',
              value: _selectedWordType,
              options: _wordTypeOptions,
              onChanged: (value) {
                setState(() {
                  _selectedWordType = value!;
                });
              },
            ),
            buildDropdown<Difficulty>(
              label: 'Wähle den Schwierigkeitsgrad:',
              value: _selectedDifficulty,
              options: _difficultyOptions,
              onChanged: (value) {
                setState(() {
                  _selectedDifficulty = value!;
                });
              },
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _startGame,
                child: const Text('Spiel Starten'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
