import 'package:flutter/material.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedClass = 5; // Standardklasse
  String _selectedTopic = 'school'; // Standardthema
  String _selectedWordType = 'all'; // Standardwortart
  String _selectedDifficulty = 'easy'; // Standardschwierigkeit

  void _navigateToGameScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          selectedClass: _selectedClass,
          selectedTopic: _selectedTopic,
          selectedWordType: _selectedWordType,
          selectedDifficulty: _selectedDifficulty,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Explorer - Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                // Zeige ein Auswahlfenster für Klasse, Thema, Wortart und Schwierigkeit
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Spieloptionen'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButton<int>(
                            value: _selectedClass,
                            items: [5, 6].map((level) {
                              return DropdownMenuItem(
                                value: level,
                                child: Text('Klasse $level'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedClass = value!;
                              });
                            },
                          ),
                          DropdownButton<String>(
                            value: _selectedTopic,
                            items:
                                ['school', 'home', 'food', 'all'].map((topic) {
                              return DropdownMenuItem(
                                value: topic,
                                child: Text(topic),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedTopic = value!;
                              });
                            },
                          ),
                          DropdownButton<String>(
                            value: _selectedWordType,
                            items: ['noun', 'verb', 'all'].map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedWordType = value!;
                              });
                            },
                          ),
                          DropdownButton<String>(
                            value: _selectedDifficulty,
                            items: ['easy', 'medium', 'hard'].map((difficulty) {
                              return DropdownMenuItem(
                                value: difficulty,
                                child: Text(difficulty),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedDifficulty = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Schließe den Dialog
                          },
                          child: const Text('Abbrechen'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Schließe den Dialog
                            _navigateToGameScreen(); // Navigiere zum GameScreen
                          },
                          child: const Text('Starten'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Klasse 5'),
            ),
          ],
        ),
      ),
    );
  }
}
