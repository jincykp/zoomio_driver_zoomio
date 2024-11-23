import 'package:flutter/material.dart';
import 'package:zoomio_driverzoomio/data/model/profile_model.dart';
import 'package:zoomio_driverzoomio/data/services/profile_services.dart';

// Import your ProfileRepository

class ProfileProvider with ChangeNotifier {
  ProfileModel? _profile;
  final ProfileRepository _profileRepository =
      ProfileRepository(); // Create an instance of your repository

  ProfileModel? get profile => _profile;

  // Fetch a profile by ID
  Future<void> fetchProfile(String id) async {
    try {
      _profile =
          await _profileRepository.fetchProfile(id); // Fetch profile data
      notifyListeners(); // Notify listeners after fetching data
    } catch (error) {
      print("Error fetching profile: $error"); // Handle errors
    }
  }

  // Save a new profile
  Future<void> saveProfile(ProfileModel profile) async {
    try {
      await _profileRepository.saveProfileData(profile); // Save profile data
      _profile = profile; // Update local profile state
      notifyListeners(); // Notify listeners
    } catch (error) {
      print("Error saving profile: $error"); // Handle errors
    }
  }

  // Update an existing profile
  Future<void> updateProfile(ProfileModel profile) async {
    try {
      await _profileRepository.updateProfile(profile); // Update profile data
      _profile = profile; // Update local profile state
      notifyListeners(); // Notify listeners
    } catch (error) {
      print("Error updating profile: $error"); // Handle errors
    }
  }

  // Delete a profile
  Future<void> deleteProfile(String id) async {
    try {
      await _profileRepository.deleteProfile(id); // Delete profile data
      _profile = null; // Clear local profile state
      notifyListeners(); // Notify listeners
    } catch (error) {
      print("Error deleting profile: $error"); // Handle errors
    }
  }
}
