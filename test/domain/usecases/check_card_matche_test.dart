import 'package:flutter_test/flutter_test.dart';
import 'package:word_explorer/domain/entities/card_pair.dart';
import 'package:word_explorer/domain/usecases/check_card_match.dart';
import 'package:word_explorer/domain/usecases/difficulty_level.dart';

void main() {
  group('CheckCardMatch', () {
    late DifficultyLevel difficultyLevel;

    setUp(() {
      difficultyLevel = DifficultyLevel(Difficulty.easy);
    });

    test('should return true for matching cards in easy mode', () {
      final useCase = CheckCardMatch(difficultyLevel);

      final card1 = CardPair(
        word: 'dog',
        sceneDescription: 'A dog runs after the ball.',
        sceneImagePath: 'assets/images/dog.png',
        wordType: 'Noun',
        category: 'Animals',
      );

      final card2 = CardPair(
        word: 'dog',
        sceneDescription: 'A dog runs after the ball.',
        sceneImagePath: 'assets/images/dog.png',
        wordType: 'Noun',
        category: 'Animals',
      );

      final result = useCase.execute(card1, card2);

      expect(result, true);
    });

    test('should return false for mismatching cards in easy mode', () {
      final useCase = CheckCardMatch(difficultyLevel);

      final card1 = CardPair(
        word: 'dog',
        sceneDescription: 'A dog runs after the ball.',
        sceneImagePath: 'assets/images/dog.png',
        wordType: 'Noun',
        category: 'Animals',
      );

      final card2 = CardPair(
        word: 'cat',
        sceneDescription: 'A cat sleeps on the couch.',
        sceneImagePath: 'assets/images/cat.png',
        wordType: 'Noun',
        category: 'Animals',
      );

      final result = useCase.execute(card1, card2);

      expect(result, false);
    });

    test('should return false for mismatching word types in medium mode', () {
      difficultyLevel = DifficultyLevel(Difficulty.medium);
      final useCase = CheckCardMatch(difficultyLevel);

      final card1 = CardPair(
        word: 'run',
        sceneDescription: 'The dog runs.',
        sceneImagePath: 'assets/images/run.png',
        wordType: 'Verb',
        category: 'Actions',
      );

      final card2 = CardPair(
        word: 'run',
        sceneDescription: 'The dog runs.',
        sceneImagePath: 'assets/images/run.png',
        wordType: 'Noun',
        category: 'Actions',
      );

      final result = useCase.execute(card1, card2);

      expect(result, false);
    });
  });
}
