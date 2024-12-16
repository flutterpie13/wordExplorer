import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/entities/card.dart';

class CardLoaderService {
  Future<List<CardModel>> loadCards(
      {int? classLevel, String? topic, String? wordType}) async {
    final String response =
        await rootBundle.loadString('assets/data/cards.json');
    final List<dynamic> data = jsonDecode(response);

    List<CardModel> allCards = data.map((item) {
      return CardModel(
        pairId: item['pairId'],
        content: item['content'],
        isScene: item['isScene'],
        classLevel: item['class'],
        topic: item['topic'],
        wordType: item['wordType'],
      );
    }).toList();

    // Anwenden von Filtern, falls Parameter angegeben sind
    if (classLevel != null || topic != null || wordType != null) {
      allCards = allCards.where((card) {
        final matchesClass =
            classLevel == null || card.classLevel == classLevel;
        final matchesTopic = topic == null || card.topic == topic;
        final matchesWordType = wordType == null || card.wordType == wordType;

        return matchesClass && matchesTopic && matchesWordType;
      }).toList();
    }

    return allCards;
  }
}
