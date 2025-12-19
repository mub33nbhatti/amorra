import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:amorra/data/models/subscription_model.dart';
import 'package:amorra/data/services/admin_service.dart';
import 'package:amorra/core/constants/app_constants.dart';
import 'package:amorra/presentation/controllers/admin/admin_base_controller.dart';

/// Admin Subscription Controller
/// Handles subscription management operations for admin dashboard
class AdminSubscriptionController extends AdminBaseController {
  final AdminService _adminService = AdminService();

  // State
  final RxList<SubscriptionModel> subscriptions = <SubscriptionModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'all'.obs; // all, active, cancelled, expired

  // Filters
  final RxString filterStatus = 'all'.obs;
  final RxString filterPlanName = 'all'.obs;

  // Total count
  final RxInt totalSubscriptions = 0.obs;

  // Analytics
  final RxMap<String, dynamic> subscriptionAnalytics = <String, dynamic>{}.obs;

  // User info map (userId -> {name, email})
  final RxMap<String, Map<String, String>> userInfo = <String, Map<String, String>>{}.obs;
  
  // Legacy support - keep userEmails for backward compatibility
  Map<String, String> get userEmails {
    final Map<String, String> emails = {};
    userInfo.forEach((userId, info) {
      emails[userId] = info['email'] ?? userId;
    });
    return emails;
  }

  // Stream subscription
  StreamSubscription<List<SubscriptionModel>>? _subscriptionsStreamSubscription;

  @override
  void onInit() {
    super.onInit();
    loadSubscriptionAnalytics();
    _setupFilters();
  }

  @override
  void onClose() {
    _subscriptionsStreamSubscription?.cancel();
    super.onClose();
  }

  /// Setup filters and load subscriptions
  void _setupFilters() {
    // Listen to filter changes
    ever(filterStatus, (_) => loadSubscriptions());
    ever(filterPlanName, (_) => loadSubscriptions());
    ever(searchQuery, (_) => _handleSearch());

    // Initial load
    loadSubscriptions();
  }

  /// Load subscriptions with current filters
  void loadSubscriptions() {
    try {
      setLoading(true);

      // Cancel existing stream
      _subscriptionsStreamSubscription?.cancel();

      // Build filters
      String? status;
      if (filterStatus.value != 'all') {
        status = filterStatus.value;
      } else if (selectedFilter.value != 'all') {
        status = selectedFilter.value;
      }

      String? planName;
      if (filterPlanName.value != 'all') {
        planName = filterPlanName.value;
      }

      // Setup stream
      _subscriptionsStreamSubscription = _adminService
          .getSubscriptionsStream(
            status: status,
            planName: planName,
          )
          .listen(
            (subscriptionList) {
              // Apply search filter if any
              if (searchQuery.value.isNotEmpty) {
                final query = searchQuery.value.toLowerCase();
                subscriptions.value = subscriptionList.where((sub) {
                  return sub.id.toLowerCase().contains(query) ||
                      sub.userId.toLowerCase().contains(query) ||
                      (sub.stripeSubscriptionId?.toLowerCase().contains(query) ?? false) ||
                      (sub.stripeCustomerId?.toLowerCase().contains(query) ?? false);
                }).toList();
              } else {
                subscriptions.value = subscriptionList;
              }

              totalSubscriptions.value = subscriptions.length;
              
              // Load user info (name and email) for subscriptions
              // Don't await - let it load in background and update UI reactively
              // Call it immediately to start fetching
              _loadUserInfo(subscriptionList).catchError((e) {
                if (kDebugMode) {
                  print('Error in _loadUserInfo: $e');
                }
              });
              
              setLoading(false);
            },
            onError: (error) {
              setError(error.toString());
              setLoading(false);
              showError('Failed to load subscriptions', subtitle: error.toString());
            },
          );
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      showError('Failed to load subscriptions', subtitle: e.toString());
    }
  }

  /// Handle search
  void _handleSearch() {
    if (searchQuery.value.isEmpty) {
      loadSubscriptions();
    } else {
      // Filter existing subscriptions
      final query = searchQuery.value.toLowerCase();
      subscriptions.value = subscriptions.where((sub) {
        return sub.id.toLowerCase().contains(query) ||
            sub.userId.toLowerCase().contains(query) ||
            (sub.stripeSubscriptionId?.toLowerCase().contains(query) ?? false) ||
            (sub.stripeCustomerId?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
  }

  /// Update subscription
  Future<bool> updateSubscription(
    String subscriptionId,
    Map<String, dynamic> updates,
  ) async {
    try {
      setLoading(true);
      await _adminService.updateSubscription(subscriptionId, updates);
      setLoading(false);
      showSuccess('Subscription updated successfully');
      loadSubscriptions(); // Refresh list
      return true;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      showError('Failed to update subscription', subtitle: e.toString());
      return false;
    }
  }

  /// Cancel subscription
  Future<bool> cancelSubscription(String subscriptionId, {String? reason}) async {
    try {
      setLoading(true);
      await _adminService.cancelSubscription(subscriptionId, reason: reason);
      setLoading(false);
      showSuccess('Subscription cancelled successfully');
      loadSubscriptions(); // Refresh list
      loadSubscriptionAnalytics(); // Refresh analytics
      return true;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      showError('Failed to cancel subscription', subtitle: e.toString());
      return false;
    }
  }

  /// Reactivate subscription
  Future<bool> reactivateSubscription(String subscriptionId) async {
    try {
      setLoading(true);
      await _adminService.reactivateSubscription(subscriptionId);
      setLoading(false);
      showSuccess('Subscription reactivated successfully');
      loadSubscriptions(); // Refresh list
      loadSubscriptionAnalytics(); // Refresh analytics
      return true;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      showError('Failed to reactivate subscription', subtitle: e.toString());
      return false;
    }
  }

  /// Load subscription analytics
  Future<void> loadSubscriptionAnalytics() async {
    try {
      final analytics = await _adminService.getSubscriptionAnalytics();
      subscriptionAnalytics.value = analytics;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading subscription analytics: $e');
      }
    }
  }

  /// Set filter
  void setFilter(String filter) {
    selectedFilter.value = filter;
    loadSubscriptions();
  }

  /// Load user info (name and email) for subscriptions
  Future<void> _loadUserInfo(List<SubscriptionModel> subscriptionList) async {
    try {
      // Get unique user IDs
      final uniqueUserIds = subscriptionList
          .map((sub) => sub.userId)
          .where((userId) => userId.isNotEmpty)
          .toSet()
          .toList();

      if (uniqueUserIds.isEmpty) return;

      // Get current userInfo snapshot to check what we already have
      final currentUserInfo = Map<String, Map<String, String>>.from(userInfo);
      
      // Filter out users we already have complete info for
      final userIdsToFetch = uniqueUserIds
          .where((userId) {
            final existingInfo = currentUserInfo[userId];
            // Fetch if we don't have info, or if name/email is missing or is '-'
            return existingInfo == null || 
                   existingInfo['name'] == null || 
                   existingInfo['name'] == '-' ||
                   existingInfo['email'] == null || 
                   existingInfo['email'] == '-';
          })
          .toList();

      if (userIdsToFetch.isEmpty) return;

      // Start with current userInfo to preserve existing data
      final Map<String, Map<String, String>> newUserInfo = Map.from(currentUserInfo);
      
      // Fetch user info in batches and update reactively as we go
      for (final userId in userIdsToFetch) {
        try {
          final user = await _adminService.getUserById(userId);
          if (user != null && user.name.isNotEmpty) {
            newUserInfo[userId] = {
              'name': user.name,
              'email': user.email ?? '-',
            };
          } else {
            // Fallback to '-' if user not found
            newUserInfo[userId] = {
              'name': '-',
              'email': '-',
            };
          }
          
          // Update reactively after each fetch to show data as it loads
          userInfo.value = Map.from(newUserInfo);
          userInfo.refresh(); // Ensure reactivity is triggered
        } catch (e) {
          if (kDebugMode) {
            print('Error fetching user info for $userId: $e');
          }
          // Fallback to '-' on error
          newUserInfo[userId] = {
            'name': '-',
            'email': '-',
          };
          // Update reactively even on error
          userInfo.value = Map.from(newUserInfo);
          userInfo.refresh(); // Ensure reactivity is triggered
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user info: $e');
      }
    }
  }

  /// Get user email by userId
  String getUserEmail(String userId) {
    return userInfo[userId]?['email'] ?? '-';
  }

  /// Get user name by userId
  String getUserName(String userId) {
    return userInfo[userId]?['name'] ?? '-';
  }

  /// Get user display text (name and email)
  String getUserDisplayText(String userId) {
    final info = userInfo[userId];
    if (info == null) return '-';
    final name = info['name'] ?? '-';
    final email = info['email'] ?? '-';
    if (email == '-' || email == userId) {
      return name;
    }
    return '$name ($email)';
  }

  /// Get status badge color
  String getStatusBadgeColor(String status) {
    switch (status) {
      case AppConstants.subscriptionStatusActive:
        return 'green';
      case AppConstants.subscriptionStatusCancelled:
        return 'red';
      case AppConstants.subscriptionStatusExpired:
        return 'orange';
      default:
        return 'gray';
    }
  }
}

