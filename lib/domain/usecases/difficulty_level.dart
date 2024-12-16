enum Difficulty { easy, medium, hard }

class DifficultyLevel {
  final Difficulty difficulty;

  DifficultyLevel(this.difficulty);

  bool checkMatch(String word, String sceneDescription, {String? wordType}) {
    switch (difficulty) {
      case Difficulty.easy:
        // Einfach: Nur Begriffe matchen
        return word.isNotEmpty && sceneDescription.isNotEmpty;

      case Difficulty.medium:
        // Mittel: Begriffe und Wortart matchen
        if (wordType == null || wordType.isEmpty) {
          throw ArgumentError(
              'Word type must be provided for medium difficulty');
        }
        return word.isNotEmpty &&
            sceneDescription.isNotEmpty &&
            wordType.isNotEmpty;

      case Difficulty.hard:
        // Schwer: Zusätzliche Aktionen wie Lautlesen/Übersetzen könnten hier ergänzt werden
        // Für jetzt nur Matching der Begriffe
        return word.isNotEmpty && sceneDescription.isNotEmpty;

      default:
        return false;
    }
  }
}
