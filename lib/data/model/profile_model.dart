import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileModel {
  final String? id;
  final String name;
  final int age;
  final String contactNumber;
  final String? gender;
  final String? vehiclePreference;
  final int experienceYears;
  final String? profileImageUrl;
  final String? licenseImageUrl;
  final int cancelCount;
  final DateTime? lastCancellationDate;
  final bool isBlocked;

  ProfileModel({
    this.id,
    required this.name,
    required this.age,
    required this.contactNumber,
    this.gender,
    this.vehiclePreference,
    required this.experienceYears,
    this.profileImageUrl,
    this.licenseImageUrl,
    this.cancelCount = 0,
    this.lastCancellationDate,
    this.isBlocked = false,
  });

  // Create ProfileModel from Map (usually from Firestore)
  factory ProfileModel.fromMap(Map<String, dynamic> map,
      {required String docId}) {
    return ProfileModel(
      id: docId,
      name: map['name'] as String,
      age: map['age'] as int,
      contactNumber: map['contactNumber'] as String,
      gender: map['gender'] as String?,
      vehiclePreference: map['vehiclePreference'] as String?,
      experienceYears: map['experienceYears'] as int,
      profileImageUrl: map['profileImageUrl'] as String?,
      licenseImageUrl: map['licenseImageUrl'] as String?,
      cancelCount: map['cancelCount'] as int? ?? 0,
      lastCancellationDate: map['lastCancellationDate'] != null
          ? (map['lastCancellationDate'] as Timestamp).toDate()
          : null,
      isBlocked: map['isBlocked'] as bool? ?? false,
    );
  }

  // Create ProfileModel from Firestore DocumentSnapshot
  factory ProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProfileModel.fromMap(data, docId: doc.id);
  }

  // Convert ProfileModel to Map for storing in Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'contactNumber': contactNumber,
      'gender': gender,
      'vehiclePreference': vehiclePreference,
      'experienceYears': experienceYears,
      'profileImageUrl': profileImageUrl,
      'licenseImageUrl': licenseImageUrl,
      'cancelCount': cancelCount,
      'lastCancellationDate': lastCancellationDate != null
          ? Timestamp.fromDate(lastCancellationDate!)
          : null,
      'isBlocked': isBlocked,
    };
  }

  // Check if cancel count should reset (new day)
  bool shouldResetCancelCount() {
    if (lastCancellationDate == null) return true;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCancel = DateTime(lastCancellationDate!.year,
        lastCancellationDate!.month, lastCancellationDate!.day);

    return today.isAfter(lastCancel); // Returns true if it's a new day
  }

  // Increment cancel count and check for blocking
  ProfileModel incrementCancelCount() {
    final now = DateTime.now();
    int newCount = shouldResetCancelCount() ? 1 : cancelCount + 1;
    bool shouldBlock = newCount >= 2; // Block after 2 cancellations

    return copyWith(
      cancelCount: newCount,
      lastCancellationDate: now,
      isBlocked: shouldBlock, // Set blocked status based on cancel count
    );
  }

  // Create a copy of ProfileModel with optional new values
  ProfileModel copyWith({
    String? id,
    String? name,
    int? age,
    String? contactNumber,
    String? gender,
    String? vehiclePreference,
    int? experienceYears,
    String? profileImageUrl,
    String? licenseImageUrl,
    int? cancelCount,
    DateTime? lastCancellationDate,
    bool? isBlocked,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      contactNumber: contactNumber ?? this.contactNumber,
      gender: gender ?? this.gender,
      vehiclePreference: vehiclePreference ?? this.vehiclePreference,
      experienceYears: experienceYears ?? this.experienceYears,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      licenseImageUrl: licenseImageUrl ?? this.licenseImageUrl,
      cancelCount: cancelCount ?? this.cancelCount,
      lastCancellationDate: lastCancellationDate ?? this.lastCancellationDate,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }

  // Add a method to unblock the driver (for admin use)
  ProfileModel unblock() {
    return copyWith(
      isBlocked: false,
      cancelCount: 0,
      lastCancellationDate: null,
    );
  }

  // Add a method to check if driver can accept rides
  bool canAcceptRides() {
    return !isBlocked && (cancelCount < 2 || shouldResetCancelCount());
  }

  // toString method for debugging
  @override
  String toString() {
    return 'ProfileModel(id: $id, name: $name, cancelCount: $cancelCount, isBlocked: $isBlocked)';
  }
}
