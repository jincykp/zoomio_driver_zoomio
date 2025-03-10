import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zoomio_driverzoomio/data/services/auth_services.dart';
import 'package:zoomio_driverzoomio/views/auth_screens/bloc/sign_up_bloc.dart';
import 'package:zoomio_driverzoomio/views/auth_screens/bloc/sign_up_event.dart';
import 'package:zoomio_driverzoomio/views/auth_screens/bloc/sign_up_state.dart';
import 'package:zoomio_driverzoomio/views/auth_screens/signin_screen.dart';
import 'package:zoomio_driverzoomio/views/custom_widgets/custom_button.dart';
import 'package:zoomio_driverzoomio/views/custom_widgets/password_buttons.dart';
import 'package:zoomio_driverzoomio/views/custom_widgets/textformfields.dart';
import 'package:zoomio_driverzoomio/views/profile_screens/add_profile.dart';
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: BlocConsumer<SignUpBloc, SignUpState>(
        listener: (context, state) {
          if (state is SignUpSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreenTwo()),
            );
          } else if (state is SignUpFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SignUpLoading) {
            return Center(
                child: CircularProgressIndicator(
              color: ThemeColors.primaryColor,
            ));
          }

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.02,
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: screenHeight * 0.08),
                        // Logo or image could go here
                        const Text(
                          "Sign up",
                          style: Textstyles.blackHead,
                        ),
                        SizedBox(height: screenHeight * 0.06),

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
                        SizedBox(height: screenHeight * 0.025),

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
                        SizedBox(height: screenHeight * 0.025),

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

                        SizedBox(height: screenHeight * 0.06),

                        CustomButtons(
                          onPressed: () {
                            // Check if the form is valid
                            if (formKey.currentState?.validate() ?? false) {
                              final email = emailController.text.trim();
                              final password = passWordController.text.trim();
                              context.read<SignUpBloc>().add(
                                    SignUpButtonPressed(
                                      email: email,
                                      password: password,
                                    ),
                                  );
                            }
                          },
                          text: 'Sign Up',
                          backgroundColor: ThemeColors.primaryColor,
                          textColor: ThemeColors.textColor,
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                        ),

                        SizedBox(height: screenHeight * 0.04),

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

                        SizedBox(height: screenHeight * 0.02),

                        // Google Sign-In button
                        GestureDetector(
                          onTap: () {
                            AuthServices().signInWithGoogle(context);
                          },
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.asset(
                              "assets/images/gimage.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.03),

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
                                      builder: (context) =>
                                          const SignInScreen()),
                                );
                              },
                              child: const Text("Sign In",
                                  style: TextStyle(
                                      color: ThemeColors.primaryColor)),
                            ),
                          ],
                        ),

                        SizedBox(height: screenHeight * 0.05),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
