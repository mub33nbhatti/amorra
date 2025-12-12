import 'package:amorra/data/models/chat_message_model.dart';
import 'package:amorra/data/repositories/chat_repository.dart';

/// Chat Service
/// Data access service for chat operations
/// Note: Messages are saved by the backend API, this service only handles reading from Firestore
class ChatService {
  final ChatRepository _chatRepository = ChatRepository();

  // Note: sendMessage method removed - messages are saved by the backend API
  // The app only reads messages from Firestore via getMessagesStream and getRecentMessages

  /// Get messages stream
  Stream<List<ChatMessageModel>> getMessagesStream(String userId) {
    return _chatRepository.getMessagesStream(userId);
  }

  /// Get recent messages
  Future<List<ChatMessageModel>> getRecentMessages(
    String userId,
    int limit,
  ) async {
    return await _chatRepository.getRecentMessages(userId, limit);
  }
}

