import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/card.dart';

class JsonDataSource {
  Future<List<CardModel>> loadCardPairs() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/cards.json');
      if (jsonString.isEmpty) {
        print('JSON-Datei ist leer.');
        return [];
      }

      final List<dynamic> jsonData = json.decode(jsonString);
      if (jsonData.isEmpty) {
        print('Keine Daten in der JSON-Datei gefunden.');
        return [];
      }

      final List<CardModel> cards = jsonData
          .map((json) => CardModel.fromJson(json))
          .whereType<CardModel>() // Validiert die Konvertierung
          .toList();

      if (cards.isEmpty) {
        print('Keine gültigen Karten gefunden.');
      }

      return cards;
    } catch (e, stackTrace) {
      print('Fehler beim Laden der JSON-Daten: $e');
      print(stackTrace);
      return [];
    }
  }
}
