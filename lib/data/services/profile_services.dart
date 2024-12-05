import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zoomio_driverzoomio/data/model/profile_model.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

      final driverProfileCollection = _firestore.collection("driverProfiles");

      // Add or update the profile using the Firestore document ID as `userId`
      final profileToSave = profileModel.copyWith(id: userId);
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
      final String? userId = await getCurrentUserId();
      if (userId == null) throw Exception('No authenticated user found.');

      final docSnapshot =
          await _firestore.collection('driverProfiles').doc(userId).get();

      if (!docSnapshot.exists) {
        throw Exception('No profile found for userId: $userId');
      }

      // Return the driver's online status or default to `false`
      return docSnapshot.data()?['isOnline'] ?? false;
    } catch (e) {
      print('Error fetching driver status: $e');
      rethrow;
    }
  }

  // Update Driver's Availability Status (Online/Offline)
  Future<void> updateDriverStatus(bool isOnline) async {
    try {
      final String? userId = await getCurrentUserId();
      if (userId == null) throw Exception('No authenticated user found.');

      final docRef = _firestore.collection('driverProfiles').doc(userId);

      await docRef.update({'isOnline': isOnline});
      print('Driver status updated successfully.');
    } catch (e) {
      print('Error updating driver status: $e');
      rethrow;
    }
  }
}
