import 'package:flutter/material.dart';
import 'package:zoomio_driverzoomio/views/auth_screens/signup_screen.dart';
import 'package:zoomio_driverzoomio/views/styles/app_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    gotoLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: ThemeColors.primaryColor,
      body: Center(
          child: Text(
        "zoomio",
        style: TextStyle(
            fontSize: screenWidth * 0.1,
            fontFamily: "FamilyGuy",
            color: Colors.black),
      )),
    );
  }

  Future<void> gotoLogin() async {
    await Future.delayed(const Duration(seconds: 4));
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => SignUpScreen()));
  }
}
