import '../datasources/json_data_source.dart';
import '../../domain/entities/card.dart';
import '../../domain/repositories/card_repository.dart';

class CardRepositoryImpl implements CardRepository {
  final JsonDataSource? jsonDataSource;

  CardRepositoryImpl(this.jsonDataSource);

  @override
  Future<List<CardModel>> getCardPairs() async {
    if (jsonDataSource == null) {
      print('JsonDataSource ist nicht initialisiert.');
      return [];
    }

    try {
      final cardPairs = await jsonDataSource!.loadCardPairs();
      if (cardPairs.isEmpty) {
        print('Keine Kartenpaare gefunden.');
        return [];
      }
      return cardPairs;
    } catch (e, stackTrace) {
      print('Fehler beim Laden der Kartenpaare: $e');
      print(stackTrace);
      return []; // Fallback: Leere Liste
    }
  }
}
