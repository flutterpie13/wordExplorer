/*import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:word_explorer/domain/usecases/check_card_match.dart';
import 'package:word_explorer/services/game_manager.dart';
import 'package:word_explorer/domain/usecases/difficulty_level.dart';
import 'package:word_explorer/domain/entities/card.dart';
import 'package:word_explorer/presentation/widgets/flip_card.dart';

class GameScreen1 extends StatefulWidget {
  final int selectedClass;
  final String selectedTopic;
  final String selectedWordType;
  final String selectedDifficulty;

  GameScreen1({
    Key? key,
    required this.selectedClass,
    required this.selectedTopic,
    required this.selectedWordType,
    required this.selectedDifficulty,
  }) : super(key: key);
  @override
  GameScreen1State createState() => GameScreen1State();
}

class GameScreen1State extends State<GameScreen1> {
  DifficultyLevel _difficultyLevel = DifficultyLevel(Difficulty.easy);
  late CheckCardMatch _checkCardMatch;
  final Set<int> _flippedCards = {}; // Bereits aufgedeckte Karten
  final Set<int> _matchedCards = {}; // Gefundene Paare
  bool isInteractionLocked = false;
  List<CardModel> _cards = [];
  late String _selectedTopic;
  late String _selectedWordType;
  late int _selectedClass;
  late String _selectedDifficulty;
  late GameManager _gameManager;

  @override
  void initState() {
    super.initState();

    // Initialisiere die Variablen zuerst
    _selectedClass = widget.selectedClass ?? 5;
    _selectedTopic = widget.selectedTopic ?? 'all';
    _selectedWordType = widget.selectedWordType ?? 'all';
    _selectedDifficulty = widget.selectedDifficulty ?? 'easy';

    // Initialisiere GameManager
    _gameManager = GameManager(
      context: context,
      onCardsLoaded: (loadedCards) {
        if (loadedCards == null || loadedCards.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Keine Karten gefunden')),
          );
          return;
        }

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

    // Initialisiere CardMatch-Logik
    _checkCardMatch = CheckCardMatch(_difficultyLevel);

    // Lade Karten basierend auf den aktuellen Filtern
    try {
      _gameManager.loadCards(
        difficultyLevel: _difficultyLevel,
        topic: _selectedTopic,
        wordType: _selectedWordType,
      );
    } catch (e, stackTrace) {
      log('Fehler beim Laden der Karten: $e', stackTrace: stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Laden der Karten: $e')),
      );
    }
  }

  void _resetGame() {
    setState(() {
      _gameManager.resetGame(
        difficultyLevel: _difficultyLevel,
        topic: _selectedTopic,
        wordType: _selectedWordType,
      );
    });
  }

  void _updateFilters() {
    _gameManager.loadCards(
      difficultyLevel: _difficultyLevel,
      topic: _selectedTopic,
      wordType: _selectedWordType,
    );
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

  void _checkMatch() {
    final flippedCards = _gameManager.flippedCards.toList();

    // Prüfen, ob genügend Karten umgedreht sind
    if (flippedCards.length != 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nicht genügend Karten zum Überprüfen')),
      );
      return;
    }

    // Überprüfen, ob die Indizes innerhalb des gültigen Bereichs liegen
    if (flippedCards.any((index) => index >= _cards.length)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ungültige Kartenindizes')),
      );
      return;
    }

    try {
      _gameManager.checkMatch(
        checkCardMatch: _checkCardMatch,
        firstIndex: flippedCards[0],
        secondIndex: flippedCards[1],
      );
    } catch (e, stackTrace) {
      log('Fehler beim Überprüfen von Matches: $e', stackTrace: stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fehler beim Überprüfen von Matches')),
      );
    }

    setState(() {
      _flippedCards.clear();
    });
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

  /*void _showAdjustDialog() {
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
                  return DropdownMenuItem<String>(
                    value: topic,
                    child: Text(topic),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) _updateTopic(value);
                },
              ),
              DropdownButton<String>(
                value: _selectedWordType,
                items: ['noun', 'verb', 'all'].map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) _updateWordType(value);
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
                  if (value != null) _updateDifficulty(value.toString());
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Anwenden'),
            ),
          ],
        );
      },
    );
  }*/
  Widget _buildScoreboard() {
    final totalPairs = _cards.length ~/ 2;
    final foundPairs = _matchedCards.length ~/ 2;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Gefundene Paare: $foundPairs'),
          Text('Übrige Paare: ${totalPairs - foundPairs}'),
        ],
      ),
    );
  }

  void shuffleCards() {
    _cards.shuffle(); // Zufällige Reihenfolge der Karten
  }

  int _getCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const cardWidth = 80.0; // Breite einer Karte
    return (screenWidth / cardWidth).floor();
  }

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = MediaQuery.of(context).size.width > 600 ? 6 : 4;

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
                            items: ['all', 'school', 'home', 'food', 'animals']
                                .map((topic) {
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
                            items: ['all', 'noun', 'verb', 'adjective']
                                .map((type) {
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
                                child:
                                    Text(difficulty.toString().split('.').last),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                _changeDifficulty(
                                    value); // Hier wird die Methode verwendet
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
            _buildScoreboard(),
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
                          frontContent: card.content.isNotEmpty
                              ? card.content
                              : 'Unbekannt',
                          isFlipped:
                              _gameManager.flippedCards.contains(index) ||
                                  _gameManager.matchedCards.contains(index),
                          onTap: () {
                            if (_gameManager.isInteractionLocked() ||
                                _gameManager.flippedCards.contains(index)) {
                              return; // Keine weitere Aktion erlaubt
                            }

                            try {
                              setState(() {
                                _gameManager.toggleCard(index);
                                if (_gameManager.flippedCards.length == 2) {
                                  _checkMatch();
                                }
                              });
                            } catch (e, stackTrace) {
                              log('Fehler beim Interagieren mit der Karte: $e',
                                  stackTrace: stackTrace);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Fehler bei der Karteninteraktion')),
                              );
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
*/