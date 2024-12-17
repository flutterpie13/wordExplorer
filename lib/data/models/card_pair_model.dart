class CardModel {
  final int pairId;
  final String content;
  final bool isScene;

  CardModel(
      {required this.pairId, required this.content, required this.isScene});

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      pairId: json['pairId'],
      content: json['content'],
      isScene: json['isScene'],
    );
  }
}
