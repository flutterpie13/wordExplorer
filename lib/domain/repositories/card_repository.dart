import '../entities/card.dart';

abstract class CardRepository {
  Future<List<CardModel>> getCardPairs();
}
