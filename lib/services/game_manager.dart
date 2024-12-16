import 'package:flutter/material.dart';
import '../domain/entities/card.dart';
import '../domain/usecases/difficulty_level.dart';
import 'card_loader_service.dart';

class GameManager {
  final BuildContext context;
  final Function(List<CardModel>)
      onCardsLoaded; // Callback zum Aktualisieren der Karten
  final Function() onGameReset; // Callback für Spiel-Reset
  final Function(String) showMessage;

  GameManager({
    required this.context,
    required this.onCardsLoaded,
    required this.onGameReset,
    required this.showMessage,
  });

  Future<void> loadCards(DifficultyLevel difficultyLevel) async {
    final CardLoaderService cardLoaderService = CardLoaderService();
    final allCards = await cardLoaderService.loadCards();

    List<CardModel> selectedCards;
    switch (difficultyLevel.difficulty) {
      case Difficulty.easy:
        selectedCards = allCards.take(8).toList(); // 4 Paare
        break;
      case Difficulty.medium:
        selectedCards = allCards.take(12).toList(); // 6 Paare
        break;
      case Difficulty.hard:
        selectedCards = allCards; // Alle Karten
        break;
    }

    selectedCards.shuffle();
    onCardsLoaded(selectedCards); // Aktualisiere die Karten im UI
  }

  void resetGame() {
    onGameReset(); // Führt den Reset im UI aus
  }

  void changeDifficulty(
    Difficulty difficulty,
    DifficultyLevel currentLevel,
    Function(DifficultyLevel) onDifficultyChanged,
  ) {
    if (currentLevel.difficulty != difficulty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Warning'),
            content: const Text(
                'Changing the difficulty will reset the current game. Do you want to proceed?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Dialog schließen
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Dialog schließen
                  resetGame(); // Spiel zurücksetzen
                  onDifficultyChanged(DifficultyLevel(difficulty));
                },
                child: const Text('Proceed'),
              ),
            ],
          );
        },
      );
    }
  }

  void checkMatch(
    CardModel card1,
    CardModel card2,
    DifficultyLevel difficultyLevel,
    Function() onMatch,
    Function() onNoMatch,
  ) {
    final isMatch = card1.pairId == card2.pairId;

    if (isMatch) {
      onMatch();
    } else {
      showMessage('No Match');
      Future.delayed(const Duration(seconds: 1), () {
        onNoMatch();
      });
    }
  }
}
