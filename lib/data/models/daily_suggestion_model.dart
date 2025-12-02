/// Daily Suggestion Model
/// Represents a daily suggestion item for the home screen
class DailySuggestionModel {
  final String id;
  final String title;
  final String description;
  final String starterMessage;

  const DailySuggestionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.starterMessage,
  });

  /// Create a copy with updated fields
  DailySuggestionModel copyWith({
    String? id,
    String? title,
    String? description,
    String? starterMessage,
  }) {
    return DailySuggestionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      starterMessage: starterMessage ?? this.starterMessage,
    );
  }
}

