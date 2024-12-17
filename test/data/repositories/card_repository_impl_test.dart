import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:word_explorer/data/datasources/json_data_source.dart';
import 'package:word_explorer/data/repositories/card_repository_impl.dart';
import 'package:word_explorer/domain/entities/card.dart';

// Generiert eine Mock-Klasse mit dem benutzerdefinierten Namen
@GenerateMocks(
  [JsonDataSource],
  customMocks: [MockSpec<JsonDataSource>(as: #CustomMockJsonDataSource)],
)
import 'card_repository_impl_test.mocks.dart'; // Datei mit generierten Mocks

void main() {
  late CustomMockJsonDataSource mockJsonDataSource; // Generierter Mock
  late CardRepositoryImpl repository;

  setUp(() {
    mockJsonDataSource = CustomMockJsonDataSource();
    repository = CardRepositoryImpl(mockJsonDataSource);
  });

  group('CardRepositoryImpl', () {
    test('should return a list of CardModel when the datasource loads data',
        () async {
      // Arrange: Mock-Daten für JsonDataSource
      final mockCardModels = [
        CardModel(
          pairId: 1,
          content: 'dog',
          isScene: false,
          classLevel: 5,
          topic: 'animals',
          wordType: 'noun',
        ),
        CardModel(
          pairId: 1,
          content: 'A dog runs after the ball.',
          isScene: true,
          classLevel: 5,
          topic: 'animals',
          wordType: 'noun',
        ),
      ];

      // Simuliere das Verhalten der loadCardPairs-Methode
      when(mockJsonDataSource.loadCardPairs())
          .thenAnswer((_) async => mockCardModels);

      // Act: Repository-Funktion aufrufen
      final result = await repository.getCardPairs();

      // Assert: Überprüfen, ob die Ergebnisse korrekt sind
      expect(result, mockCardModels);
      verify(mockJsonDataSource.loadCardPairs())
          .called(1); // Überprüfe den Aufruf
    });

    test('should return an empty list when the datasource throws an exception',
        () async {
      // Arrange: Simuliere einen Fehler beim Laden der Karten
      when(mockJsonDataSource.loadCardPairs()).thenThrow(Exception('Fehler'));

      // Act: Repository-Funktion aufrufen
      final result = await repository.getCardPairs();

      // Assert: Überprüfen, ob eine leere Liste zurückgegeben wird
      expect(result, isEmpty);
      verify(mockJsonDataSource.loadCardPairs())
          .called(1); // Überprüfe den Aufruf
    });
  });
}
