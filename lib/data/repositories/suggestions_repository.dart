import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../models/daily_suggestion_model.dart';
import '../services/firebase_service.dart';

/// Suggestions Repository
/// Handles daily suggestions data operations from Firestore
class SuggestionsRepository {
  final FirebaseService _firebaseService = FirebaseService();

  /// Get active daily suggestions stream
  /// Returns a stream of active suggestions sorted by priority then createdAt
  Stream<List<DailySuggestionModel>> getActiveSuggestionsStream() {
    try {
      return _firebaseService
          .collection(AppConstants.collectionDailySuggestions)
          .where('isActive', isEqualTo: true)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isEmpty) {
          if (kDebugMode) {
            print('ℹ️ No active suggestions found in Firestore');
          }
          return <DailySuggestionModel>[];
        }

        final suggestions = snapshot.docs
            .map((doc) {
              try {
                final data = doc.data() as Map<String, dynamic>;
                return DailySuggestionModel.fromJson({
                  'id': doc.id,
                  ...data,
                });
              } catch (e) {
                if (kDebugMode) {
                  print('❌ Error parsing suggestion ${doc.id}: $e');
                }
                return null;
              }
            })
            .whereType<DailySuggestionModel>()
            .toList();

        // Sort by priority (high > medium > low), then by createdAt (oldest first)
        suggestions.sort((a, b) {
          // First sort by priority
          final priorityCompare = a.priority.sortOrder.compareTo(b.priority.sortOrder);
          if (priorityCompare != 0) {
            return priorityCompare;
          }
          // If same priority, sort by createdAt (oldest first)
          return a.createdAt.compareTo(b.createdAt);
        });

        if (kDebugMode) {
          print('✅ Stream update: ${suggestions.length} active suggestions');
          print('   Priority breakdown: ${_getPriorityBreakdown(suggestions)}');
        }

        return suggestions;
      }).handleError((error) {
        if (kDebugMode) {
          print('❌ Stream error: $error');
          if (error.toString().contains('index') || error.toString().contains('PERMISSION')) {
            print('⚠️ Firestore index or permission issue!');
            print('   Check: 1) Firestore rules allow read access');
            print('         2) All documents have required fields');
          }
        }
        // Re-throw to let controller handle it
        throw error;
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get active suggestions stream error: $e');
      }
      // Return empty stream on error
      return Stream.value(<DailySuggestionModel>[]);
    }
  }

  /// Get priority breakdown for debugging
  String _getPriorityBreakdown(List<DailySuggestionModel> suggestions) {
    final high = suggestions.where((s) => s.priority == SuggestionPriority.high).length;
    final medium = suggestions.where((s) => s.priority == SuggestionPriority.medium).length;
    final low = suggestions.where((s) => s.priority == SuggestionPriority.low).length;
    return 'High: $high, Medium: $medium, Low: $low';
  }

  /// Get active daily suggestions (one-time fetch)
  /// Returns list of active suggestions sorted by priority then createdAt
  Future<List<DailySuggestionModel>> getActiveSuggestions() async {
    try {
      final snapshot = await _firebaseService
          .collection(AppConstants.collectionDailySuggestions)
          .where('isActive', isEqualTo: true)
          .get();

      final suggestions = snapshot.docs
          .map((doc) {
            try {
              final data = doc.data() as Map<String, dynamic>;
              return DailySuggestionModel.fromJson({
                'id': doc.id,
                ...data,
              });
            } catch (e) {
              if (kDebugMode) {
                print('❌ Error parsing suggestion ${doc.id}: $e');
              }
              return null;
            }
          })
          .whereType<DailySuggestionModel>()
          .toList();

      // Sort by priority (high > medium > low), then by createdAt (oldest first)
      suggestions.sort((a, b) {
        // First sort by priority
        final priorityCompare = a.priority.sortOrder.compareTo(b.priority.sortOrder);
        if (priorityCompare != 0) {
          return priorityCompare;
        }
        // If same priority, sort by createdAt (oldest first)
        return a.createdAt.compareTo(b.createdAt);
      });

      if (kDebugMode) {
        print('✅ Fetched ${suggestions.length} active suggestions');
      }

      return suggestions;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get active suggestions error: $e');
      }
      rethrow;
    }
  }

  /// Get all suggestions (including inactive) - for admin use
  /// Returns list sorted by priority then createdAt
  Future<List<DailySuggestionModel>> getAllSuggestions() async {
    try {
      final snapshot = await _firebaseService
          .collection(AppConstants.collectionDailySuggestions)
          .get();

      final suggestions = snapshot.docs
          .map((doc) {
            try {
              final data = doc.data() as Map<String, dynamic>;
              return DailySuggestionModel.fromJson({
                'id': doc.id,
                ...data,
              });
            } catch (e) {
              if (kDebugMode) {
                print('❌ Error parsing suggestion ${doc.id}: $e');
              }
              return null;
            }
          })
          .whereType<DailySuggestionModel>()
          .toList();

      // Sort by priority (high > medium > low), then by createdAt (oldest first)
      suggestions.sort((a, b) {
        final priorityCompare = a.priority.sortOrder.compareTo(b.priority.sortOrder);
        if (priorityCompare != 0) {
          return priorityCompare;
        }
        return a.createdAt.compareTo(b.createdAt);
      });

      return suggestions;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get all suggestions error: $e');
      }
      rethrow;
    }
  }

  /// Create a new suggestion - for admin use
  /// If id is provided, uses that; otherwise Firestore auto-generates
  /// Timestamps are automatically set by Firestore server
  Future<String> createSuggestion(DailySuggestionModel suggestion) async {
    try {
      final json = suggestion.toJson();
      // Remove id from JSON as it's the document ID
      json.remove('id');
      
      // Use serverTimestamp for createdAt and updatedAt (auto-set by Firestore)
      json['createdAt'] = FieldValue.serverTimestamp();
      json['updatedAt'] = FieldValue.serverTimestamp();

      DocumentReference docRef;
      if (suggestion.id.isNotEmpty) {
        docRef = _firebaseService
            .collection(AppConstants.collectionDailySuggestions)
            .doc(suggestion.id);
      } else {
        docRef = _firebaseService
            .collection(AppConstants.collectionDailySuggestions)
            .doc();
      }

      await docRef.set(json);

      if (kDebugMode) {
        print('✅ Created suggestion: ${docRef.id}');
      }

      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Create suggestion error: $e');
      }
      rethrow;
    }
  }

  /// Update a suggestion - for admin use
  /// updatedAt is automatically set by Firestore server
  Future<void> updateSuggestion(DailySuggestionModel suggestion) async {
    try {
      final json = suggestion.toJson();
      // Remove id from JSON as it's the document ID
      json.remove('id');
      // Remove createdAt (should not be updated)
      json.remove('createdAt');
      // Use serverTimestamp for updatedAt (auto-set by Firestore)
      json['updatedAt'] = FieldValue.serverTimestamp();

      await _firebaseService
          .collection(AppConstants.collectionDailySuggestions)
          .doc(suggestion.id)
          .update(json);

      if (kDebugMode) {
        print('✅ Updated suggestion: ${suggestion.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Update suggestion error: $e');
      }
      rethrow;
    }
  }

  /// Delete a suggestion - for admin use
  Future<void> deleteSuggestion(String suggestionId) async {
    try {
      await _firebaseService
          .collection(AppConstants.collectionDailySuggestions)
          .doc(suggestionId)
          .delete();

      if (kDebugMode) {
        print('✅ Deleted suggestion: $suggestionId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Delete suggestion error: $e');
      }
      rethrow;
    }
  }

  /// Toggle suggestion active status - for admin use
  /// updatedAt is automatically set by Firestore server
  Future<void> toggleSuggestionActive(String suggestionId, bool isActive) async {
    try {
      await _firebaseService
          .collection(AppConstants.collectionDailySuggestions)
          .doc(suggestionId)
          .update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('✅ Toggled suggestion $suggestionId to $isActive');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Toggle suggestion error: $e');
      }
      rethrow;
    }
  }

  /// Update suggestion priority - for admin use
  /// updatedAt is automatically set by Firestore server
  Future<void> updateSuggestionPriority(
    String suggestionId,
    SuggestionPriority priority,
  ) async {
    try {
      await _firebaseService
          .collection(AppConstants.collectionDailySuggestions)
          .doc(suggestionId)
          .update({
        'priority': priority.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('✅ Updated suggestion $suggestionId priority to ${priority.value}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Update suggestion priority error: $e');
      }
      rethrow;
    }
  }
}

