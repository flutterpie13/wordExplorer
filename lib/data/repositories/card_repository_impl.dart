import 'package:word_explorer/domain/entities/card.dart';
import '../../domain/repositories/card_repository.dart';
import '../datasources/json_data_source.dart';
import 'dart:developer';

class CardRepositoryImpl implements CardRepository {
  final JsonDataSource jsonDataSource;

  CardRepositoryImpl(this.jsonDataSource);

  @override
  Future<List<CardModel>> getCardPairs() async {
    try {
      return await jsonDataSource.loadCardPairs();
    } catch (e, stackTrace) {
      log('Fehler im CardRepository beim Abrufen von Karten: $e',
          stackTrace: stackTrace);
      rethrow; // Exception weitergeben
    }
  }
}
