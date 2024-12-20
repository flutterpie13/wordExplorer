enum Difficulty { easy, medium, hard }

class DifficultyLevel {
  final Difficulty difficulty;
  final int maxPairs;

  DifficultyLevel(this.difficulty) : maxPairs = _getMaxPairs(difficulty);
  // Methode zur Bestimmung der maximalen Paare basierend auf dem Schwierigkeitsgrad
  static int _getMaxPairs(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 4; // 4 Paare
      case Difficulty.medium:
        return 6; // 6 Paare
      case Difficulty.hard:
        return 10; // 10 Paare
    }
  }

  // Check-Match-Logik basierend auf Schwierigkeitsgrad
  bool checkMatch(String word, String sceneDescription, {String? wordType}) {
    switch (difficulty) {
      case Difficulty.easy:
        // Einfach: Nur prüfen, ob Begriffe vorhanden sind
        return word.isNotEmpty && sceneDescription.isNotEmpty;

      case Difficulty.medium:
        // Mittel: Begriffe und Wortart prüfen
        return word.isNotEmpty &&
            sceneDescription.isNotEmpty &&
            wordType != null &&
            wordType.isNotEmpty;

      case Difficulty.hard:
        // Schwer: Nur Matching der Begriffe (Erweiterung möglich)
        return word.isNotEmpty && sceneDescription.isNotEmpty;

      default:
        return false;
    }
  }
}
