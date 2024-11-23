import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zoomio_driverzoomio/data/services/auth_services.dart';
import 'package:zoomio_driverzoomio/views/auth_screens/signin_screen.dart';
import 'package:zoomio_driverzoomio/views/custom_widgets/custom_button.dart';
import 'package:zoomio_driverzoomio/views/custom_widgets/password_buttons.dart';
import 'package:zoomio_driverzoomio/views/custom_widgets/textformfields.dart';
import 'package:zoomio_driverzoomio/views/profile_screens/secondprofile.dart';
import 'package:zoomio_driverzoomio/views/styles/app_styles.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final formKey = GlobalKey<FormState>();
  final AuthServices auth = AuthServices();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passWordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool? isChecked = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Sign up",
                  style: Textstyles.blackHead,
                ),
                SizedBox(height: screenHeight * 0.02),
                // Email field
                Profilefields(
                  controller: emailController,
                  hintText: 'Email',
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
                SizedBox(height: screenHeight * 0.012),

                // Password field
                CustomPasswordTextFormFields(
                  hintText: "password",
                  controller: passWordController,
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
                SizedBox(height: screenHeight * 0.012),

                // Confirm Password field
                CustomPasswordTextFormFields(
                  hintText: "confirm password",
                  controller: confirmPasswordController,
                  isConfirmPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    } else if (value != passWordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    LengthLimitingTextInputFormatter(6)
                  ],
                ),
                SizedBox(height: screenHeight * 0.01),

                // Checkbox for Terms of Service
                Row(
                  children: [
                    Checkbox(
                      value: isChecked,
                      activeColor: Colors.green,
                      onChanged: (newBool) {
                        setState(() {
                          isChecked = newBool;
                        });
                      },
                    ),
                    const Expanded(
                      child: Text(
                          "By signing up, you agree to the Terms of service and Privacy policy."),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),

                // Sign Up button
                CustomButtons(
                  text: "Sign up",
                  onPressed: () async {
                    // Check if form is valid and the Terms of Service checkbox is checked
                    if (formKey.currentState!.validate() && isChecked == true) {
                      // Call the function to create an account using the auth instance
                      User? user = await auth.createAccountWithEmail(
                        emailController.text.trim(),
                        passWordController.text.trim(),
                      );

                      if (user != null) {
                        // Navigate to Profile Creation Screen after successful signup
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreenTwo(),
                          ),
                        );
                      } else {
                        // Show error message if account creation failed
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Failed to create account. Please try again.',
                              style: Textstyles.smallTexts,
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else {
                      // Show message if Terms of Service not accepted
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'You must agree to the Terms of Service and Privacy Policy to proceed.',
                            style: Textstyles.smallTexts,
                          ),
                          backgroundColor: ThemeColors.titleColor,
                        ),
                      );
                    }
                  },
                  backgroundColor: ThemeColors.primaryColor,
                  textColor: ThemeColors.textColor,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                ),

                // Divider or "or" section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Expanded(child: Divider(thickness: 1)),
                    Padding(
                      padding: EdgeInsets.all(screenWidth * 0.01),
                      child: const Text("or"),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                // Google Sign-In button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        AuthServices().signInWithGoogle(context);
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 1, color: ThemeColors.textColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.asset(
                          "assets/images/gimage.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  ],
                ),

                // Already have an account? Sign In link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignInScreen()),
                        );
                      },
                      child: const Text("Sign In",
                          style: TextStyle(color: ThemeColors.primaryColor)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
