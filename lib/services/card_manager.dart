import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/entities/card.dart';

class CardManager {
  final List<CardModel> _allCards = [];

  Future<void> loadCards() async {
    final String response =
        await rootBundle.loadString('assets/data/cards.json');
    final List<dynamic> data = jsonDecode(response);

    _allCards.clear();
    _allCards.addAll(data.map((item) {
      return CardModel(
        pairId: item['pairId'],
        content: item['content'],
        isScene: item['isScene'],
        classLevel: item['class'],
        topic: item['topic'],
        wordType: item['wordType'],
      );
    }).toList());
  }

  List<CardModel> filterCards({
    required int classLevel,
    required String topic,
    required String wordType,
  }) {
    return _allCards.where((card) {
      final matchesClass = card.classLevel == classLevel;
      final matchesTopic = card.topic == topic || topic == 'all';
      final matchesWordType = card.wordType == wordType || wordType == 'all';

      return matchesClass && matchesTopic && matchesWordType;
    }).toList();
  }
}
