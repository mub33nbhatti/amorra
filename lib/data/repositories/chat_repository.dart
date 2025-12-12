import 'package:amorra/core/constants/app_constants.dart';
import 'package:amorra/data/models/chat_message_model.dart';
import 'package:amorra/data/services/firebase_service.dart';
import 'package:flutter/foundation.dart';

/// Chat Repository
/// Handles chat-related data operations
class ChatRepository {
  final FirebaseService _firebaseService = FirebaseService();

  /// Get messages stream for a user
  /// Queries messages collection filtered by userId (root level field)
  Stream<List<ChatMessageModel>> getMessagesStream(String userId) {
    try {
      if (kDebugMode) {
        print('📡 Setting up Firestore stream for userId: $userId');
      }
      
      return _firebaseService
          .collection(AppConstants.collectionMessages)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
            if (kDebugMode) {
              print('📡 Stream snapshot: ${snapshot.docs.length} documents');
            }
            
            return snapshot.docs
                .map(
                  (doc) {
                    try {
                      final data = doc.data() as Map<String, dynamic>? ?? {};
                      if (kDebugMode && data.isEmpty) {
                        print('⚠️ Stream document ${doc.id} has empty data');
                      }
                      return ChatMessageModel.fromJson({
                        'id': doc.id,
                        ...data,
                      });
                    } catch (e) {
                      if (kDebugMode) {
                        print('❌ Error parsing stream document ${doc.id}: $e');
                      }
                      rethrow;
                    }
                  },
                )
                .toList()
              ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
          });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get messages stream error: $e');
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
  /// Queries messages collection filtered by metadata.userId
  Future<List<ChatMessageModel>> getRecentMessages(
    String userId,
    int limit,
  ) async {
    try {
      if (kDebugMode) {
        print('🔍 Querying Firestore for messages with userId: $userId');
      }
      
      final snapshot = await _firebaseService
          .collection(AppConstants.collectionMessages)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      if (kDebugMode) {
        print('📊 Firestore query returned ${snapshot.docs.length} documents');
        if (snapshot.docs.isEmpty) {
          print('⚠️ Query returned 0 documents. Possible issues:');
          print('  1. Firestore security rules might be blocking the query');
          print('  2. Index might not be created correctly');
          print('  3. Field path might be incorrect');
        }
      }

      final messages = snapshot.docs
          .map(
            (doc) {
              try {
                final data = doc.data() as Map<String, dynamic>? ?? {};
                if (kDebugMode && data.isEmpty) {
                  print('⚠️ Document ${doc.id} has empty data');
                }
                final message = ChatMessageModel.fromJson({
                  'id': doc.id,
                  ...data,
                });
                if (kDebugMode) {
                  print('  ✓ Parsed message: ${message.type} - ${message.message.substring(0, message.message.length > 20 ? 20 : message.message.length)}...');
                }
                return message;
              } catch (e) {
                if (kDebugMode) {
                  print('❌ Error parsing document ${doc.id}: $e');
                  print('  Document data: ${doc.data()}');
                }
                rethrow;
              }
            },
          )
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
      if (kDebugMode) {
        print('✅ Successfully parsed ${messages.length} messages');
      }
      
      return messages;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get recent messages error: $e');
        // Check if it's an index error
        if (e.toString().contains('index') || e.toString().contains('Index')) {
          print('⚠️ Firestore index required! Create a composite index for:');
          print('  Collection: messages');
          print('  Fields: metadata.userId (Ascending), metadata.timestamp (Descending)');
        }
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
          .where('userId', isEqualTo: userId)
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
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final data = snapshot.docs.first.data() as Map<String, dynamic>? ?? {};
      return ChatMessageModel.fromJson({
        'id': snapshot.docs.first.id,
        ...data,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Get last message error: $e');
      }
      return null;
    }
  }
}
