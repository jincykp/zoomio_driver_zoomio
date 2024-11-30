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
      // Get the current user's ID
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('No authenticated user found. Please log in.');
      }

      // Create a new profile model with both ids
      final newDriver = profileModel.copyWith(
          id: userId, // Firestore document ID
          driverId: userId // Authentication user ID
          );

      final driverProfileCollection =
          FirebaseFirestore.instance.collection("driverProfiles");

      // Rest of your existing code remains the same
      // ...
    } catch (e) {
      print('Error saving profile: $e');
      rethrow;
    }
  }

  // Fetch Profile Data
  Future<ProfileModel> getProfileData() async {
    try {
      final String? userId = await getCurrentUserId();
      if (userId == null) {
        throw Exception('No authenticated user found.');
      }

      final driverProfileCollection =
          FirebaseFirestore.instance.collection("driverProfiles");
      final existingDoc = await driverProfileCollection.doc(userId).get();

      if (!existingDoc.exists) {
        throw Exception('No profile found for userId: $userId');
      }

      return ProfileModel.fromMap(existingDoc.data()!);
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  // Update Profile
  Future<void> updateProfile(ProfileModel profile) async {
    try {
      // Debug print to understand the profile being passed
      print('Profile to update: ${profile.toMap()}');

      // Get the current authenticated user ID
      final userId = FirebaseAuth.instance.currentUser?.uid;

      // Ensure we have a valid user ID
      if (userId == null) {
        throw Exception('No authenticated user found');
      }

      // If profile ID is null, use the current user's ID
      final profileId = profile.id ?? userId;

      // Ensure the profile has a valid ID
      if (profileId.isEmpty) {
        throw Exception(
            "Cannot determine profile ID. Authentication may have failed.");
      }

      // Update the profile in Firestore using the determined ID
      await _firestore
          .collection('driverProfiles')
          .doc(profileId)
          .update(profile.toMap());

      print("Profile successfully updated with ID: $profileId");
    } catch (e) {
      print("Failed to update profile: $e");
      rethrow;
    }
  }

  // Fetch Driver's current status (Online/Offline)
  Future<bool> getDriverStatus() async {
    final userId = await getCurrentUserId();
    if (userId == null) throw Exception('No authenticated user');

    try {
      final doc =
          await _firestore.collection('driverProfiles').doc(userId).get();
      if (!doc.exists) {
        throw Exception('No profile found for user');
      }

      return doc.data()?['isOnline'] ??
          false; // Default to false if no status exists
    } catch (e) {
      print('Error fetching driver status: $e');
      rethrow;
    }
  }

  // Update Driver's Availability Status (Online/Offline)
  Future<void> updateDriverStatus(bool isOnline) async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) throw Exception('No authenticated user');

      // Check if the document exists first
      final docRef = _firestore.collection('driverProfiles').doc(userId);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // Document exists, update it
        await docRef.update({'isOnline': isOnline});
        print('Driver status updated');
      } else {
        // Document doesn't exist, handle it (e.g., create a new profile)
        print('Driver profile not found, creating new profile...');
        await _firestore.collection('driverProfiles').add({
          'userId': userId,
          'isOnline': isOnline,
        });
        print('New profile created');
      }
    } catch (e) {
      print('Error updating driver status: $e');
      rethrow;
    }
  }

  // final String? useIdd = FirebaseAuth.instance.currentUser?.uid;
  // saveprofiel({required ProfileModel profileModel}) async {
  //   final driverProfile =
  //       FirebaseFirestore.instance.collection("driverProfileDate");
  //   final newDriver = ProfileModel(
  //       name: profileModel.name,
  //       age: profileModel.age,
  //       contactNumber: profileModel.contactNumber,
  //       experienceYears: profileModel.experienceYears,
  //       id: useIdd,
  //       profileImageUrl: profileModel.profileImageUrl,
  //       licenseImageUrl: profileModel.licenseImageUrl);
  // }
}
