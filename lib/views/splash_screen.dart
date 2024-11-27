import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zoomio_driverzoomio/views/auth_screens/signup_screen.dart';
import 'package:zoomio_driverzoomio/views/bottom_screens.dart';
import 'package:zoomio_driverzoomio/views/styles/app_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: ThemeColors.primaryColor,
      body: Center(
        child: Text(
          "zoomio",
          style: TextStyle(
            fontSize: screenWidth * 0.1,
            fontFamily: "FamilyGuy",
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  /// Check user authentication state and navigate accordingly
  Future<void> _checkAuthentication() async {
    // Simulate a short splash delay
    await Future.delayed(const Duration(seconds: 3));

    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // User is signed in, navigate to BottomScreens
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomScreens()),
      );
    } else {
      // User is not signed in, navigate to SignUpScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignUpScreen()),
      );
    }
  }
}
