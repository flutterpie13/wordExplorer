import 'package:flutter/material.dart';
import '../domain/entities/card.dart';
import '../domain/usecases/check_card_match.dart';
import '../domain/usecases/difficulty_level.dart';
import 'card_loader_service.dart';

class GameManager {
  final BuildContext context;
  final Function(List<CardModel>) onCardsLoaded;
  final Function() onGameReset;
  final Function(String) showMessage;

  List<CardModel> _cards = [];
  final Set<int> _matchedCards = {};
  final Set<int> _flippedCards = {};
  bool _isInteractionLocked = false;

  GameManager({
    required this.context,
    required this.onCardsLoaded,
    required this.onGameReset,
    required this.showMessage,
  });

  Future<void> loadCards({
    required DifficultyLevel difficultyLevel,
    required String topic,
    required String wordType,
  }) async {
    final cardLoaderService = CardLoaderService();
    final allCards = await cardLoaderService.loadCards();

    final filteredCards = allCards.where((card) {
      final matchesTopic =
          topic == 'all' || card.topic.toLowerCase() == topic.toLowerCase();
      final matchesWordType = wordType == 'all' ||
          card.wordType.toLowerCase() == wordType.toLowerCase();
      return matchesTopic && matchesWordType;
    }).toList();

    if (filteredCards.isEmpty) {
      print('Keine Karten gefunden, die den Filterbedingungen entsprechen.');
      return; // Keine Karten gefunden
    }

    final maxPairs = _getMaxPairs(difficultyLevel.difficulty);
    final selectedCards =
        filteredCards.take(maxPairs * 2).toList(); // 2 Karten pro Paar

    print('Gefilterte Karten: ${filteredCards.length}');
    print('Ausgewählte Karten für das Spiel: ${selectedCards.length}');

    onCardsLoaded(selectedCards);
  }

  int _getMaxPairs(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 4; // 4 Paare
      case Difficulty.medium:
        return 6; // 6 Paare
      case Difficulty.hard:
        return 10; // 10 Paare
    }
  }

  void resetGame({
    required DifficultyLevel difficultyLevel,
    required String topic,
    required String wordType,
  }) {
    _flippedCards.clear();
    _matchedCards.clear();
    _isInteractionLocked = false;

    loadCards(
      difficultyLevel: difficultyLevel,
      topic: topic,
      wordType: wordType,
    );

    onGameReset(); // UI-Reset durchführen
  }

  void checkMatch({
    required CheckCardMatch checkCardMatch,
    required int firstIndex,
    required int secondIndex,
  }) {
    if (_cards.isEmpty ||
        firstIndex >= _cards.length ||
        secondIndex >= _cards.length) {
      print('Ungültige Indizes oder Karten nicht geladen.');
      return; // Beendet die Methode
    }

    final card1 = _cards[firstIndex];
    final card2 = _cards[secondIndex];

    final result = checkCardMatch.execute(card1, card2);

    if (result) {
      _matchedCards.addAll([firstIndex, secondIndex]);
      print('Match gefunden: ${card1.content}, ${card2.content}');

      _flippedCards.clear();
      _isInteractionLocked = false;
      showMessage('Match!');
    } else {
      _isInteractionLocked = true; // Sperre Aktionen während des Verdeckens
      showMessage('No Match!');

      Future.delayed(const Duration(seconds: 1), () {
        _flippedCards.clear(); // Verdecke die Karten
        _isInteractionLocked = false; // Entsperre Aktionen
      });
    }
  }

  bool isInteractionLocked() => _isInteractionLocked;
  Set<int> get matchedCards => _matchedCards;
  Set<int> get flippedCards => _flippedCards;

  void toggleCard(int index) {
    if (_flippedCards.contains(index)) {
      _flippedCards.remove(index);
    } else {
      _flippedCards.add(index);
    }
  }

  void changeDifficulty(
    Difficulty newDifficulty,
    DifficultyLevel currentDifficultyLevel,
    Function(DifficultyLevel) onDifficultyChanged, {
    required String topic,
    required String wordType,
  }) {
    if (currentDifficultyLevel.difficulty != newDifficulty) {
      // Zeige Warnungsdialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Achtung'),
            content: const Text(
              'Wenn Sie den Schwierigkeitsgrad ändern, wird das aktuelle Spiel zurückgesetzt. Möchten Sie fortfahren?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Dialog schließen
                },
                child: const Text('Abbrechen'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Dialog schließen

                  // Anwenden der Änderungen
                  final newLevel = DifficultyLevel(newDifficulty);
                  onDifficultyChanged(newLevel);

                  // Spiel zurücksetzen und neue Karten laden
                  resetGame(
                    difficultyLevel: newLevel,
                    topic: topic,
                    wordType: wordType,
                  );
                },
                child: const Text('Fortfahren'),
              ),
            ],
          );
        },
      );
    }
  }
}
