class GameOptions {
  final int selectedClass;
  final String selectedTopic;
  final String selectedWordType;
  final String selectedDifficulty;

  GameOptions({
    required this.selectedClass,
    required this.selectedTopic,
    required this.selectedWordType,
    required this.selectedDifficulty,
  });

  GameOptions copyWith({
    int? selectedClass,
    String? selectedTopic,
    String? selectedWordType,
    String? selectedDifficulty,
  }) {
    return GameOptions(
      selectedClass: selectedClass ?? this.selectedClass,
      selectedTopic: selectedTopic ?? this.selectedTopic,
      selectedWordType: selectedWordType ?? this.selectedWordType,
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
    );
  }
}

class GetGameOptions {
  GameOptions getDefaultOptions() {
    return GameOptions(
      selectedClass: 5,
      selectedTopic: 'school',
      selectedWordType: 'all',
      selectedDifficulty: 'easy',
    );
  }
}
