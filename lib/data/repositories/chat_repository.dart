import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../models/chat_message_model.dart';
import '../services/firebase_service.dart';

/// Chat Repository
/// Handles chat-related data operations
class ChatRepository {
  final FirebaseService _firebaseService = FirebaseService();

  /// Get messages stream for a user
  Stream<List<ChatMessageModel>> getMessagesStream(String userId) {
    try {
      return _firebaseService
          .collection(AppConstants.collectionMessages)
          .doc(userId)
          .collection('chats')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => ChatMessageModel.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      });
    } catch (e) {
      if (kDebugMode) {
        print('Get messages stream error: $e');
      }
      rethrow;
    }
  }

  /// Save message to Firestore
  Future<void> saveMessage(ChatMessageModel message) async {
    try {
      await _firebaseService
          .collection(AppConstants.collectionMessages)
          .doc(message.userId)
          .collection('chats')
          .doc(message.id)
          .set(message.toJson());
    } catch (e) {
      if (kDebugMode) {
        print('Save message error: $e');
      }
      rethrow;
    }
  }

  /// Get recent messages for context (last N messages)
  Future<List<ChatMessageModel>> getRecentMessages(
    String userId,
    int limit,
  ) async {
    try {
      final snapshot = await _firebaseService
          .collection(AppConstants.collectionMessages)
          .doc(userId)
          .collection('chats')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ChatMessageModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    } catch (e) {
      if (kDebugMode) {
        print('Get recent messages error: $e');
      }
      rethrow;
    }
  }

  /// Delete all messages for a user (if needed)
  Future<void> deleteAllMessages(String userId) async {
    try {
      final messagesRef = _firebaseService
          .collection(AppConstants.collectionMessages)
          .doc(userId)
          .collection('chats');

      final snapshot = await messagesRef.get();
      final batch = _firebaseService.firestore.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      if (kDebugMode) {
        print('Delete messages error: $e');
      }
      rethrow;
    }
  }

  /// Check if user has active chat (any messages exist)
  Future<bool> hasActiveChat(String userId) async {
    try {
      final snapshot = await _firebaseService
          .collection(AppConstants.collectionMessages)
          .doc(userId)
          .collection('chats')
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Has active chat error: $e');
      }
      return false;
    }
  }

  /// Get last message for a user
  Future<ChatMessageModel?> getLastMessage(String userId) async {
    try {
      final snapshot = await _firebaseService
          .collection(AppConstants.collectionMessages)
          .doc(userId)
          .collection('chats')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return ChatMessageModel.fromJson({
        'id': snapshot.docs.first.id,
        ...snapshot.docs.first.data(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Get last message error: $e');
      }
      return null;
    }
  }
}

