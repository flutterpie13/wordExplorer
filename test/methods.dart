import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_explorer/domain/entities/card.dart';
import 'package:word_explorer/domain/usecases/difficulty_level.dart';
import 'package:word_explorer/services/game_manager.dart';

// Erstelle ein Mock-Widget für den Kontext
Future<GameManager> initializeBuildContext(
  WidgetTester tester, {
  required List<CardModel> cards,
  void Function(List<CardModel>)? onCardsLoaded,
  void Function()? onGameReset,
  void Function(String)? showMessage,
}) async {
  GameManager? gameManager;

  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (BuildContext context) {
          gameManager = GameManager(
            context: context,
            onCardsLoaded: onCardsLoaded ?? (_) {},
            onGameReset: onGameReset ?? () {},
            showMessage: showMessage ?? (_) {},
          );

          // Simuliert das Laden der Karten
          gameManager!.loadCards(
            difficultyLevel: DifficultyLevel(Difficulty.easy),
            topic: 'all',
            wordType: 'all',
          );

          // Setze Karten
          for (var card in cards) {
            gameManager!.onCardTap(card);
          }

          return Container(); // Dummy-Widget
        },
      ),
    ),
  );

  return gameManager!;
}
