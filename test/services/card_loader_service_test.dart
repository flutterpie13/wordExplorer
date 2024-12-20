import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:word_explorer/domain/entities/card.dart';
import 'package:word_explorer/services/card_loader_service.dart';

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
  });
}
