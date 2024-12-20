import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_explorer/data/datasources/json_data_source.dart';
import 'package:word_explorer/domain/entities/card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('JsonDataSource', () {
    late JsonDataSource jsonDataSource;

    setUp(() {
      jsonDataSource = JsonDataSource();
    });

    test('should load card pairs from JSON and return a list of CardModel',
        () async {
      // Mock JSON-Datei in den Asset-Bundle laden
      const mockJson = '''
      [
        {
          "pairId": 1,
          "content": "dog",
          "isScene": false,
          "classLevel": 5,
          "topic": "animals",
          "wordType": "noun"
        },
        {
          "pairId": 1,
          "content": "A dog runs after the ball.",
          "isScene": true,
          "classLevel": 5,
          "topic": "animals",
          "wordType": "noun"
        },
        {
          "pairId": 2,
          "content": "apple",
          "isScene": false,
          "classLevel": 5,
          "topic": "food",
          "wordType": "noun"
        },
        {
          "pairId": 2,
          "content": "An apple is red and sweet.",
          "isScene": true,
          "classLevel": 5,
          "topic": "food",
          "wordType": "noun"
        }
      ]
      ''';

      // Simuliere das Laden aus `rootBundle`
      final ByteData data =
          ByteData.sublistView(Uint8List.fromList(mockJson.codeUnits));
      ServicesBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/assets',
        (message) async =>
            ByteData.sublistView(Uint8List.fromList(mockJson.codeUnits)),
      );

      // Führe den Test aus
      final List<CardModel> cardModels = await jsonDataSource.loadCardPairs();

      // Überprüfe die Ergebnisse
      expect(cardModels.length, 4);

      // Überprüfung der ersten Karte
      expect(cardModels[0].pairId, 1);
      expect(cardModels[0].content, 'dog');
      expect(cardModels[0].isScene, false);
      expect(cardModels[0].classLevel, 5);
      expect(cardModels[0].topic, 'animals');
      expect(cardModels[0].wordType, 'noun');

      // Überprüfung der zweiten Karte (Szene)
      expect(cardModels[1].pairId, 1);
      expect(cardModels[1].content, 'A dog runs after the ball.');
      expect(cardModels[1].isScene, true);
      expect(cardModels[1].classLevel, 5);
      expect(cardModels[1].topic, 'animals');
      expect(cardModels[1].wordType, 'noun');

      // Überprüfung der dritten Karte
      expect(cardModels[2].pairId, 2);
      expect(cardModels[2].content, 'apple');
      expect(cardModels[2].isScene, false);
      expect(cardModels[2].classLevel, 5);
      expect(cardModels[2].topic, 'food');
      expect(cardModels[2].wordType, 'noun');

      // Überprüfung der vierten Karte (Szene)
      expect(cardModels[3].pairId, 2);
      expect(cardModels[3].content, 'An apple is red and sweet.');
      expect(cardModels[3].isScene, true);
      expect(cardModels[3].classLevel, 5);
      expect(cardModels[3].topic, 'food');
      expect(cardModels[3].wordType, 'noun');
    });
  });
}
