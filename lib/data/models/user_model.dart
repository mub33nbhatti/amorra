import 'package:amorra/data/models/base_model.dart';

/// User Model
/// Represents user data structure
class UserModel extends BaseModel {
  final String id;
  final String? email;
  final String name;
  final int? age;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isSubscribed;
  final String subscriptionStatus;
  final bool isAgeVerified;
  final bool isOnboardingCompleted;
  final bool isBlocked;
  final String? profileImageUrl;

  UserModel({
    required this.id,
    this.email,
    required this.name,
    this.age,
    required this.createdAt,
    this.updatedAt,
    this.isSubscribed = false,
    this.subscriptionStatus = 'free',
    this.isAgeVerified = false,
    this.isOnboardingCompleted = false,
    this.isBlocked = false,
    this.profileImageUrl,
  });

  /// Create UserModel from Firestore document
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['uid'] ?? '',
      email: json['email'],
      name: json['name'] ?? '',
      age: json['age'],
      createdAt: json['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: json['updatedAt']?.toDate(),
      isSubscribed: json['isSubscribed'] ?? false,
      subscriptionStatus: json['subscriptionStatus'] ?? 'free',
      isAgeVerified: json['isAgeVerified'] ?? false,
      isOnboardingCompleted: json['isOnboardingCompleted'] ?? false,
      isBlocked: json['isBlocked'] ?? false,
      profileImageUrl: json['profileImageUrl'],
      // Note: preferences are stored in a subcollection, not in the user document
    );
  }

  /// Convert UserModel to JSON for Firestore
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'age': age,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? DateTime.now(),
      'isSubscribed': isSubscribed,
      'subscriptionStatus': subscriptionStatus,
      'isAgeVerified': isAgeVerified,
      'isOnboardingCompleted': isOnboardingCompleted,
      'isBlocked': isBlocked,
      'profileImageUrl': profileImageUrl,
      // Note: preferences are stored in a subcollection, not in the user document
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    int? age,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSubscribed,
    String? subscriptionStatus,
    bool? isAgeVerified,
    bool? isOnboardingCompleted,
    bool? isBlocked,
    String? profileImageUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      age: age ?? this.age,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      isAgeVerified: isAgeVerified ?? this.isAgeVerified,
      isOnboardingCompleted:
          isOnboardingCompleted ?? this.isOnboardingCompleted,
      isBlocked: isBlocked ?? this.isBlocked,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  @override
  BaseModel fromJson(Map<String, dynamic> json) {
    return UserModel.fromJson(json);
  }
}
