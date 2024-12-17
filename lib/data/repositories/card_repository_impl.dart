import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/card_pair_model.dart';
import '../models/class_model.dart';
import '../models/topic_model.dart';

class CardRepository {
  Future<ClassLevel> fetchClassLevel(int classLevel) async {
    final String response = await rootBundle
        .loadString('assets/data/terms_by_class_and_topic.json');
    final Map<String, dynamic> data = json.decode(response);

    // Suche die Klasse in den JSON-Daten
    final classData = (data['classes'] as List)
        .firstWhere((cls) => cls['classLevel'] == classLevel);

    return ClassLevel.fromJson(classData);
  }

  Future<List<CardPairModel>> fetchFilteredCardPairs({
    required int classLevel,
    required String topic,
  }) async {
    try {
      // Lade die JSON-Daten
      final String response = await rootBundle
          .loadString('assets/data/terms_by_class_and_topic.json');
      final Map<String, dynamic> data = json.decode(response);

      // Suche die Klasse basierend auf classLevel
      final classData = (data['classes'] as List).firstWhere(
          (cls) => cls['classLevel'] == classLevel,
          orElse: () => null);

      if (classData == null) {
        print('No class data found for classLevel: $classLevel');
        return [];
      }

      // Suche das Thema basierend auf topic
      final topicData = (classData['topics'] as List)
          .firstWhere((tp) => tp['topic'] == topic, orElse: () => null);

      if (topicData == null) {
        print('No topic data found for topic: $topic');
        return [];
      }

      // Extrahiere die Paare
      final pairs = topicData['pairs'] as List;
      return pairs.map((json) => CardPairModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching card pairs: $e');
      return [];
    }
  }
}
