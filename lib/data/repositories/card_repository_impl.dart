import '../../domain/entities/card_pair.dart';
import '../../domain/repositories/card_repository.dart';
import '../datasources/json_data_source.dart';

class CardRepositoryImpl implements CardRepository {
  final JsonDataSource jsonDataSource;

  CardRepositoryImpl(this.jsonDataSource);

  @override
  Future<List<CardPair>> getCardPairs() async {
    return await jsonDataSource.loadCardPairs();
  }
}
