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
    final repository = CardRepository();
    final cards = await repository.fetchFilteredCardPairs(
      classLevel: widget.selectedClass,
      topic: widget.selectedTopic,
    );

    setState(() {
      _cards = cards..shuffle();
      _flippedCards = List.generate(_cards.length, (_) => false);
      _initializeGameState(_cards.length);
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
