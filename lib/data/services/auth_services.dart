import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zoomio_driverzoomio/views/bottom_screens.dart';
import 'package:zoomio_driverzoomio/views/profile_screens/add_profile.dart';

class AuthServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn(); // Initialized GoogleSignIn
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Create account with email and password
  Future<User?> createAccountWithEmail(String email, String password) async {
    try {
      final cred = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      log("Something went wrong: $e");
    }
    return null;
  }

  // Login with email and password
  Future<User?> loginAccountWithEmail(String email, String password) async {
    try {
      final cred = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      log("Something went wrong: $e");
    }
    return null;
  }

  // Sign out
  Future<void> signout() async {
    try {
      await auth.signOut();
      await googleSignIn.signOut(); // Sign out from Google
    } catch (e) {
      log("Error during signout: $e");
    }
  }

  // Reset password
  Future<String> resetPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      return "Mail sent";
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    }
  }

  // Google Sign-in

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Start the Google Sign-In process
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Check if the user successfully signed in
      if (googleUser != null) {
        // Authenticate with Google
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Ensure that the access token and ID token are available
        if (googleAuth.accessToken != null && googleAuth.idToken != null) {
          // Create the credentials for Firebase authentication
          final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          // Sign in to Firebase with the credentials
          UserCredential userCredential =
              await FirebaseAuth.instance.signInWithCredential(credential);

          // After successful login, fetch user data
          String email = googleUser.email;
          String? displayName = googleUser.displayName;
          User? user = FirebaseAuth.instance.currentUser;

          if (user != null) {
            // Check if the profile is complete
            bool isProfileComplete = await checkIfProfileComplete(user.uid);

            // Navigate based on profile completeness
            if (isProfileComplete) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => BottomScreens()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreenTwo(
                    email: email,
                    displayName: displayName,
                  ),
                ),
              );
            }
          } else {
            log("Firebase user is null after Google sign-in.");
          }
        } else {
          log("Google Auth Token is null");
        }
      } else {
        log("Google Sign-In was unsuccessful.");
      }
    } catch (e) {
      log("Google Sign-In failed: ${e.toString()}");

      // Handle specific exceptions to show a meaningful message to the user
      if (e is PlatformException) {
        log("Error Code: ${e.code}");
        log("Error Message: ${e.message}");
        _showErrorDialog(context, "Google Sign-In failed: ${e.message}");
      } else {
        // General error handling
        _showErrorDialog(
            context, "An unknown error occurred. Please try again.");
      }
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

// Helper function to check if the profile is complete (example with Firestore)
  Future<bool> checkIfProfileComplete(String userId) async {
    // You can check if user profile data exists in Firestore, for example:
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      // Check if profile is completed (e.g., a flag in the document)
      bool profileComplete = userDoc.data()?['profileComplete'] ?? false;
      return profileComplete;
    }

    return false;
  }

  Future<void> sendEmailVerificationLink() async {
    try {
      await auth.currentUser?.sendEmailVerification();
    } catch (e) {
      log(e.toString());
    }
  }

  Future<String> getCurrentUserId() async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      log("User is not authenticated.");
      throw Exception("User ID is null");
    }
    return userId;
  }
}
