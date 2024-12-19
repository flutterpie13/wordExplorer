import 'dart:developer';
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
    try {
      final cardLoaderService = CardLoaderService();
      final allCards = await cardLoaderService.loadCards();

      if (allCards.isEmpty) {
        log('Keine Karten verfügbar');
        showMessage('Keine Karten gefunden');
        return;
      }

      // Filterkarten basierend auf Thema und Wortart
      final filteredCards = allCards.where((card) {
        final matchesTopic =
            topic == 'all' || card.topic.toLowerCase() == topic.toLowerCase();
        final matchesWordType = wordType == 'all' ||
            card.wordType.toLowerCase() == wordType.toLowerCase();
        return matchesTopic && matchesWordType;
      }).toList();

      if (filteredCards.isEmpty) {
        log('Keine Karten gefunden, die den Filterbedingungen entsprechen.');
        showMessage('Keine passenden Karten gefunden. Standardkarten geladen.');
        _cards = allCards
            .take(_getMaxPairs(difficultyLevel.difficulty) * 2)
            .toList();
      } else {
        final maxPairs = _getMaxPairs(difficultyLevel.difficulty);
        _cards = filteredCards.take(maxPairs * 2).toList();
      }

      onCardsLoaded(_cards);
    } catch (e, stackTrace) {
      log('Fehler beim Laden der Karten: $e', stackTrace: stackTrace);
      showMessage('Fehler beim Laden der Karten');
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
    shuffleCards();

    onGameReset();
  }

  bool checkMatch({
    required CheckCardMatch checkCardMatch,
    required int firstIndex,
    required int secondIndex,
  }) {
    if (!_validateIndices(firstIndex, secondIndex)) {
      return false;
    }

    final card1 = _cards[firstIndex];
    final card2 = _cards[secondIndex];
    final result = checkCardMatch.execute(card1, card2);

    if (!result && flippedCards.length == 2) {
      _isInteractionLocked = true;
      showMessage('No Match!');
      Future.delayed(const Duration(seconds: 1), () {
        toggleCard(firstIndex, forceHide: true);
        toggleCard(secondIndex, forceHide: true);

        _isInteractionLocked = false;
      });
    } else {
      _matchedCards.addAll([firstIndex, secondIndex]);
      _flippedCards.clear();
      showMessage('Match!');
      _isInteractionLocked = false;
    }

    return result;
  }

  bool _validateIndices(int firstIndex, int secondIndex) {
    final valid = firstIndex < _cards.length && secondIndex < _cards.length;
    if (!valid) {
      log('Ungültige Indizes: $firstIndex, $secondIndex');
      showMessage('Ungültige Kartenindizes');
    }
    return valid;
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

  bool isInteractionLocked() => _isInteractionLocked;
  Set<int> get matchedCards => _matchedCards;
  Set<int> get flippedCards => _flippedCards;

  void toggleCard(int index, {bool forceHide = false}) {
    if (forceHide) {
      _flippedCards.remove(index); // Karte verdecken
    } else if (_flippedCards.contains(index)) {
      return; // Karte zuklappen
    } else if (_flippedCards.length < 2) {
      _flippedCards.add(index); // Karte aufdecken
    }
  }

  void shuffleCards() {
    _cards.shuffle(); // Zufällige Reihenfolge der Karten
  }

  void changeDifficulty(
    Difficulty newDifficulty,
    DifficultyLevel currentDifficultyLevel,
    Function(DifficultyLevel) onDifficultyChanged, {
    required String topic,
    required String wordType,
  }) {
    if (currentDifficultyLevel.difficulty != newDifficulty) {
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
                  Navigator.of(context).pop();
                },
                child: const Text('Abbrechen'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();

                  final newLevel = DifficultyLevel(newDifficulty);
                  onDifficultyChanged(newLevel);

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
