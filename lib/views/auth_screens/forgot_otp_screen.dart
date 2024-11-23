import 'package:flutter/material.dart';
import 'package:zoomio_driverzoomio/data/services/auth_services.dart';
import 'package:zoomio_driverzoomio/views/custom_widgets/custom_button.dart';
import 'package:zoomio_driverzoomio/views/custom_widgets/textformfields.dart';
import 'package:zoomio_driverzoomio/views/styles/app_styles.dart';

class ClickOtpScreen extends StatefulWidget {
  const ClickOtpScreen({super.key});

  @override
  State<ClickOtpScreen> createState() => _ClickOtpScreenState();
}

class _ClickOtpScreenState extends State<ClickOtpScreen> {
  final auth = AuthServices();
  final emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.08),
          child: Column(
            children: [
              const Text(
                "Enter email to send you a password reset email",
                // style: Textstyles.titleTextSmall,
              ),
              SizedBox(
                height: screenWidth * 0.1,
              ),
              ProfileFields(
                  controller: emailController, hintText: "Enter your Email"),
              SizedBox(
                height: screenWidth * 0.1,
              ),
              CustomButtons(
                  text: "Send Email",
                  onPressed: () async {
                    await auth.resetPassword(emailController.text);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'An email for password reset has been sent to your email.',
                          style: Textstyles.smallTexts,
                        ),
                        backgroundColor: ThemeColors.titleColor,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  backgroundColor: ThemeColors.primaryColor,
                  textColor: ThemeColors.textColor,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight)
            ],
          ),
        ),
      ),
    );
  }
}
