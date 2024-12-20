import 'dart:developer';
import 'package:flutter/material.dart';
import '../domain/entities/card.dart';
import '../domain/usecases/difficulty_level.dart';
import 'card_loader_service.dart';

enum CardStatus { noMatch, open, match, close }

class GameManager {
  final BuildContext context;
  final Function(List<CardModel>) onCardsLoaded;
  final Function() onGameReset;
  //final Function(String) showMessage;
  final dynamic showInfo;
  bool _isGameOver = false;
  bool isGameOver() => _isGameOver;

  bool _isInteractionLocked = false;
  bool isInteractionLocked() => _isInteractionLocked;

  List<CardModel> _cards = [];
  final Map<CardModel, CardStatus> _cardStatuses = {};
  CardModel? firstCard;
  CardModel? secondCard;

  GameManager({
    required this.context,
    required this.onCardsLoaded,
    required this.onGameReset,
    required this.showInfo,
  });

  Future<void> loadCards({
    required DifficultyLevel difficultyLevel,
    required String topic,
    required String wordType,
  }) async {
    try {
      final CardLoaderService cardLoaderService = CardLoaderService();
      final allCards = await cardLoaderService.loadCards();

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
        _cardStatuses[card] = CardStatus.close;
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
        _cardStatuses[card] == CardStatus.open ||
        _cardStatuses[card] == CardStatus.match) {
      return; // Verhindert Interaktionen während der Sperre
    }
    // Erste Karte aufdecken
    if (firstCard == null) {
      firstCard = card;
      _updateCardStatus(card, CardStatus.open);
      onCardsLoaded(_cards);
      return;
    }
    // Zweite Karte auswählen
    if (secondCard == null && card != firstCard) {
      secondCard = card;
      _updateCardStatus(card, CardStatus.open);
      onCardsLoaded(_cards); // UI aktualisieren
      _isInteractionLocked = true;
      // Match prüfen
      if (firstCard!.pairId == secondCard!.pairId) {
        // Karten matchen
        _updateCardStatus(card, CardStatus.match);
        _updateCardStatus(card, CardStatus.match);
        showMessage('Match gefunden!');
        resetSelection();
      } else {
        // Kein Match - Interaktion für den nächsten Tap sperren
        showMessage('Kein Match! Tippe erneut, um die Karten zu verdecken.');
      }
      _isInteractionLocked = false;
      checkWinCondition();
      return;
    }
    // Wenn es kein Match war, verdecke beide Karten beim nächsten Tap
    if (firstCard != null && secondCard != null) {
      _updateCardStatus(card, CardStatus.close);
      _updateCardStatus(card, CardStatus.close);
      resetSelection();
      _isInteractionLocked = false; // Interaktion freigeben
      onCardsLoaded(_cards); // UI aktualisieren
    }
  }

  void resetSelection() {
    firstCard = null;
    secondCard = null;
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
  }) async {
    // Spielstatus zurücksetzen
    _isGameOver = false;
    firstCard = null;
    secondCard = null;
    _isInteractionLocked = false;

    // Asynchrones Zurücksetzen der Kartenstatus
    await Future.microtask(() {
      for (final card in _cards) {
        _cardStatuses[card] = CardStatus.close;
      }
    });

    loadCards(
        difficultyLevel: difficultyLevel, topic: topic, wordType: wordType);
    onGameReset();
  }

  /* void checkMatch() {
    if (firstCard == null || secondCard == null) {
      return;
    }

    final isMatch = firstCard!.pairId == secondCard!.pairId;
    if (isMatch) {
      _cardStatuses[firstCard!] = CardStatus.match;
      _cardStatuses[secondCard!] = CardStatus.match;
      showMessage('Match!');
    } else {
      _cardStatuses[firstCard!] = CardStatus.close;
      _cardStatuses[secondCard!] = CardStatus.close;
      showMessage('No Match!');
    }
  }*/

  Set<int> get flippedCards => _cardStatuses.entries
      .where((entry) => entry.value == CardStatus.open)
      .map((entry) => _cards.indexOf(entry.key))
      .toSet();

  Set<int> get matchedCards => _cardStatuses.entries
      .where((entry) => entry.value == CardStatus.match)
      .map((entry) => _cards.indexOf(entry.key))
      .toSet();

  CardStatus getCardStatus(CardModel card) {
    return _cardStatuses[card] ?? CardStatus.close; // Standardstatus: verdeckt
  }

  List<CardModel> getLoadedCards() {
    return _cards; // Gibt die Liste der geladenen Karten zurück
  }

  bool _validateIndices(int firstIndex, int secondIndex) {
    final valid = firstIndex < _cards.length && secondIndex < _cards.length;
    if (!valid) {
      log('Ungültige Indizes: $firstIndex, $secondIndex');
      showMessage('Ungültige Kartenindizes');
    }
    return valid;
  }

  void shuffleCards() {
    if (!_isGameOver) {
      _cards.shuffle();
    } // Zufällige Reihenfolge der Karten
  }

  void checkWinCondition() {
    // Überprüfe, ob alle Karten den Status "match" haben
    final allMatched =
        _cardStatuses.values.every((status) => status == CardStatus.match);

    if (allMatched && !_isGameOver) {
      _isGameOver = true; // Setze den Spielstatus auf beendet
      showMessage('Glückwunsch! Du hast alle Paare gefunden!');
    }
    _isInteractionLocked = false;
  }

  void _updateCardStatus(CardModel card, CardStatus status) {
    if (_cardStatuses[card] == CardStatus.match) {
      // Karten, die bereits ein Match sind, dürfen nicht mehr geändert werden
      return;
    }
    _cardStatuses[card] = status;
    // UI nur für den spezifischen Bereich aktualisieren
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onCardsLoaded(_cards);
    });
  }

  void showMessage(dynamic message) {
    ScaffoldMessenger.of(context)
        .clearSnackBars(); // Alte Nachrichten entfernen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.toString()),
        duration: const Duration(seconds: 1), // Kürzere Anzeigedauer
      ),
    );
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
