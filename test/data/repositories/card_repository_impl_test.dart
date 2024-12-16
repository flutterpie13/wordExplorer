import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:word_explorer/data/datasources/json_data_source.dart';
import 'package:word_explorer/data/repositories/card_repository_impl.dart';
import 'package:word_explorer/domain/entities/card_pair.dart';

// Generiert eine Mock-Klasse mit dem benutzerdefinierten Namen
@GenerateMocks(
  [JsonDataSource],
  customMocks: [MockSpec<JsonDataSource>(as: #CustomMockJsonDataSource)],
)
import 'card_repository_impl_test.mocks.dart'; // Datei mit generierten Mocks

void main() {
  late CustomMockJsonDataSource
      mockJsonDataSource; // Generierte Klasse wird verwendet
  late CardRepositoryImpl repository;

  setUp(() {
    mockJsonDataSource = CustomMockJsonDataSource();
    repository = CardRepositoryImpl(mockJsonDataSource);
  });

  group('CardRepositoryImpl', () {
    test(
        'should return a list of CardPair when the datasource successfully loads data',
        () async {
      // Arrange: Mock-Daten für den JsonDataSource
      final mockCardPairs = [
        CardPair(
          word: 'dog',
          sceneDescription: 'A dog runs after the ball.',
          sceneImagePath: 'assets/images/dog.png',
          wordType: 'Noun',
          category: 'Animals',
        ),
        CardPair(
          word: 'apple',
          sceneDescription: 'An apple is red and sweet.',
          sceneImagePath: 'assets/images/apple.png',
          wordType: 'Noun',
          category: 'Food',
        ),
      ];

      when(mockJsonDataSource.loadCardPairs())
          .thenAnswer((_) async => mockCardPairs);

      // Act: Repository-Funktion aufrufen
      final result = await repository.getCardPairs();

      // Assert: Überprüfen, ob die Ergebnisse korrekt sind
      expect(result, mockCardPairs);
      verify(mockJsonDataSource.loadCardPairs())
          .called(1); // Sicherstellen, dass die Funktion aufgerufen wurde
    });
  });
}
