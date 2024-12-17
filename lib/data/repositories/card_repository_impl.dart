import 'package:word_explorer/domain/entities/card.dart';
import '../../domain/repositories/card_repository.dart';
import '../datasources/json_data_source.dart';

class CardRepositoryImpl implements CardRepository {
  final JsonDataSource jsonDataSource;

  CardRepositoryImpl(this.jsonDataSource);

  @override
  Future<List<CardModel>> getCardPairs() async {
    try {
      return await jsonDataSource.loadCardPairs();
    } catch (e) {
      print('Fehler beim Laden der Karten: $e');
      return []; // Gebe eine leere Liste zurück, wenn ein Fehler auftritt
    }
  }
}
