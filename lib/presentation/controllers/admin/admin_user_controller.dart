import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:amorra/data/models/user_model.dart';
import 'package:amorra/data/services/admin_service.dart';
import 'package:amorra/presentation/controllers/admin/admin_base_controller.dart';

/// Admin User Controller
/// Handles user management operations for admin dashboard
class AdminUserController extends AdminBaseController {
  final AdminService _adminService = AdminService();

  // State
  final RxList<UserModel> users = <UserModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter =
      'all'.obs; // all, blocked, active, subscribed, free

  // Filters
  final RxBool filterBlocked = false.obs;
  final RxString filterSubscriptionStatus = 'all'.obs;
  final RxBool filterOnboardingCompleted = false.obs;
  final RxBool filterAgeVerified = false.obs;

  // Total count
  final RxInt totalUsers = 0.obs;

  // Analytics
  final RxMap<String, dynamic> userAnalytics = <String, dynamic>{}.obs;

  // Stream subscription
  StreamSubscription<List<UserModel>>? _usersStreamSubscription;

  @override
  void onInit() {
    super.onInit();
    loadUserAnalytics();
    _setupFilters();
  }

  @override
  void onClose() {
    _usersStreamSubscription?.cancel();
    super.onClose();
  }

  /// Setup filters and load users
  void _setupFilters() {
    // Listen to filter changes
    ever(filterBlocked, (_) => loadUsers());
    ever(filterSubscriptionStatus, (_) => loadUsers());
    ever(filterOnboardingCompleted, (_) => loadUsers());
    ever(filterAgeVerified, (_) => loadUsers());
    ever(searchQuery, (_) => _handleSearch());

    // Initial load
    loadUsers();
  }

  /// Load users with current filters
  void loadUsers() {
    try {
      setLoading(true);

      // Cancel existing stream
      _usersStreamSubscription?.cancel();

      // Build filters
      bool? isBlocked;
      if (filterBlocked.value) {
        isBlocked = true;
      } else if (selectedFilter.value == 'blocked') {
        isBlocked = true;
      } else if (selectedFilter.value == 'active') {
        isBlocked = false;
      }

      String? subscriptionStatus;
      if (filterSubscriptionStatus.value != 'all') {
        subscriptionStatus = filterSubscriptionStatus.value;
      } else if (selectedFilter.value == 'subscribed') {
        subscriptionStatus = 'active';
      } else if (selectedFilter.value == 'free') {
        subscriptionStatus = 'free';
      }

      bool? isOnboardingCompleted;
      if (filterOnboardingCompleted.value) {
        isOnboardingCompleted = true;
      }

      bool? isAgeVerified;
      if (filterAgeVerified.value) {
        isAgeVerified = true;
      }

      // Setup stream
      _usersStreamSubscription = _adminService
          .getUsersStream(
            isBlocked: isBlocked,
            subscriptionStatus: subscriptionStatus,
            isOnboardingCompleted: isOnboardingCompleted,
            isAgeVerified: isAgeVerified,
          )
          .listen(
            (userList) {
              // Apply search filter if any
              if (searchQuery.value.isNotEmpty) {
                final query = searchQuery.value.toLowerCase();
                users.value = userList.where((user) {
                  return user.name.toLowerCase().contains(query) ||
                      (user.email?.toLowerCase().contains(query) ?? false) ||
                      user.id.toLowerCase().contains(query);
                }).toList();
              } else {
                users.value = userList;
              }

              totalUsers.value = users.length;
              setLoading(false);
            },
            onError: (error) {
              setError(error.toString());
              setLoading(false);
              showError('Failed to load users', subtitle: error.toString());
            },
          );
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      showError('Failed to load users', subtitle: e.toString());
    }
  }

  /// Handle search
  void _handleSearch() {
    if (searchQuery.value.isEmpty) {
      loadUsers();
    } else {
      // Filter existing users
      final query = searchQuery.value.toLowerCase();
      users.value = users.where((user) {
        return user.name.toLowerCase().contains(query) ||
            (user.email?.toLowerCase().contains(query) ?? false) ||
            user.id.toLowerCase().contains(query);
      }).toList();
    }
  }

  /// Search users
  Future<void> searchUsers(String query) async {
    try {
      if (query.isEmpty) {
        loadUsers();
        return;
      }

      setLoading(true);
      final results = await _adminService.searchUsers(query);
      users.value = results;
      totalUsers.value = results.length;
      setLoading(false);
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      showError('Search failed', subtitle: e.toString());
    }
  }

  /// Update user
  Future<bool> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      setLoading(true);
      await _adminService.updateUser(userId, updates);
      setLoading(false);
      showSuccess('User updated successfully');
      loadUsers(); // Refresh list
      return true;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      showError('Failed to update user', subtitle: e.toString());
      return false;
    }
  }

  /// Block user
  Future<bool> blockUser(String userId, {String? reason}) async {
    // Optimistically update the local list for immediate UI feedback
    final userIndex = users.indexWhere((u) => u.id == userId);
    bool wasUpdated = false;
    
    if (userIndex != -1) {
      final updatedUser = users[userIndex].copyWith(isBlocked: true);
      users[userIndex] = updatedUser;
      users.refresh(); // Ensure reactivity
      wasUpdated = true;
    }
    
    try {
      await _adminService.blockUser(userId, reason: reason);
      showSuccess('User blocked successfully');
      // Stream subscription will automatically update the list in real-time
      // The stream update will confirm the optimistic update
      return true;
    } catch (e) {
      // Revert optimistic update on error
      if (wasUpdated && userIndex != -1) {
        final revertedUser = users[userIndex].copyWith(isBlocked: false);
        users[userIndex] = revertedUser;
        users.refresh();
      }
      setError(e.toString());
      showError('Failed to block user', subtitle: e.toString());
      return false;
    }
  }

  /// Unblock user
  Future<bool> unblockUser(String userId) async {
    // Optimistically update the local list for immediate UI feedback
    final userIndex = users.indexWhere((u) => u.id == userId);
    bool wasUpdated = false;
    
    if (userIndex != -1) {
      final updatedUser = users[userIndex].copyWith(isBlocked: false);
      users[userIndex] = updatedUser;
      users.refresh(); // Ensure reactivity
      wasUpdated = true;
    }
    
    try {
      await _adminService.unblockUser(userId);
      showSuccess('User unblocked successfully');
      // Stream subscription will automatically update the list in real-time
      // The stream update will confirm the optimistic update
      return true;
    } catch (e) {
      // Revert optimistic update on error
      if (wasUpdated && userIndex != -1) {
        final revertedUser = users[userIndex].copyWith(isBlocked: true);
        users[userIndex] = revertedUser;
        users.refresh();
      }
      setError(e.toString());
      showError('Failed to unblock user', subtitle: e.toString());
      return false;
    }
  }

  /// Load user analytics
  Future<void> loadUserAnalytics() async {
    try {
      final analytics = await _adminService.getUserAnalytics();
      userAnalytics.value = analytics;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user analytics: $e');
      }
    }
  }

  /// Set filter
  void setFilter(String filter) {
    selectedFilter.value = filter;
    loadUsers();
  }

}
