import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/card_pair.dart';

class JsonDataSource {
  Future<List<CardPair>> loadCardPairs() async {
    // Lade die JSON-Datei aus dem assets-Ordner
    final String response =
        await rootBundle.loadString('assets/data/cards.json');
    final List<dynamic> data = json.decode(response);

    // Transformiere die JSON-Daten in CardPair-Objekte
    return data
        .map((json) => CardPair(
              word: json['word'],
              sceneDescription: json['sceneDescription'],
              sceneImagePath: json['sceneImagePath'],
              wordType: json['wordType'],
              category: json['category'],
            ))
        .toList();
  }
}
