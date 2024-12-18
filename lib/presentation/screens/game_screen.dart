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
      onGameReset: _resetGame,
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

  void _resetGame() {
    setState(() {
      _flippedCards.clear();
      _matchedCards.clear();
      isInteractionLocked = false;
      _gameManager.loadCards(
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

  void _updateTopic(String newTopic) {
    setState(() {
      _selectedTopic = newTopic;
    });
    _gameManager.resetGame(
      difficultyLevel: _difficultyLevel,
      topic: _selectedTopic,
      wordType: _selectedWordType,
    );
  }

  void _updateWordType(String newWordType) {
    setState(() {
      _selectedWordType = newWordType;
    });
    _gameManager.resetGame(
      difficultyLevel: _difficultyLevel,
      topic: _selectedTopic,
      wordType: _selectedWordType,
    );
  }

  void _updateDifficulty(String newDifficulty) {
    setState(() {
      _selectedDifficulty = newDifficulty;
    });
    _gameManager.resetGame(
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

        // Lade Karten basierend auf den aktuellen Filtern
        _gameManager.loadCards(
          difficultyLevel: _difficultyLevel,
          topic: _selectedTopic,
          wordType: _selectedWordType,
        );
      },
      _selectedTopic, // Aktuelles Thema übergeben
      _selectedWordType, // Aktuelle Wortart übergeben
    );
  }

  void _loadCards({
    int? classLevel,
    String? topic,
    String? wordType,
  }) async {
    final CardLoaderService cardLoaderService = CardLoaderService();
    final allCards = await cardLoaderService.loadCards();

    setState(() {
      _cards = allCards.where((card) {
        final matchesClass =
            classLevel == null || card.classLevel == classLevel;
        final matchesTopic =
            topic == null || topic == 'all' || card.topic == topic;
        final matchesWordType =
            wordType == null || wordType == 'all' || card.wordType == wordType;

        return matchesClass && matchesTopic && matchesWordType;
      }).toList();
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
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
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
          ],
        ),
      ),
    );
  }
}
