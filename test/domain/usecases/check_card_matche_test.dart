import 'package:flutter_test/flutter_test.dart';
import 'package:word_explorer/domain/usecases/check_card_match.dart';
import 'package:word_explorer/domain/usecases/difficulty_level.dart';
import 'package:word_explorer/domain/entities/card.dart';

void main() {
  group('CheckCardMatch', () {
    late DifficultyLevel difficultyLevel;

    setUp(() {
      difficultyLevel = DifficultyLevel(Difficulty.easy);
    });

    test('should return true for matching pairIds in easy mode', () {
      final useCase = CheckCardMatch(difficultyLevel);

      final card1 = CardModel(
        pairId: 1,
        content: 'dog',
        isScene: false,
        classLevel: 5,
        topic: 'animals',
        wordType: 'noun',
      );

      final card2 = CardModel(
        pairId: 1,
        content: 'A dog runs after the ball.',
        isScene: true,
        classLevel: 5,
        topic: 'animals',
        wordType: 'noun',
      );

      final result = useCase.execute(card1, card2);

      expect(result, true);
    });

    test('should return false for mismatching pairIds in easy mode', () {
      final useCase = CheckCardMatch(difficultyLevel);

      final card1 = CardModel(
        pairId: 1,
        content: 'dog',
        isScene: false,
        classLevel: 5,
        topic: 'animals',
        wordType: 'noun',
      );

      final card2 = CardModel(
        pairId: 2,
        content: 'cat',
        isScene: false,
        classLevel: 5,
        topic: 'animals',
        wordType: 'noun',
      );

      final result = useCase.execute(card1, card2);

      expect(result, false);
    });

    test('should return false for mismatching word types in medium mode', () {
      difficultyLevel = DifficultyLevel(Difficulty.medium);
      final useCase = CheckCardMatch(difficultyLevel);

      final card1 = CardModel(
        pairId: 1,
        content: 'run',
        isScene: false,
        classLevel: 5,
        topic: 'actions',
        wordType: 'verb',
      );

      final card2 = CardModel(
        pairId: 1,
        content: 'run',
        isScene: false,
        classLevel: 5,
        topic: 'actions',
        wordType: 'noun',
      );

      final result = useCase.execute(card1, card2);

      expect(result, false);
    });

    test('should return false for mismatching content in hard mode', () {
      difficultyLevel = DifficultyLevel(Difficulty.hard);
      final useCase = CheckCardMatch(difficultyLevel);

      final card1 = CardModel(
        pairId: 1,
        content: 'run',
        isScene: false,
        classLevel: 5,
        topic: 'actions',
        wordType: 'verb',
      );

      final card2 = CardModel(
        pairId: 1,
        content: 'running',
        isScene: false,
        classLevel: 5,
        topic: 'actions',
        wordType: 'verb',
      );

      final result = useCase.execute(card1, card2);

      expect(result, false);
    });
  });
}
