import 'card_pair_model.dart';

class Topic {
  final String name;
  final List<CardPairModel> pairs;

  Topic({
    required this.name,
    required this.pairs,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      name: json['topic'],
      pairs: (json['pairs'] as List)
          .map((pairJson) => CardPairModel.fromJson(pairJson))
          .toList(),
    );
  }
}
