import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:word_explorer/data/datasources/json_data_source.dart';
import 'package:word_explorer/domain/entities/card_pair.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('JsonDataSource', () {
    late JsonDataSource jsonDataSource;

    setUp(() {
      jsonDataSource = JsonDataSource();
    });

    test('should load card pairs from JSON and return a list of CardPair',
        () async {
      // Mock JSON-Datei in den Asset-Bundle laden
      const mockJson = '''
      [
        {
          "word": "dog",
          "sceneDescription": "A dog runs after the ball.",
          "sceneImagePath": "assets/images/dog.png",
          "wordType": "Noun",
          "category": "Animals"
        },
        {
          "word": "apple",
          "sceneDescription": "An apple is red and sweet.",
          "sceneImagePath": "assets/images/apple.png",
          "wordType": "Noun",
          "category": "Food"
        }
      ]
      ''';

      // Simuliere das Laden aus `rootBundle`
      final ByteData data =
          ByteData.sublistView(Uint8List.fromList(mockJson.codeUnits));
      ServicesBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/assets',
        (message) async => data.buffer.asByteData(),
      );

      // Führe den Test aus
      final List<CardPair> cardPairs = await jsonDataSource.loadCardPairs();

      // Überprüfe die Ergebnisse
      expect(cardPairs.length, 2);

      expect(cardPairs[0].word, 'dog');
      expect(cardPairs[0].sceneDescription, 'A dog runs after the ball.');
      expect(cardPairs[0].sceneImagePath, 'assets/images/dog.png');
      expect(cardPairs[0].wordType, 'Noun');
      expect(cardPairs[0].category, 'Animals');

      expect(cardPairs[1].word, 'apple');
      expect(cardPairs[1].sceneDescription, 'An apple is red and sweet.');
      expect(cardPairs[1].sceneImagePath, 'assets/images/apple.png');
      expect(cardPairs[1].wordType, 'Noun');
      expect(cardPairs[1].category, 'Food');
    });
  });
}
