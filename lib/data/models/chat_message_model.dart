import 'base_model.dart';

/// Chat Message Model
/// Represents a chat message structure
class ChatMessageModel extends BaseModel {
  final String id;
  final String userId;
  final String message;
  final String type; // 'user' or 'ai' or 'system'
  final DateTime timestamp;
  final bool isTyping;
  final Map<String, dynamic>? metadata;

  ChatMessageModel({
    required this.id,
    required this.userId,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isTyping = false,
    this.metadata,
  });

  /// Create ChatMessageModel from Firestore document
  /// Fields are at root level: text, timestamp, type, userId, id, chatSessionId, isTyping
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      message: json['text'] ?? '', // 'text' field contains the message content
      type: json['type'] ?? 'user',
      timestamp: _parseTimestamp(json['timestamp']),
      isTyping: json['isTyping'] as bool? ?? false,
      metadata: json['metadata'], // Keep for backward compatibility, but not used
    );
  }
  
  /// Parse timestamp from various formats
  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    
    // If it's already a DateTime
    if (timestamp is DateTime) {
      return timestamp;
    }
    
    // If it's a Firestore Timestamp object (has toDate method)
    try {
      // Firestore Timestamp objects have a toDate() method
      if (timestamp.toString().contains('Timestamp') || 
          timestamp.runtimeType.toString().contains('Timestamp')) {
        // Use dynamic call to handle Firestore Timestamp
        return (timestamp as dynamic).toDate() as DateTime;
      }
    } catch (e) {
      // If toDate() doesn't work, try other methods
    }
    
    // If it's a Map with _seconds (serialized Firestore Timestamp)
    if (timestamp is Map) {
      if (timestamp.containsKey('_seconds')) {
        final seconds = timestamp['_seconds'] as int?;
        final nanoseconds = timestamp['_nanoseconds'] as int? ?? 0;
        if (seconds != null) {
          return DateTime.fromMillisecondsSinceEpoch(
            seconds * 1000 + (nanoseconds ~/ 1000000),
          );
        }
      }
    }
    
    // Default fallback
    return DateTime.now();
  }

  /// Convert ChatMessageModel to JSON for Firestore
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'message': message,
      'type': type,
      'timestamp': timestamp,
      'isTyping': isTyping,
      'metadata': metadata,
    };
  }

  /// Create a copy with updated fields
  ChatMessageModel copyWith({
    String? id,
    String? userId,
    String? message,
    String? type,
    DateTime? timestamp,
    bool? isTyping,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isTyping: isTyping ?? this.isTyping,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  BaseModel fromJson(Map<String, dynamic> json) {
    return ChatMessageModel.fromJson(json);
  }
}

