import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:zoomio_driverzoomio/data/model/profile_model.dart';
import 'package:zoomio_driverzoomio/views/auth_screens/signin_screen.dart';
import 'package:zoomio_driverzoomio/views/custom_widgets/cutom_profile_container.dart';
import 'package:zoomio_driverzoomio/views/profile_screens/bloc/driver_profile_bloc.dart';
import 'package:zoomio_driverzoomio/views/profile_screens/bloc/driver_profile_event.dart';
import 'package:zoomio_driverzoomio/views/profile_screens/bloc/driver_profile_state.dart';

import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Fetching profile data using DriverProfileBloc
    context.read<DriverProfileBloc>().add(FetchProfileEvent());

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              // You can add theme toggle logic if needed
              // context.read<ThemeCubit>().toggleTheme();
            },
            icon: const Icon(Icons.sunny),
          ),
        ],
        // backgroundColor: ThemeColors.primaryColor,
      ),
      body: BlocBuilder<DriverProfileBloc, DriverProfileState>(
        builder: (context, state) {
          if (state is DriverProfileLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is DriverProfileError) {
            return Center(child: Text(state.message));
          } else if (state is DriverProfileLoaded) {
            // Displaying profile data
            final profile = state.profile;
            return Padding(
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        radius: 50,
                        backgroundImage: (profile.profileImageUrl != null &&
                                profile.profileImageUrl!.isNotEmpty)
                            ? NetworkImage(profile.profileImageUrl!)
                            : const AssetImage("assets/images/personpp.png")
                                as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            // Add functionality for profile editing if needed
                          },
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
                  SizedBox(height: screenWidth * 0.04),
                  Text(
                    profile.name ?? "Driver Name",
                    style:
                        GoogleFonts.alikeAngular(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    profile.contactNumber ?? "Mobile Number",
                    style:
                        GoogleFonts.alikeAngular(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  CustomListTileCard(
                    leadingIcon: Icons.person,
                    title: "Personal Information",
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),
                  CustomListTileCard(
                    leadingIcon: Icons.history,
                    title: "Ride History",
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),
                  CustomListTileCard(
                    leadingIcon: Icons.settings,
                    title: "Settings",
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),
                  CustomListTileCard(
                    leadingIcon: Icons.sync_problem,
                    title: "Legal & Compliance",
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),
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
                                    // Log out the user and navigate to the sign-in screen
                                    // await auth.signout();
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SignInScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text("Logout"),
                                ),
                              ],
                            );
                          });
                    },
                  ),
                ],
              ),
            );
          }
          return Center(child: Text("No profile found"));
        },
      ),
    );
  }
}
