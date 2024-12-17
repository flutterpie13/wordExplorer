class CardModel {
  final int pairId;
  final String content;
  final bool isScene;
  final int classLevel; // Neue Attribute
  final String topic;
  final String wordType;

  CardModel({
    required this.pairId,
    required this.content,
    required this.isScene,
    required this.classLevel,
    required this.topic,
    required this.wordType,
  });
  // fromJson-Konstruktor für die JSON-Daten
  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      pairId: json['pairId'] as int,
      content: json['content'] as String,
      isScene: json['isScene'] as bool,
      classLevel: json['classLevel'] as int,
      topic: json['topic'] as String,
      wordType: json['wordType'] as String,
    );
  }
}
