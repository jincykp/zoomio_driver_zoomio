import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zoomio_driverzoomio/views/profile_screens/secondprofile.dart';

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
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

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

          // Get user details from Firebase (this might be necessary)
          String email = googleUser.email;
          String? displayName = googleUser.displayName;

          // Optionally store user data in a profile or save it to Firestore
          // Example: save user data in Firestore (if needed)
          // await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          //   'email': email,
          //   'displayName': displayName,
          // });

          // After successful sign-in, navigate to ProfileScreenTwo
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreenTwo(
                // Pass user details to ProfileScreenTwo if needed
                email: email,
                displayName: displayName,
              ),
            ),
          );
        } else {
          // Log an error if the authentication tokens are null
          log("Google Auth Token is null");
        }
      } else {
        log("Google Sign-In was unsuccessful");
      }
    } catch (e) {
      // Log any error that occurs during the sign-in process
      log("Google Sign-In failed: ${e.toString()}");
      if (e is PlatformException) {
        log("Error Code: ${e.code}");
        log("Error Message: ${e.message}");
      }
    }
  }

  Future<void> sendEmailVerificationLink() async {
    try {
      await auth.currentUser?.sendEmailVerification();
    } catch (e) {
      log(e.toString());
    }
  }
}
