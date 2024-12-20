import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:word_explorer/domain/usecases/check_card_match.dart';
import 'package:word_explorer/domain/usecases/difficulty_level.dart';
import 'package:word_explorer/presentation/widgets/flip_card.dart';
import '../../services/card_manager.dart';
import '../../services/game_manager.dart';
import '../../domain/entities/card.dart';

class GameScreen extends StatefulWidget {
  final int selectedClass;
  final String selectedTopic;
  final String selectedWordType;
  final String selectedDifficulty;

  GameScreen({
    required this.selectedClass,
    required this.selectedTopic,
    required this.selectedWordType,
    required this.selectedDifficulty,
  });

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late DifficultyLevel _difficultyLevel;
  late CheckCardMatch _checkCardMatch;
  late GameManager _gameManager;
  late CardManager _cardManager;

  List<CardModel> _cards = [];
  bool _isInteractionLocked = false;

  late String _selectedTopic;
  late String _selectedWordType;
  late int _selectedClass;
  late String _selectedDifficulty;

  @override
  void initState() {
    super.initState();

    // Initialisiere die Variablen zuerst
    _selectedClass = widget.selectedClass;
    _selectedTopic = widget.selectedTopic;
    _selectedWordType = widget.selectedWordType;
    _selectedDifficulty = widget.selectedDifficulty;

    // Initialisiere Schwierigkeitsgrad
    _difficultyLevel = DifficultyLevel(Difficulty.values.firstWhere(
        (d) => d.toString().split('.').last == _selectedDifficulty,
        orElse: () => Difficulty.easy));

    // Initialisiere GameManager
    _gameManager = GameManager(
      context: context,
      onCardsLoaded: (loadedCards) {
        setState(() {
          _cards = loadedCards;
        });
      },
      onGameReset: () => _resetGame(),
      showInfo: (message) => _gameManager.showMessage(message),
    );

    // Initialisiere CardMatch-Logik
    _checkCardMatch = CheckCardMatch(_difficultyLevel);

    // Lade Karten basierend auf den aktuellen Filtern
    _loadCards();
  }

  Future<void> _loadCards() async {
    try {
      await _gameManager.loadCards(
        difficultyLevel: _difficultyLevel,
        topic: _selectedTopic,
        wordType: _selectedWordType,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fehler beim Laden der Karten')),
      );
    }
  }

  void _showMassage(String message) {
    _gameManager.showMessage(message);
  }

  void _resetGame() {
    setState(() {
      _isInteractionLocked = false;
      _gameManager.resetGame(
        difficultyLevel: _difficultyLevel,
        topic: _selectedTopic,
        wordType: _selectedWordType,
      );
    });
  }

  void _updateFilters() {
    _loadCards();
  }

  void _changeDifficulty(Difficulty difficulty) {
    setState(() {
      _difficultyLevel =
          DifficultyLevel(difficulty); // Aktualisiere Schwierigkeitsgrad
      _checkCardMatch = CheckCardMatch(_difficultyLevel); // Aktualisiere Logik
    });

    // Spiel mit neuem Schwierigkeitsgrad neu starten
    _resetGame();
  }

  int _getCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const cardWidth = 80.0;
    return (screenWidth / cardWidth).floor();
  }

  void _showAdjustDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Spiel anpassen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: _selectedTopic,
                items:
                    ['all', 'school', 'home', 'food', 'animals'].map((topic) {
                  return DropdownMenuItem<String>(
                    value: topic,
                    child: Text(topic),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedTopic = value;
                    });
                    _updateFilters(); // Karten mit neuem Thema laden
                  }
                },
              ),
              DropdownButton<String>(
                value: _selectedWordType,
                items: ['all', 'noun', 'verb', 'adjective'].map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedWordType = value;
                    });
                    _updateFilters(); // Karten mit neuer Wortart laden
                  }
                },
              ),
              DropdownButton<Difficulty>(
                value: _difficultyLevel.difficulty,
                items: Difficulty.values.map((difficulty) {
                  return DropdownMenuItem<Difficulty>(
                    value: difficulty,
                    child: Text(difficulty.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _changeDifficulty(value); // Hier wird die Methode verwendet
                  }
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
                // Optionale Logik hier hinzufügen
              },
              child: const Text('Speichern'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Explorer'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'exit') {
                Navigator.of(context).pop();
              } else if (value == 'adjust') {
                _showAdjustDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'exit',
                child: Text('Spiel verlassen'),
              ),
              const PopupMenuItem(
                value: 'adjust',
                child: Text('Spiel anpassen'),
              ),
            ],
          )
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // Überprüfe, ob zwei Karten offen sind
          if (_gameManager.isInteractionLocked() &&
              _gameManager.flippedCards.length == 2) {
            setState(() {
              _gameManager.flippedCards.clear(); // Verdecke die Karten
              _isInteractionLocked = false; // Entsperre Aktionen
            });
          }
        },
        child: Column(
          children: [
            if (_gameManager.isGameOver()) // Anzeige bei Spielende
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Spiel beendet! Drücke "Restart", um erneut zu spielen.',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(
              child: _cards.isEmpty
                  ? const Center(child: Text('Keine Karten verfügbar'))
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _getCrossAxisCount(context),
                        childAspectRatio: 3 / 4,
                      ),
                      cacheExtent: 100.0,
                      itemCount: _cards.length,
                      itemBuilder: (context, index) {
                        final card = _cards[index];
                        return FlipCard(
                          frontContent: card.content,
                          isFlipped:
                              _gameManager.flippedCards.contains(index) ||
                                  _gameManager.matchedCards.contains(index),
                          onTap: () {
                            if (!_gameManager.isInteractionLocked()) {
                              // Interaktionssperre überprüfen
                              setState(() {
                                _gameManager.onCardTap(card);
                              });
                            }
                          },
                        );
                      },
                    ),
            ),
            FloatingActionButton(
              onPressed: () {
                _gameManager.resetGame(
                  difficultyLevel: _difficultyLevel,
                  topic: _selectedTopic,
                  wordType: _selectedWordType,
                );
              },
              child: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Gewonnen!'),
          content: const Text(
              'Herzlichen Glückwunsch, du hast alle Paare gefunden!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dialog schließen
                _resetGame(); // Spiel neu starten
              },
              child: const Text('Nochmal spielen'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dialog schließen
                Navigator.of(context).pop(); // Zurück ins Hauptmenü
              },
              child: const Text('Zum Hauptmenü'),
            ),
          ],
        );
      },
    );
  }
}
