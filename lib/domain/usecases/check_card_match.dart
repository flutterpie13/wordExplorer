import '../entities/card.dart';
import 'difficulty_level.dart';

class CheckCardMatch {
  final DifficultyLevel difficultyLevel;

  CheckCardMatch(this.difficultyLevel);

  bool execute(CardModel card1, CardModel card2) {
    // Überprüfe das Matching basierend auf der Schwierigkeit
    if (difficultyLevel.difficulty == Difficulty.easy) {
      return card1.pairId == card2.pairId;
    } else if (difficultyLevel.difficulty == Difficulty.medium) {
      return card1.pairId == card2.pairId && card1.wordType == card2.wordType;
    } else if (difficultyLevel.difficulty == Difficulty.hard) {
      return card1.pairId == card2.pairId &&
          card1.wordType == card2.wordType &&
          card1.content != card2.content; // Zusätzliche Logik für Hard
    }
    return false;
  }
}
