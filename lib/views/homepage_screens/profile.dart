import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoomio_driverzoomio/data/services/auth_services.dart';
import 'package:zoomio_driverzoomio/views/auth_screens/signin_screen.dart';
import 'package:zoomio_driverzoomio/views/bloc/themestate/thememode.dart';
import 'package:zoomio_driverzoomio/views/custom_widgets/cutom_profile_container.dart';
import 'package:zoomio_driverzoomio/views/styles/app_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthServices auth = AuthServices();
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                context.read<ThemeCubit>().toggleTheme();
              },
              icon: const Icon(Icons.sunny))
        ],
        //backgroundColor: ThemeColors.primaryColor,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.03),
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  const CircleAvatar(
                      backgroundColor: ThemeColors.textColor,
                      maxRadius: 50,
                      minRadius: 50,
                      backgroundImage: AssetImage("assets/images/personpp.png")
                      // Show icon when there is no image

                      ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 25,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: screenWidth * 0.04,
              ),
              Text(
                "Jincy",
                style: GoogleFonts.alikeAngular(fontWeight: FontWeight.bold),
              ),
              Text(
                "8592861876",
                style: GoogleFonts.alikeAngular(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              CustomListTileCard(
                  leadingIcon: Icons.person,
                  title: "Personal Information",
                  onTap: () {}),
              const SizedBox(
                height: 10,
              ),
              CustomListTileCard(
                  leadingIcon: Icons.history,
                  title: "Ride History",
                  onTap: () {}),
              const SizedBox(
                height: 10,
              ),
              CustomListTileCard(
                  leadingIcon: Icons.settings, title: "Settings", onTap: () {}),
              const SizedBox(
                height: 10,
              ),
              CustomListTileCard(
                  leadingIcon: Icons.sync_problem,
                  title: "Legal & Compliance",
                  onTap: () {}),
              const SizedBox(
                height: 10,
              ),
              CustomListTileCard(
                  leadingIcon: Icons.logout,
                  title: "Log Out",
                  onTap: () async {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              "Logout Confirmation",
                              style: GoogleFonts.alikeAngular(
                                  fontWeight: FontWeight.bold),
                              //   style: Textstyles.buttonText,
                            ),
                            content: const Text(
                              "Are you sure you want to logout?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  await auth.signout();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SignInScreen()),
                                  );
                                },
                                child: const Text("Logout"),
                              ),
                            ],
                          );
                        });
                  })
            ],
          ),
        ),
      ),
    );
  }
}
