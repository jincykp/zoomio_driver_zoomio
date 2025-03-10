import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zoomio_driverzoomio/data/services/auth_services.dart';
import 'package:zoomio_driverzoomio/views/auth_screens/forgot_otp_screen.dart';
import 'package:zoomio_driverzoomio/views/auth_screens/signup_screen.dart';
import 'package:zoomio_driverzoomio/views/bottom_screens.dart';
import 'package:zoomio_driverzoomio/views/custom_widgets/custom_button.dart';
import 'package:zoomio_driverzoomio/views/custom_widgets/textformfields.dart';
import 'package:zoomio_driverzoomio/views/styles/app_styles.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final auth = AuthServices();
  final emailController = TextEditingController();
  final passWordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // Removed mainAxisAlignment: MainAxisAlignment.spaceEvenly
            children: [
              SizedBox(height: screenHeight * 0.1), // Added top spacing
              const Text(
                "Sign In",
                style: Textstyles.blackHead,
              ),
              SizedBox(height: screenHeight * 0.04),
              Profilefields(
                controller: emailController,
                hintText: 'Enter your email',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email address';
                  }
                  final bool isValid =
                      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value);
                  if (!isValid) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              SizedBox(height: screenHeight * 0.02),
              Profilefields(
                controller: passWordController,
                hintText: 'Enter your password',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  } else if (value.contains(' ')) {
                    return 'Password cannot contain whitespace';
                  }
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  LengthLimitingTextInputFormatter(6)
                ],
              ),
              // Right-aligned Forget Password button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ClickOtpScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Forget Password?",
                    style: Textstyles.spclTexts,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              CustomButtons(
                text: "Sign In",
                onPressed: logIn,
                backgroundColor: ThemeColors.primaryColor,
                textColor: ThemeColors.textColor,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
              ),
              SizedBox(height: screenHeight * 0.03),
              // Fixed divider with "or" text
              Row(
                children: [
                  const Expanded(
                    child: Divider(
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: const Text("or"),
                  ),
                  const Expanded(
                    child: Divider(
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
              // Centered Google sign-in button
              Center(
                child: GestureDetector(
                  onTap: () {
                    AuthServices().signInWithGoogle(context);
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        "assets/images/gimage.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              // Centered "Don't have an account?" row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Sign up",
                      style: TextStyle(color: ThemeColors.primaryColor),
                    ),
                  )
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  void logIn() async {
    // Check if the email and password fields are not empty
    if (emailController.text.isEmpty || passWordController.text.isEmpty) {
      log("Email and password cannot be empty");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: ThemeColors.titleColor,
          content: Text(
            "Email and password cannot be empty",
            style: Textstyles.smallTexts,
          ),
        ),
      );
      return;
    }

    // Attempt to log in the user
    try {
      final user = await auth.loginAccountWithEmail(
        emailController.text.trim(),
        passWordController.text.trim(),
      );

      // Check if login was successful
      if (user != null) {
        log("User Logged In: ${user.email}");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BottomScreens(
              email: emailController.text,
            ),
          ),
        );
      } else {
        log("Login failed: User is null");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: ThemeColors.alertColor,
            content: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                "Login failed. Please check your email and password.",
                style: Textstyles.smallTexts,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      log("Error during login: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred during login: ${e.toString()}"),
        ),
      );
    }
  }
}
