import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/card.dart';

class JsonDataSource {
  Future<List<CardModel>> loadCardPairs() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/cards.json');
      final List<dynamic> jsonData = json.decode(jsonString);

      return jsonData.map((json) => CardModel.fromJson(json)).toList();
    } catch (e) {
      print('Fehler beim Laden der JSON-Daten: $e');
      return [];
    }
  }
}
