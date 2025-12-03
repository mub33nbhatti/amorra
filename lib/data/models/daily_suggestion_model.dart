/// Daily Suggestion Priority Enum
enum SuggestionPriority {
  high,
  medium,
  low;

  /// Get priority value as string
  String get value {
    switch (this) {
      case SuggestionPriority.high:
        return 'high';
      case SuggestionPriority.medium:
        return 'medium';
      case SuggestionPriority.low:
        return 'low';
    }
  }

  /// Get priority from string
  static SuggestionPriority fromString(String value) {
    switch (value.toLowerCase()) {
      case 'high':
        return SuggestionPriority.high;
      case 'medium':
        return SuggestionPriority.medium;
      case 'low':
        return SuggestionPriority.low;
      default:
        return SuggestionPriority.medium;
    }
  }

  /// Get priority sort order (lower number = higher priority)
  int get sortOrder {
    switch (this) {
      case SuggestionPriority.high:
        return 1;
      case SuggestionPriority.medium:
        return 2;
      case SuggestionPriority.low:
        return 3;
    }
  }
}

/// Daily Suggestion Model
/// Represents a daily suggestion item for the home screen
class DailySuggestionModel {
  final String id; // Firestore document ID
  final String title;
  final String description;
  final String starterMessage;
  final SuggestionPriority priority;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const DailySuggestionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.starterMessage,
    this.priority = SuggestionPriority.medium,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create DailySuggestionModel from Firestore document
  factory DailySuggestionModel.fromJson(Map<String, dynamic> json) {
    return DailySuggestionModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      starterMessage: json['starterMessage'] ?? '',
      priority: json['priority'] != null
          ? SuggestionPriority.fromString(json['priority'])
          : SuggestionPriority.medium,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: json['updatedAt']?.toDate(),
    );
  }

  /// Convert DailySuggestionModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'starterMessage': starterMessage,
      'priority': priority.value,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? DateTime.now(),
    };
  }

  /// Create a copy with updated fields
  DailySuggestionModel copyWith({
    String? id,
    String? title,
    String? description,
    String? starterMessage,
    SuggestionPriority? priority,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailySuggestionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      starterMessage: starterMessage ?? this.starterMessage,
      priority: priority ?? this.priority,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

