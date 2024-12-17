enum CardType { term, scene }

class CardPairModel {
  final int pairId;
  final String term; // Begriff der Karte
  final String scene; // Beschreibung oder Szene der Karte
  final String wordType; // Wortart (z. B. noun, verb)

  CardPairModel({
    required this.pairId,
    required this.term,
    required this.scene,
    required this.wordType,
  });

  factory CardPairModel.fromJson(Map<String, dynamic> json) {
    return CardPairModel(
      pairId: json['pairId'],
      term: json['term'],
      scene: json['scene'],
      wordType: json['wordType'],
    );
  }
}
