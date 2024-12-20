import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_explorer/domain/entities/card.dart';
import 'package:word_explorer/domain/usecases/difficulty_level.dart';
import 'package:word_explorer/services/game_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('GameManager Match-Logik', () {
    late GameManager gameManager;
    late List<CardModel> cards;
    DifficultyLevel _difficultyLevel = DifficultyLevel(Difficulty.easy);

    setUp(() {
      cards = [
        CardModel(
            pairId: 1,
            content: 'Card 1A',
            isScene: false,
            classLevel: 5,
            topic: 'tiere',
            wordType: 'noun'),
        CardModel(
            pairId: 1,
            content: 'Card 1B',
            isScene: true,
            classLevel: 5,
            topic: 'tiere',
            wordType: 'noun'),
        CardModel(
            pairId: 2,
            content: 'Card 2A',
            isScene: false,
            classLevel: 5,
            topic: 'tiere',
            wordType: 'noun'),
        CardModel(
            pairId: 2,
            content: 'Card 2B',
            isScene: true,
            classLevel: 5,
            topic: 'tiere',
            wordType: 'noun'),
      ];
    });
    testWidgets('Karten matchen korrekt', (WidgetTester tester) async {
      // Erstelle ein Mock-Widget für den Kontext
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              gameManager = GameManager(
                context: context,
                onCardsLoaded: (_) {},
                onGameReset: () {},
                showMessage: (_) {},
              );

              gameManager.loadCards(
                difficultyLevel: _difficultyLevel,
                topic: 'all',
                wordType: 'all',
              );

              return Container(); // Dummy-Widget
            },
          ),
        ),
      );

      gameManager.onCardTap(cards[0]); // Tap erste Karte
      gameManager.onCardTap(cards[1]); // Tap zweite Karte

      expect(gameManager.matchedCards.length, 2);
      expect(
          gameManager.flippedCards.isEmpty, true); // Beide Karten bleiben offen
    });

    testWidgets('Karten matchen nicht', (WidgetTester tester) async {
      // Erstelle ein Mock-Widget für den Kontext
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              gameManager = GameManager(
                context: context,
                onCardsLoaded: (_) {},
                onGameReset: () {},
                showMessage: (_) {},
              );

              gameManager.loadCards(
                difficultyLevel: _difficultyLevel,
                topic: 'all',
                wordType: 'all',
              );

              return Container(); // Dummy-Widget
            },
          ),
        ),
      );

      // Testausführung
      gameManager.onCardTap(cards[0]); // Tap erste Karte
      gameManager.onCardTap(cards[2]); // Tap Karte ohne Match

      expect(gameManager.matchedCards.isEmpty, true); // Kein Match
      expect(gameManager.flippedCards.isEmpty,
          true); // Beide Karten werden verdeckt
    });
  });
}
