import 'dart:developer';
import 'package:flutter/material.dart';
import '../domain/entities/card.dart';
import '../domain/usecases/check_card_match.dart';
import '../domain/usecases/difficulty_level.dart';
import 'card_loader_service.dart';

enum CardStatus { verdeckt, aufgedeckt, gefunden }

class GameManager {
  final BuildContext context;
  final Function(List<CardModel>) onCardsLoaded;
  final Function() onGameReset;
  final Function(String) showMessage;

  List<CardModel> _cards = [];
  final Map<CardModel, CardStatus> _cardStatuses = {};
  CardModel? firstCard;
  CardModel? secondCard;
  bool _isInteractionLocked = false;
  bool isInteractionLocked() => _isInteractionLocked;
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
      final CardLoaderService cardLoaderService = CardLoaderService();
      final allCards = await cardLoaderService.loadCards();
      _cards = allCards;

      if (allCards.isEmpty) {
        log('Keine Karten verfügbar');
        showMessage('Keine Karten gefunden');
        return;
      }

      // Kartenfilter basierend auf Thema und Wortart
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
      for (final card in _cards) {
        _cardStatuses[card] = CardStatus.verdeckt;
      }
      onCardsLoaded(_cards);
      _cards.shuffle();
    } catch (e, stackTrace) {
      log('Fehler beim Laden der Karten: $e', stackTrace: stackTrace);
      showMessage('Fehler beim Laden der Karten');
    }
  }

  void onCardTap(CardModel card) {
    if (_isInteractionLocked ||
        _cardStatuses[card] == CardStatus.aufgedeckt ||
        _cardStatuses[card] == CardStatus.gefunden) {
      return;
    }

    if (firstCard == null) {
      // Erste Karte aufdecken
      firstCard = card;
      _cardStatuses[card] = CardStatus.aufgedeckt;
    } else if (secondCard == null && card != firstCard) {
      // Zweite Karte aufdecken
      secondCard = card;
      _cardStatuses[card] = CardStatus.aufgedeckt;

      // Übereinstimmung prüfen
      _isInteractionLocked = true;
      Future.delayed(const Duration(seconds: 1), () {
        checkMatch();
        _isInteractionLocked = false;
      });
    }
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
    firstCard = null;
    secondCard = null;
    _isInteractionLocked = false;

    for (final card in _cards) {
      _cardStatuses[card] = CardStatus.verdeckt;
    }

    loadCards(
        difficultyLevel: difficultyLevel, topic: topic, wordType: wordType);
    onGameReset();
  }

  void checkMatch() {
    if (firstCard == null || secondCard == null) {
      return;
    }

    final isMatch = firstCard!.pairId == secondCard!.pairId;
    if (isMatch) {
      _cardStatuses[firstCard!] = CardStatus.gefunden;
      _cardStatuses[secondCard!] = CardStatus.gefunden;
      showMessage('Match gefunden!');
    } else {
      _cardStatuses[firstCard!] = CardStatus.verdeckt;
      _cardStatuses[secondCard!] = CardStatus.verdeckt;
      showMessage('Kein Match!');
    }

    // Zurücksetzen für den nächsten Zug
    firstCard = null;
    secondCard = null;
  }

  Set<int> get flippedCards => _cardStatuses.entries
      .where((entry) => entry.value == CardStatus.aufgedeckt)
      .map((entry) => _cards.indexOf(entry.key))
      .toSet();

  Set<int> get matchedCards => _cardStatuses.entries
      .where((entry) => entry.value == CardStatus.gefunden)
      .map((entry) => _cards.indexOf(entry.key))
      .toSet();

  bool _validateIndices(int firstIndex, int secondIndex) {
    final valid = firstIndex < _cards.length && secondIndex < _cards.length;
    if (!valid) {
      log('Ungültige Indizes: $firstIndex, $secondIndex');
      showMessage('Ungültige Kartenindizes');
    }
    return valid;
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
