import 'package:flutter/material.dart';
import '../../domain/usecases/get_game_options.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GameOptions _gameOptions;

  @override
  void initState() {
    super.initState();
    _gameOptions = GetGameOptions().getDefaultOptions();
  }

  void _navigateToGameScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          selectedClass: _gameOptions.selectedClass,
          selectedTopic: _gameOptions.selectedTopic,
          selectedWordType: _gameOptions.selectedWordType,
          selectedDifficulty: _gameOptions.selectedDifficulty,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Word Explorer - Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await _showGameOptionsDialog();
              },
              child: const Text('Spiel starten'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showGameOptionsDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Spieloptionen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<int>(
                value: _gameOptions.selectedClass,
                items: [5, 6].map((level) {
                  return DropdownMenuItem(
                      value: level, child: Text('Klasse $level'));
                }).toList(),
                onChanged: (value) => setState(() => _gameOptions =
                    _gameOptions.copyWith(selectedClass: value!)),
              ),
              DropdownButton<String>(
                value: _gameOptions.selectedTopic,
                items: ['school', 'home', 'food', 'all'].map((topic) {
                  return DropdownMenuItem(value: topic, child: Text(topic));
                }).toList(),
                onChanged: (value) => setState(() => _gameOptions =
                    _gameOptions.copyWith(selectedTopic: value!)),
              ),
              DropdownButton<String>(
                value: _gameOptions.selectedWordType,
                items: ['noun', 'verb', 'all'].map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) => setState(() => _gameOptions =
                    _gameOptions.copyWith(selectedWordType: value!)),
              ),
              DropdownButton<String>(
                value: _gameOptions.selectedDifficulty,
                items: ['easy', 'medium', 'hard'].map((difficulty) {
                  return DropdownMenuItem(
                      value: difficulty, child: Text(difficulty));
                }).toList(),
                onChanged: (value) => setState(() => _gameOptions =
                    _gameOptions.copyWith(selectedDifficulty: value!)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToGameScreen();
              },
              child: const Text('Starten'),
            ),
          ],
        );
      },
    );
  }
}
