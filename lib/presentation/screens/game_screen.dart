import 'package:flutter/material.dart';

import '../../data/repositories/card_repository_impl.dart';

import '../../data/models/card_pair_model.dart';
import '../widgets/animated_card.dart';

class GameScreen extends StatefulWidget {
  final int selectedClass;
  final String selectedTopic;
  final String selectedWordType;
  final String selectedDifficulty;

  const GameScreen({
    Key? key,
    required this.selectedClass,
    required this.selectedTopic,
    required this.selectedWordType,
    required this.selectedDifficulty,
  }) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // late Future<List<CardPairModel>> _filteredCards;
  List<bool> _cardFlipped = [];
  List<int> _selectedCards = [];
  List<CardPairModel> _cards = [];
  List<bool> _flippedCards = [];
  Set<int> _matchedCards = {};
  int _score = 0;
  bool _showInputField = false; // Für mittlere Schwierigkeitsstufe
  final TextEditingController _inputController = TextEditingController();
  String _inputPrompt = '';
  bool _isInteractionLocked = false;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  void _loadCards() async {
    print("Loading cards...");
    final repository = CardRepository();
    final cards = await repository.fetchFilteredCardPairs(
      classLevel: widget.selectedClass,
      topic: widget.selectedTopic,
    );

    setState(() {
      print("Cards loaded: ${cards.length}");
      _cards = cards..shuffle();
      _flippedCards = List.generate(_cards.length, (_) => false);
    });
  }

  void _onCardTap(int index) {
    if (_isInteractionLocked ||
        _flippedCards[index] ||
        _matchedCards.contains(index)) {
      return;
    }

    setState(() {
      _flippedCards[index] = true;
    });

    final flippedIndexes = _flippedCards
        .asMap()
        .entries
        .where((entry) => entry.value && !_matchedCards.contains(entry.key))
        .map((entry) => entry.key)
        .toList();

    if (flippedIndexes.length == 2) {
      _checkMatch(flippedIndexes[0], flippedIndexes[1]);
    }
  }

  Future<void> _checkMatch(int index1, int index2) async {
    final card1 = _cards[index1];
    final card2 = _cards[index2];

    final isMatch = card1.pairId == card2.pairId;

    setState(() {
      _isInteractionLocked = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      if (isMatch) {
        _score += 10;
        _matchedCards.addAll([index1, index2]);
      } else {
        _flippedCards[index1] = false;
        _flippedCards[index2] = false;
      }
      _isInteractionLocked = false;
    });
  }

  void _showPronouncePrompt(String term) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Aussprache üben'),
          content:
              Text('Bitte sprich das Wort "$term" laut aus und übersetze es.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fertig'),
            ),
          ],
        );
      },
    );
  }

  void _promptForInput() {
    final firstCard = _cards[_selectedCards[0]];

    setState(() {
      _showInputField = true;

      // Überprüfen, ob die Karte ein Begriff (term) mit Wortart verb ist
      if (firstCard.term.isNotEmpty && firstCard.wordType == 'verb') {
        _inputPrompt = 'Enter the past tense of "${firstCard.term}"';
      } else if (firstCard.term.isNotEmpty) {
        _inputPrompt =
            'This card is a "${firstCard.wordType}". No input needed.';
      } else {
        _inputPrompt = 'This is a scene card. No input required.';
      }
    });
  }

  void _checkInput() {
    final firstCard = _cards[_selectedCards[0]];
    final secondCard = _cards[_selectedCards[1]];

    // Erwarte die Eingabe der Vergangenheitsform des Begriffs
    final expectedInput =
        firstCard.wordType == 'verb' && firstCard.term == 'run' ? 'ran' : '';

    // Prüfen, ob die Karten ein Paar sind und die Eingabe korrekt ist
    final isMatch = firstCard.pairId == secondCard.pairId &&
        _inputController.text.trim().toLowerCase() == expectedInput;

    setState(() {
      if (isMatch) {
        _score += 20; // Punkte für richtige Paarung und Eingabe
        _matchedCards.addAll([_selectedCards[0], _selectedCards[1]]);
        _showInputField = false; // Eingabefeld schließen
      } else {
        _resetSelectedCards(); // Karten zurücksetzen
      }
      _selectedCards.clear(); // Auswahl zurücksetzen
      _inputController.clear(); // Eingabe löschen
    });
  }

  void _resetSelectedCards() {
    for (final index in _selectedCards) {
      _cardFlipped[index] = false;
    }
    setState(() {
      _showInputField = false;
      _selectedCards.clear();
    });
  }

  late List<CardPairModel> _filteredCardsList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Score: $_score'),
      ),
      body: _cards.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _buildGameGrid(),
    );
  }

  Widget _buildInputPrompt() {
    return AlertDialog(
      title: Text(_inputPrompt),
      content: TextField(
        controller: _inputController,
        decoration: const InputDecoration(labelText: 'Your Answer'),
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _resetSelectedCards();
            });
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _checkInput();
            });
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }

  void _initializeGameState(int length) {
    setState(() {
      _cardFlipped = List.generate(length, (_) => false);
      _matchedCards.clear();
      _selectedCards.clear();
    });
  }

  Widget _buildGameGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: _filteredCardsList.length,
      itemBuilder: (context, index) {
        final card = _filteredCardsList[index];
        return AnimatedCard(
          isFlipped: _cardFlipped[index],
          onTap: () => _onCardTap(index),
          front: _buildCardFront(card),
          back: _buildCardBack(),
        );
      },
    );
  }

  Widget _buildCardFront(CardPairModel card) {
    return Card(
      child: Center(
        child: Text(
          card.term.isNotEmpty ? card.term : card.scene,
          style: card.term.isNotEmpty
              ? const TextStyle(fontSize: 16)
              : const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
        ),
      ),
    );
  }

  Widget _buildCardBack() {
    return const Card(
      color: Colors.blue,
      child: Center(
        child: Icon(Icons.help, size: 36, color: Colors.white),
      ),
    );
  }
}

/*
import 'package:flutter/material.dart';

import '../../data/repositories/card_repository_impl.dart';

import '../../data/models/card_pair_model.dart';
import '../widgets/animated_card.dart';

class GameScreen extends StatefulWidget {
  final int selectedClass;
  final String selectedTopic;
  final String selectedWordType;
  final String selectedDifficulty;

  const GameScreen({
    Key? key,
    required this.selectedClass,
    required this.selectedTopic,
    required this.selectedWordType,
    required this.selectedDifficulty,
  }) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Future<List<CardPairModel>> _filteredCards;
  List<bool> _cardFlipped = [];
  List<int> _selectedCards = [];
  List<CardPairModel> _cards = [];
  List<bool> _flippedCards = [];
  Set<int> _matchedCards = {};
  int _score = 0;
  bool _showInputField = false; // Für mittlere Schwierigkeitsstufe
  final TextEditingController _inputController = TextEditingController();
  String _inputPrompt = '';
  bool _isInteractionLocked = false;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  void _loadCards() async {
    final repository = CardRepository();
    final cards = await repository.fetchFilteredCardPairs(
      classLevel: widget.selectedClass,
      topic: widget.selectedTopic,
    );

    setState(() {
      _cards = cards..shuffle();
      _flippedCards = List.generate(_cards.length, (_) => false);
    });
  }

  void _onCardTap(int index) {
    if (_flippedCards[index] || _matchedCards.contains(index)) {
      return;
    }

    setState(() {
      _flippedCards[index] = true;
    });

    final flippedIndexes = _flippedCards
        .asMap()
        .entries
        .where((entry) => entry.value && !_matchedCards.contains(entry.key))
        .map((entry) => entry.key)
        .toList();

    if (flippedIndexes.length == 2) {
      _checkMatch(flippedIndexes[0], flippedIndexes[1]);
    }
  }

  void _checkMatch(int index1, int index2) async {
    final card1 = _cards[index1];
    final card2 = _cards[index2];

    // Prüfen, ob die Karten ein Paar sind
    final isMatch = card1.pairId == card2.pairId;

    await Future.delayed(
        const Duration(seconds: 1)); // Verzögerung für Animation

    setState(() {
      if (isMatch) {
        _score += 10;
        _matchedCards.addAll([index1, index2]); // Paar markieren
      } else {
        _flippedCards[index1] = false; // Karten zurückdrehen
        _flippedCards[index2] = false;
      }
      _selectedCards.clear(); // Zurücksetzen der Auswahl
    });
  }

  void _showPronouncePrompt(String term) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Aussprache üben'),
          content:
              Text('Bitte sprich das Wort "$term" laut aus und übersetze es.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fertig'),
            ),
          ],
        );
      },
    );
  }

  void _promptForInput() {
    final firstCard = _filteredCardsList[_selectedCards[0]];
    setState(() {
      _showInputField = true;

      // Passe die Aufforderung basierend auf dem Kartentyp an
      if (firstCard.type == CardType.term) {
        _inputPrompt = 'Enter the past tense of "${firstCard.content}"';
      } else {
        _inputPrompt = 'This card is not a term card.';
      }
    });
  }

  void _checkInput() {
    final firstCard = _cards[_selectedCards[0]];
    final secondCard = _cards[_selectedCards[1]];

    // Überprüfen, ob die Karten ein Paar sind und ob die Eingabe korrekt ist
    if (_inputController.text.trim().toLowerCase() == 'ran' &&
        firstCard.term == 'run' &&
        secondCard.scene == 'A child runs in the park.') {
      setState(() {
        _score += 20;
        _matchedCards.addAll([_selectedCards[0], _selectedCards[1]]);
        _showInputField = false;
        _selectedCards.clear();
      });
    } else {
      _resetSelectedCards();
    }

    _inputController.clear();
  }

  void _resetSelectedCards() {
    for (final index in _selectedCards) {
      _cardFlipped[index] = false;
    }
    setState(() {
      _showInputField = false;
      _selectedCards.clear();
    });
  }

  late List<CardPairModel> _filteredCardsList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Score: $_score'),
      ),
      body: FutureBuilder<List<CardPairModel>>(
        future: _filteredCards,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No cards found for this selection.'));
          }
          _filteredCardsList = snapshot.data!;
          _initializeGameState(_filteredCardsList.length);
          return _buildGameGrid();
        },
      ),
    );
  }

  Widget _buildInputPrompt() {
    return AlertDialog(
      title: Text(_inputPrompt),
      content: TextField(
        controller: _inputController,
        decoration: const InputDecoration(labelText: 'Your Answer'),
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _resetSelectedCards();
            });
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _checkInput();
            });
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }

  void _initializeGameState(int length) {
    setState(() {
      _cardFlipped = List.generate(length, (_) => false);
      _matchedCards.clear();
      _selectedCards.clear();
    });
  }

  Widget _buildGameGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: _filteredCardsList.length,
      itemBuilder: (context, index) {
        final card = _filteredCardsList[index];
        return AnimatedCard(
          isFlipped: _cardFlipped[index],
          onTap: () => _onCardTap(index),
          front: _buildCardFront(card),
          back: _buildCardBack(),
        );
      },
    );
  }

  Widget _buildCardFront(CardPairModel card) {
    return Card(
      child: Center(
        child: card.type == CardType.term
            ? Text(card.content, style: const TextStyle(fontSize: 16))
            : Text(card.content,
                style:
                    const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
      ),
    );
  }

  Widget _buildCardBack() {
    return const Card(
      color: Colors.blue,
      child: Center(
        child: Icon(Icons.help, size: 36, color: Colors.white),
      ),
    );
  }
}
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
}*/
