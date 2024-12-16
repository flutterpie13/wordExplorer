import 'package:flutter/material.dart';
import 'package:word_explorer/domain/usecases/check_card_match.dart';

import 'package:word_explorer/domain/usecases/difficulty_level.dart';
import 'package:word_explorer/presentation/widgets/flip_card.dart';
import 'package:word_explorer/services/card_loader_service.dart';
import '../../services/game_manager.dart';
import '../../services/card_manager.dart';
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
  final Set<int> _flippedCards = {}; // Bereits aufgedeckte Karten
  final Set<int> _matchedCards = {}; // Gefundene Paare
  bool isInteractionLocked = false;
  List<CardModel> _cards = [];
  late CardManager _cardManager;
  late int _selectedClass;
  late String _selectedTopic;
  late String _selectedWordType;
  late String _selectedDifficulty;

  late GameManager _gameManager;

  @override
  void initState() {
    super.initState();
    _gameManager = GameManager(
      context: context,
      onCardsLoaded: (loadedCards) {
        setState(() {
          _cards = loadedCards;
        });
      },
      onGameReset: _resetGame,
      showMessage: (message) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      },
    );

    _gameManager.loadCards(_difficultyLevel);
    _checkCardMatch = CheckCardMatch(_difficultyLevel);
    _gameManager.loadCards(_difficultyLevel);
    _cardManager = CardManager();
    _cardManager.loadCards().then((_) {
      _loadFilteredCards();
    });
    _selectedClass = widget.selectedClass;
    _selectedTopic = widget.selectedTopic;
    _selectedWordType = widget.selectedWordType;
    _selectedDifficulty = widget.selectedDifficulty;
  }

  void _resetGame() {
    setState(() {
      _flippedCards.clear();
      _matchedCards.clear();
      isInteractionLocked = false;
      _gameManager.loadCards(_difficultyLevel);
    });
  }

  void _updateTopic(String newTopic) {
    setState(() {
      _selectedTopic = newTopic;
    });
  }

  void _updateWordType(String newWordType) {
    setState(() {
      _selectedWordType = newWordType;
    });
  }

  void _updateDifficulty(String newDifficulty) {
    setState(() {
      _selectedDifficulty = newDifficulty;
    });
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
        _gameManager.loadCards(newLevel);
      },
    );
  }

  void _loadFilteredCards({
    int classLevel = 5,
    String topic = 'all',
    String wordType = 'all',
  }) {
    setState(() {
      _cards = _cardManager.filterCards(
        classLevel: classLevel,
        topic: topic,
        wordType: wordType,
      );
      _cards.shuffle();
    });
  }

  void _loadCards() async {
    final CardLoaderService cardLoaderService = CardLoaderService();
    final allCards =
        await cardLoaderService.loadCards(); // Keine Parameter übergeben

    setState(() {
      _cards = allCards; // Filterlogik später anwenden
      _cards.shuffle();
    });
  }

  void _checkMatch() {
    if (_flippedCards.length == 2) {
      final firstIndex = _flippedCards.first;
      final secondIndex = _flippedCards.last;

      final card1 = _cards[firstIndex];
      final card2 = _cards[secondIndex];

      final result = _checkCardMatch.execute(card1, card2);
      final message = result ? 'Match!' : 'No Match!';

      if (result) {
        _matchedCards.addAll([firstIndex, secondIndex]);
        _flippedCards.clear();
        isInteractionLocked = false;

        // Zeige die Zeitformen nur ab Schwierigkeitsgrad "Medium"
        if (_difficultyLevel.difficulty != Difficulty.easy) {
          _showTimeFormQuestion(_cards[firstIndex].content);
        }
      } else {
        isInteractionLocked = true;
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  if (!result) {
                    _flippedCards.clear();
                    isInteractionLocked = false;
                  }
                });
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _showTimeFormQuestion(String word) {
    final timeForms = {
      'go': ['went', 'gone'],
      'run': ['ran', 'run (past participle)'],
      'eat': ['ate', 'eaten'],
      // Weitere Wörter hinzufügen
    };

    final forms = timeForms[word] ?? [];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Time Forms for "$word"'),
        content: Text(
          forms.isNotEmpty
              ? 'The other forms of "$word" are: ${forms.join(', ')}'
              : 'No additional forms available for "$word".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showResetWarningDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Fortschritt wird zurückgesetzt'),
          content: const Text(
            'Wenn Sie die Änderungen speichern, wird der aktuelle Spielfortschritt verloren gehen. Möchten Sie fortfahren?',
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
                Navigator.of(context).pop(); // Schließe den Warnungsdialog
                Navigator.of(context).pop(); // Schließe den Anpassungsdialog
                _resetGame(); // Setze das Spiel zurück
              },
              child: const Text('Fortfahren'),
            ),
          ],
        );
      },
    );
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
                items: ['school', 'home', 'food', 'all'].map((topic) {
                  return DropdownMenuItem(
                    value: topic,
                    child: Text(topic),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedTopic = value;
                    });
                  }
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
                  if (value != null) {
                    setState(() {
                      _selectedWordType = value;
                    });
                  }
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
                  if (value != null) {
                    setState(() {
                      _selectedDifficulty = value;
                    });
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
                // Zeige eine Warnung, dass der Fortschritt verloren geht
                _showResetWarningDialog();
              },
              child: const Text('Speichern'),
            ),
          ],
        );
      },
    );
  }

  void _toggleCard(int index) {
    if (_flippedCards.contains(index)) {
      _flippedCards.remove(index);
    } else {
      _flippedCards.add(index);
    }
  }

  void shuffleCards() {
    _cards.shuffle(); // Zufällige Reihenfolge der Karten
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
                Navigator.of(context).pop(); // Zurück zum HomeScreen
              } else if (value == 'adjust') {
                // Öffne Optionen oder zeige einen Dialog zur Anpassung
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
                                ['school', 'home', 'food', 'all'].map((topic) {
                              return DropdownMenuItem(
                                value: topic,
                                child: Text(topic),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                _updateTopic(value); // Aktualisiere den Zustand
                              }
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
                              if (value != null) {
                                _updateWordType(value);
                              }
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
                              if (value != null) {
                                _updateDifficulty(value);
                              }
                            },
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
          if (isInteractionLocked && _flippedCards.length == 2) {
            setState(() {
              _flippedCards.clear(); // Verdecke die Karten
              isInteractionLocked = false; // Entsperre Aktionen
            });
          }
        },
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 3 / 4,
                ),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  final card = _cards[index];
                  return FlipCard(
                    frontContent: card.content,
                    isFlipped: _flippedCards.contains(index) ||
                        _matchedCards.contains(index),
                    onTap: () {
                      if (isInteractionLocked)
                        return; // Blockiere weitere Interaktionen

                      setState(() {
                        if (_flippedCards.contains(index)) {
                          _flippedCards.remove(index);
                        } else {
                          _flippedCards.add(index);
                        }

                        if (_flippedCards.length == 2) {
                          _checkMatch();
                        }
                      });
                    },
                  );
                },
              ),
            ),
            FloatingActionButton(
              onPressed: () {
                _gameManager.resetGame();
              },
              child: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }
}
