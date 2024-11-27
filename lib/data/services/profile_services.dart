import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zoomio_driverzoomio/data/model/profile_model.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // In your ProfileRepository or ProfileServices
  // Get current user ID
  Future<String?> getCurrentUserId() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    return currentUser?.uid;
  }

  // Save a profile to Firestore
  Future<void> saveProfileData(ProfileModel profile) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user');
      }

      // Explicitly add userId when saving
      final profileWithUserId = profile.copyWith(userId: currentUser.uid);

      // Save to Firestore
      DocumentReference docRef = await _firestore
          .collection('profiles')
          .add(profileWithUserId.toMap());

      // Update the document with its own ID
      final savedProfile = profileWithUserId.copyWith(id: docRef.id);

      print('Profile saved with Firestore ID: ${savedProfile.id}');
      print('Profile saved with User ID: ${savedProfile.userId}');
      print('Name: ${profileWithUserId.name}');
      print('Phone: ${profileWithUserId.contactNumber}');
      print('Profile Image URL: ${profileWithUserId.profileImageUrl}');
      print('User ID: ${profileWithUserId.userId}');
    } catch (e) {
      print('Error saving profile: $e');
      throw e;
    }
  }

  // Fetch a profile from Firestore by ID
  Future<ProfileModel> getProfileData(String userId) async {
    try {
      final query = await _firestore
          .collection('profiles')
          .where('userId', isEqualTo: userId)
          .get();

      if (query.docs.isEmpty) throw Exception('No profile found for user');

      return ProfileModel.fromMap(query.docs.first.data());
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

// Delete a profile from Firestore
  Future<void> deleteProfile(String id) async {
    try {
      await _firestore.collection('profiles').doc(id).delete();

      // Print the ID of the deleted profile
      print("Profile deleted with ID: $id");
    } catch (e) {
      throw Exception("Failed to delete profile: $e");
    }
  }

//update
  Future<void> updateProfile(ProfileModel profile) async {
    try {
      if (profile.id != null) {
        await _firestore
            .collection('profiles')
            .doc(profile.id)
            .update(profile.toMap());

        // Print the updated profile's ID
        print("Profile updated with ID: ${profile.id}");
      } else {
        throw Exception("Profile ID is null. Cannot update profile.");
      }
    } catch (e) {
      throw Exception("Failed to update profile: $e");
    }
  }
}
