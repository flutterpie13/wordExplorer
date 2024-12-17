import 'topic_model.dart';

class ClassLevel {
  final int level;
  final List<Topic> topics;

  ClassLevel({
    required this.level,
    required this.topics,
  });

  factory ClassLevel.fromJson(Map<String, dynamic> json) {
    return ClassLevel(
      level: json['classLevel'],
      topics: (json['topics'] as List)
          .map((topicJson) => Topic.fromJson(topicJson))
          .toList(),
    );
  }
}
