import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';

import 'package:word_explorer/domain/entities/card.dart';

class CardLoaderService {
  final AssetBundle assetBundle;

  // Konstruktor nimmt das AssetBundle als Abhängigkeit
  CardLoaderService({AssetBundle? assetBundle})
      : assetBundle = assetBundle ?? rootBundle;

  Future<List<CardModel>> loadCards(
      {int? classLevel = 5,
      String? topic = 'all',
      String? wordType = 'all'}) async {
    try {
      final String response =
          await assetBundle.loadString('assets/data/cards.json');
      final List<dynamic> data = jsonDecode(response);

      // Karten erstellen mit Validierung
      List<CardModel> allCards = data.map((item) {
        if (item['pairId'] == null ||
            item['content'] == '' ||
            item['topic'] == '' ||
            item['classLevel'] == null ||
            item['wordType'] == '') {
          throw Exception('Ungültige Karte gefunden: ${item.toString()}');
        }
        return CardModel(
          pairId: item['pairId'],
          content: item['content'],
          isScene: item['isScene'],
          classLevel: item['classLevel'],
          topic: item['topic'],
          wordType: item['wordType'],
        );
      }).toList();

      // Überprüfe, ob jede pairId genau zwei Karten enthält
      final Map<int, List<CardModel>> groupedByPairId = {};
      for (var card in allCards) {
        groupedByPairId.putIfAbsent(card.pairId, () => []);
        groupedByPairId[card.pairId]!.add(card);
      }
      // Filtern: Behalte nur gültige Paare (zwei Karten pro pairId)
      final List<CardModel> validCards = [];
      groupedByPairId.forEach((pairId, cards) {
        if (cards.length == 2 &&
            cards.any((card) => card.isScene == true) &&
            cards.any((card) => card.isScene == false)) {
          validCards.addAll(cards);
        } else {
          log('Ungültiges Paar gefunden: pairId=$pairId');
        }
      });

      // Anwenden von Filtern, falls Parameter angegeben sind
      if (classLevel != null || topic != 'all' || wordType != 'all') {
        return validCards.where((card) {
          final matchesClass =
              classLevel == null || card.classLevel == classLevel;
          final matchesTopic = topic == 'all' || card.topic == topic;
          final matchesWordType =
              wordType == 'all' || card.wordType == wordType;

          return matchesClass && matchesTopic && matchesWordType;
        }).toList();
      }

      return validCards;
    } catch (e, stackTrace) {
      log('Fehler beim Laden der Karten: $e', stackTrace: stackTrace);
      return []; // Rückfall: Leerer Kartenstapel
    }
  }
}
