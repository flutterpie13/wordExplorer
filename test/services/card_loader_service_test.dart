import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:word_explorer/domain/entities/card.dart';
import 'package:word_explorer/domain/usecases/difficulty_level.dart';
import 'package:word_explorer/services/card_loader_service.dart';
import 'package:word_explorer/services/game_manager.dart';

import '../methods.dart';

class MockAssetBundle extends AssetBundle {
  final String jsonData;

  MockAssetBundle(this.jsonData);

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return jsonData;
  }

  @override
  Future<ByteData> load(String key) async {
    throw UnimplementedError();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('CardLoaderService Tests', () {
    late CardLoaderService cardLoaderService;

    test('Lädt und filtert Karten korrekt nach pairId (gültige Paare)',
        () async {
      const jsonData = '''
      [
        {
          "pairId": 1,
          "content": "dog",
          "isScene": false,
          "classLevel": 5,
          "topic": "tiere",
          "wordType": "noun"
        },
        {
          "pairId": 1,
          "content": "A dog runs after the ball.",
          "isScene": true,
          "classLevel": 5,
          "topic": "tiere",
          "wordType": "noun"
        },
        {
          "pairId": 91,
          "content": "She takes pictures with the camera.",
          "isScene": true,
          "classLevel": 5,
          "topic": "freizeit",
          "wordType": "verb"
        },
        {
          "pairId": 92,
          "content": "to sing ",
          "isScene": false,
          "classLevel": 5,
          "topic": "freizeit",
          "wordType": "verb"
        }
      ]
      ''';

      final mockBundle = MockAssetBundle(jsonData);
      cardLoaderService = CardLoaderService(assetBundle: mockBundle);

      final List<CardModel> cards = await cardLoaderService.loadCards();
      expect(cards.length, 2);
      expect(cards[0].pairId, 1);
      expect(cards[1].pairId, 1);
    });

    test('Ignoriert ungültige Paare', () async {
      const jsonData = '''
      [
        {
          "pairId": 2,
          "content": "cat",
          "isScene": false,
          "classLevel": 5,
          "topic": "tiere",
          "wordType": "noun"
        },
                {
          "pairId": 2,
          "content": "cat",
          "isScene": false,
          "classLevel": 5,
          "topic": "tiere",
          "wordType": "noun"
        }
      ]
      ''';

      final mockBundle = MockAssetBundle(jsonData);
      cardLoaderService = CardLoaderService(assetBundle: mockBundle);

      final List<CardModel> cards = await cardLoaderService.loadCards();
      expect(cards.isEmpty, true); // Keine gültigen Paare
    });

    test('Filtert nach topic korrekt', () async {
      const jsonData = '''
      [
        {
          "pairId": 3,
          "content": "elephant",
          "isScene": false,
          "classLevel": 5,
          "topic": "tiere",
          "wordType": "noun"
        },
        {
          "pairId": 3,
          "content": "The elephant is big and gray.",
          "isScene": true,
          "classLevel": 5,
          "topic": "tiere",
          "wordType": "noun"
        },
        {
          "pairId": 4,
          "content": "pizza",
          "isScene": false,
          "classLevel": 5,
          "topic": "essen",
          "wordType": "noun"
        },
        {
          "pairId": 4,
          "content": "We love to eat pizza together.",
          "isScene": true,
          "classLevel": 5,
          "topic": "essen",
          "wordType": "noun"
        }
      ]
      ''';

      final mockBundle = MockAssetBundle(jsonData);
      cardLoaderService = CardLoaderService(assetBundle: mockBundle);

      final List<CardModel> cards =
          await cardLoaderService.loadCards(topic: 'tiere');
      expect(cards.length, 2);
      expect(cards[0].topic, 'tiere');
      expect(cards[1].topic, 'tiere');
    });
    test('Filter: Lädt Karten basierend auf Topic und WordType', () async {
      const jsonData = '''
  [
    {"pairId": 1, "content": "dog", "isScene": false, "class": 1, "topic": "animals", "wordType": "noun"},
    {"pairId": 1, "content": "A dog runs.", "isScene": true, "class": 1, "topic": "animals", "wordType": "noun"},
    {"pairId": 2, "content": "apple", "isScene": false, "class": 1, "topic": "food", "wordType": "noun"},
    {"pairId": 2, "content": "I eat an apple.", "isScene": true, "class": 1, "topic": "food", "wordType": "noun"}
  ]
  ''';

      final mockBundle = MockAssetBundle(jsonData);
      final cardLoader = CardLoaderService(assetBundle: mockBundle);

      final filteredCards =
          await cardLoader.loadCards(topic: 'animals', wordType: 'noun');
      expect(filteredCards.length, 2);
      expect(filteredCards[0].topic, 'animals');
    });
    group('CardLoaderService - Kartenanzahl basierend auf Schwierigkeitsgrad',
        () {
      GameManager gameManager;

      setUp(() {});

      testWidgets('Easy: Lädt 4 Paare', (WidgetTester tester) async {
        final cards = [
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
        gameManager = await initializeBuildContext(tester,
            cards: [], onCardsLoaded: (_) {});

        await gameManager.loadCards(
          difficultyLevel: DifficultyLevel(Difficulty.easy),
          topic: 'all',
          wordType: 'all',
        );
        expect(gameManager.getLoadedCards().length, 8);
      });

      testWidgets('Hard: Lädt 10 Paare', (WidgetTester tester) async {
        final cards = [
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
        gameManager = await initializeBuildContext(tester,
            cards: [], onCardsLoaded: (_) {});

        await gameManager.loadCards(
          difficultyLevel: DifficultyLevel(Difficulty.hard),
          topic: 'all',
          wordType: 'all',
        );
        expect(gameManager.getLoadedCards().length, 20);
      });
    });
  });
}
