import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:zoomio_driverzoomio/data/model/profile_model.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Get current user ID
  Future<String?> getCurrentUserId() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    return currentUser?.uid;
  }

  // Save Profile Data

// When creating or saving a profile, ensure you're setting the ID
  Future<void> saveProfileData({required ProfileModel profileModel}) async {
    try {
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('No authenticated user found. Please log in.');
      }

      // Set the 'id' field of profile to match the Firestore document ID (userId)
      final profileToSave = profileModel.copyWith(id: userId);

      // Save the profile data to Firestore
      final driverProfileCollection = _firestore.collection("driverProfiles");

      // Use the userId as the document ID to ensure consistency
      await driverProfileCollection
          .doc(userId)
          .set(profileToSave.toMap(), SetOptions(merge: true));

      print('Profile saved successfully for userId: $userId');
    } catch (e) {
      print('Error saving profile: $e');
      rethrow;
    }
  }

  // Fetch Profile Data
  Future<ProfileModel> getProfileData({String? docId}) async {
    try {
      // Use the provided docId or fallback to the authenticated user's ID
      final String? userId = docId ?? await getCurrentUserId();
      if (userId == null) {
        throw Exception('No authenticated user found, and no docId provided.');
      }

      final docSnapshot =
          await _firestore.collection('driverProfiles').doc(userId).get();

      if (!docSnapshot.exists) {
        throw Exception('No profile found for userId: $userId');
      }

      // Pass the document ID explicitly to the `fromMap` method
      return ProfileModel.fromMap(docSnapshot.data()!, docId: userId);
    } catch (e) {
      print('Error fetching profile data: $e');
      rethrow;
    }
  }

  // Update Profile
  Future<void> updateProfile(ProfileModel profile) async {
    try {
      final String? userId = await getCurrentUserId();
      if (userId == null) {
        throw Exception('No authenticated user found.');
      }

      await _firestore
          .collection('driverProfiles')
          .doc(userId)
          .update(profile.toMap());

      print("Profile successfully updated for userId: $userId");
    } catch (e) {
      print("Error updating profile: $e");
      rethrow;
    }
  }

  // Fetch Driver's current status (Online/Offline)
  Future<bool> getDriverStatus() async {
    try {
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('No authenticated user found.');
      }

      final driverProfileCollection =
          FirebaseFirestore.instance.collection("driverProfiles");
      final snapshot = await driverProfileCollection.doc(userId).get();

      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data['isOnline'] != null) {
          return data['isOnline'] as bool;
        }
      }

      return false; // Default to offline if status not found
    } catch (e) {
      print('Error fetching driver status: $e');
      return false;
    }
  }

  // Update Driver's Availability Status (Online/Offline)
  Future<void> updateDriverStatus(bool isOnline) async {
    try {
      final String? userId = await getCurrentUserId();
      if (userId == null) throw Exception('No authenticated user found.');

      final docRef = _firestore.collection('driverProfiles').doc(userId);

      // Add more detailed logging
      print('Attempting to update status for user $userId to $isOnline');

      await docRef.update({'isOnline': isOnline});
      print('Driver status successfully updated to $isOnline');
    } catch (e) {
      print('Detailed error updating driver status: $e');
      rethrow;
    }
  }

  // Fetch all drivers' FCM tokens
  Future<List<String>> getAllDriverTokens() async {
    try {
      final querySnapshot = await _firestore.collection('driverProfiles').get();
      List<String> driverTokens = [];

      for (var doc in querySnapshot.docs) {
        // Ensure that 'fcm_token' exists for each driver
        String? token = doc['fcm_token'];
        if (token != null) {
          driverTokens.add(token);
        }
      }

      return driverTokens;
    } catch (e) {
      print('Error fetching all driver tokens: $e');
      rethrow;
    }
  }

  Future<RatingData> getDriverRatings(String driverId) async {
    try {
      print('Fetching ratings for driver: $driverId');

      // Query bookings with feedback for this driver
      final DataSnapshot snapshot = await _database
          .child('bookings')
          .orderByChild('driverId')
          .equalTo(driverId)
          .get();

      if (!snapshot.exists) {
        print('No bookings found for driver');
        return RatingData(average: 0.0, total: 0);
      }

      // Convert snapshot to Map
      final Map<dynamic, dynamic>? bookings =
          snapshot.value as Map<dynamic, dynamic>?;

      if (bookings == null) {
        return RatingData(average: 0.0, total: 0);
      }

      double totalRating = 0;
      int ratingCount = 0;

      // Iterate through bookings to find ratings
      bookings.forEach((key, booking) {
        // Check if booking has feedback and rating
        if (booking is Map &&
            booking['feedback'] != null &&
            booking['complaint'] == true &&
            booking['rating'] != null) {
          totalRating += (booking['rating'] as num).toDouble();
          ratingCount++;
        }
      });

      // Calculate average
      double averageRating = ratingCount > 0 ? totalRating / ratingCount : 0.0;

      print(
          'Calculated ratings - Average: $averageRating, Total: $ratingCount');

      return RatingData(
        average: double.parse(
            averageRating.toStringAsFixed(1)), // Round to 1 decimal
        total: ratingCount,
      );
    } catch (e) {
      print('Error calculating ratings: $e');
      throw Exception('Failed to fetch driver ratings: $e');
    }
  }

  // Helper method to validate rating value
  bool _isValidRating(dynamic rating) {
    if (rating is num) {
      double ratingValue = rating.toDouble();
      return ratingValue >= 0 && ratingValue <= 5;
    }
    return false;
  }
}

class RatingData {
  final double average;
  final int total;

  RatingData({required this.average, required this.total});
}
