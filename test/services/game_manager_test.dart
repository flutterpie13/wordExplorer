import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_explorer/domain/entities/card.dart';
import 'package:word_explorer/domain/usecases/difficulty_level.dart';
import 'package:word_explorer/presentation/widgets/flip_card.dart';
import 'package:word_explorer/services/game_manager.dart';

import '../methods.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('GameManager Match-Logik', () {
    GameManager gameManager;
    late List<CardModel> cards;
    DifficultyLevel _difficultyLevel = DifficultyLevel(Difficulty.easy);

    setUp(() {
      cards = [
        for (var i = 1; i <= 10; i++) ...[
          CardModel(
              pairId: i,
              content: 'Card $i',
              isScene: false,
              classLevel: 1,
              topic: 'test',
              wordType: 'noun'),
          CardModel(
              pairId: i,
              content: 'Scene $i',
              isScene: true,
              classLevel: 1,
              topic: 'test',
              wordType: 'noun'),
        ],
      ];
    });
    testWidgets('Karten matchen korrekt', (WidgetTester tester) async {
      // BuildContext initialisieren
      final gameManager = await initializeBuildContext(
        tester,
        cards: cards,
        onCardsLoaded: (loadedCards) =>
            expect(loadedCards.length, cards.length),
      );

      // Karten aufdecken
      gameManager.onCardTap(cards[0]); // Tap erste Karte
      gameManager.onCardTap(cards[1]); // Tap zweite Karte

      // Überprüfen, ob die Karten gematched sind
      expect(gameManager.matchedCards.length, 2);
      expect(gameManager.getCardStatus(cards[0]), CardStatus.match);
      expect(gameManager.getCardStatus(cards[1]),
          CardStatus.match); // Beide Karten bleiben offen
    });

    testWidgets('Karten matchen nicht', (WidgetTester tester) async {
      // BuildContext initialisieren
      final gameManager = await initializeBuildContext(
        tester,
        cards: cards,
      );

      // Karten aufdecken
      gameManager.onCardTap(cards[0]); // Tap erste Karte
      gameManager.onCardTap(cards[1]); // Tap zweite Karte

      // Überprüfen, ob die Karten zurückgedreht werden
      await tester.pump(const Duration(seconds: 2)); // Verzögerung abwarten
      expect(gameManager.getCardStatus(cards[0]), CardStatus.close);
      expect(gameManager.getCardStatus(cards[1]), CardStatus.close);
    });
  });
  group('GameManager - Gewinnbedingung', () {
    late List<CardModel> cards;

    setUp(() {
      cards = [
        for (var i = 1; i <= 10; i++) ...[
          CardModel(
              pairId: i,
              content: 'Card $i',
              isScene: false,
              classLevel: 1,
              topic: 'test',
              wordType: 'noun'),
          CardModel(
              pairId: i,
              content: 'Scene $i',
              isScene: true,
              classLevel: 1,
              topic: 'test',
              wordType: 'noun'),
        ],
      ];
    });

    testWidgets('Gewinnbedingung erfüllt, wenn alle Karten matched sind',
        (WidgetTester tester) async {
      // BuildContext initialisieren
      final gameManager = await initializeBuildContext(
        tester,
        cards: cards,
      );

      for (final card in cards) {
        gameManager.onCardTap(card);
      }
      gameManager.checkWinCondition();
      final allMatched = cards
          .every((card) => gameManager.getCardStatus(card) == CardStatus.match);
      expect(allMatched, true);
    });

    testWidgets('Rset nach gewonnenem Spiel.', (WidgetTester tester) async {
      // BuildContext initialisieren
      final gameManager = await initializeBuildContext(
        tester,
        cards: cards,
      );
      // Simuliere ein gewonnenes Spiel
      gameManager.onCardTap(cards[0]);
      gameManager.onCardTap(cards[1]);
      gameManager.checkWinCondition();

      expect(gameManager.isGameOver(), true);

      // Spiel zurücksetzen
      gameManager.resetGame(
        difficultyLevel: DifficultyLevel(Difficulty.easy),
        topic: 'all',
        wordType: 'all',
      );

      expect(gameManager.isGameOver(), false); // Spielstatus ist zurückgesetzt
    });
  });

  group('Änderung der Einstellungen', () {
    late List<CardModel> cards;

    setUp(() {
      cards = [
        for (var i = 1; i <= 10; i++) ...[
          CardModel(
              pairId: i,
              content: 'Card $i',
              isScene: false,
              classLevel: 1,
              topic: 'test',
              wordType: 'noun'),
          CardModel(
              pairId: i,
              content: 'Scene $i',
              isScene: true,
              classLevel: 1,
              topic: 'test',
              wordType: 'noun'),
        ],
      ];
    });
    testWidgets('Aktualisiert Karten nach Änderung der Einstellungen',
        (tester) async {
      final gameManager = await initializeBuildContext(
        tester,
        cards: cards,
      );

      // Überprüfen, dass Karten geladen sind
      expect(find.byType(FlipCard), findsWidgets);

      // Schwierigkeit ändern
      await tester.tap(find.byType(DropdownButton<Difficulty>));
      await tester.pump();
      await tester.tap(find.text('medium').last);
      await tester.pumpAndSettle();

      // Überprüfen, dass neue Karten geladen sind
      expect(find.byType(FlipCard), findsWidgets);
    });
  });
}
