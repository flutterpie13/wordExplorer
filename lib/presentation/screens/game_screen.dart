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
  DifficultyLevel _difficultyLevel = DifficultyLevel(Difficulty.easy);
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

    // Initialisiere GameManager
    _gameManager = GameManager(
      context: context,
      onCardsLoaded: (loadedCards) {
        setState(() {
          _cards = loadedCards;
        });
      },
      onGameReset: () => _gameManager.resetGame(
        difficultyLevel: _difficultyLevel,
        topic: _selectedTopic,
        wordType: _selectedWordType,
      ),
      showMessage: (message) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      },
    );

    // Initialisiere CardMatch-Logik
    _checkCardMatch = CheckCardMatch(_difficultyLevel);

    // Lade Karten basierend auf den aktuellen Filtern
    _gameManager.loadCards(
      difficultyLevel: _difficultyLevel,
      topic: _selectedTopic,
      wordType: _selectedWordType,
    );

    // Initialisiere CardManager und lade gefilterte Karten
    _cardManager = CardManager();
    _cardManager.loadCards().then((_) {
      _loadCards();
    });
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
    _gameManager.changeDifficulty(
      difficulty,
      _difficultyLevel,
      (newLevel) {
        setState(() {
          _difficultyLevel = newLevel;
          _checkCardMatch = CheckCardMatch(newLevel);
        });
      },
      topic: _selectedTopic,
      wordType: _selectedWordType,
    );
  }

  /*void _checkMatch() {
    final flippedCards = _gameManager.flippedCards.toList();

    // Prüfen, ob genügend Karten umgedreht sind
    if (flippedCards.isEmpty || flippedCards.length != 2) {
      debugPrint('Nicht genügend Karten zum Überprüfen: $flippedCards');
      return;
    }
    // Sicherstellen, dass die Indizes gültig sind
    final firstIndex = flippedCards[0];
    final secondIndex = flippedCards[1];
    if (firstIndex >= _cards.length || secondIndex >= _cards.length) {
      debugPrint('Ungültige Indizes: $firstIndex, $secondIndex');
      return;
    }

    try {
      final result = _gameManager.checkMatch(
        _cards[firstIndex],
        _cards[secondIndex],
      );

      if (!result) {
        // Verdeckte die Karten, wenn sie kein Match sind
        Future.delayed(const Duration(seconds: 1), () {});
        setState(() {
          _gameManager.toggleCard(firstIndex, forceHide: true);
          _gameManager.toggleCard(secondIndex, forceHide: true);
        });
      }
    } catch (e, stackTrace) {
      log('Fehler beim Überprüfen von Matches: $e', stackTrace: stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fehler beim Überprüfen von Matches')),
      );
    }
  }*/

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
              ElevatedButton(
                onPressed: () {
                  _gameManager.resetGame(
                    difficultyLevel: _difficultyLevel,
                    topic: _selectedTopic,
                    wordType: _selectedWordType,
                  );
                },
                child: const Text('Restart Game'),
              ), // Weitere Optionen hier hinzufügen
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

  int _getCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const cardWidth = 80.0;
    return (screenWidth / cardWidth).floor();
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
            Expanded(
              child: _cards.isEmpty
                  ? const Center(child: Text('Keine Karten verfügbar'))
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _getCrossAxisCount(context),
                        childAspectRatio: 3 / 4,
                      ),
                      itemCount: _cards.length,
                      itemBuilder: (context, index) {
                        final card = _cards[index];
                        return FlipCard(
                          frontContent: card.content,
                          isFlipped:
                              _gameManager.flippedCards.contains(index) ||
                                  _gameManager.matchedCards.contains(index),
                          onTap: () {
                            if (_gameManager.isInteractionLocked() ||
                                _gameManager.flippedCards.contains(index)) {
                              return;
                            }

                            setState(() {
                              _gameManager.onCardTap(card);
                            });
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
}
