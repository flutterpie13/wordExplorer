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
}
