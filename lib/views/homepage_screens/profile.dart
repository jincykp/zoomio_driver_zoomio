import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:zoomio_driverzoomio/data/services/profile_services.dart';
import 'package:zoomio_driverzoomio/views/app_settings_screens/help_and_support_screen.dart';
import 'package:zoomio_driverzoomio/views/app_settings_screens/notification_screen.dart';
import 'package:zoomio_driverzoomio/views/app_settings_screens/privacy_policy.dart';
import 'package:zoomio_driverzoomio/views/auth_screens/signin_screen.dart';
import 'package:zoomio_driverzoomio/views/bloc/themestate/thememode.dart';
import 'package:zoomio_driverzoomio/views/custom_widgets/cutom_profile_container.dart';
import 'package:zoomio_driverzoomio/views/profile_screens/bloc/driver_profile_bloc.dart';
import 'package:zoomio_driverzoomio/views/profile_screens/bloc/driver_profile_event.dart';
import 'package:zoomio_driverzoomio/views/profile_screens/bloc/driver_profile_state.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoomio_driverzoomio/views/profile_screens/edit_screen.dart';
import 'package:zoomio_driverzoomio/views/app_settings_screens/feedback_and_complaint_screen.dart';
import 'package:zoomio_driverzoomio/views/styles/app_styles.dart';

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
              context
                  .read<ThemeCubit>()
                  .toggleTheme(); // Toggle the theme when the button is pressed
            },
            icon: const Icon(Icons.sunny),
          ),
        ],
        // backgroundColor: ThemeColors.primaryColor,
      ),
      body: BlocBuilder<DriverProfileBloc, DriverProfileState>(
        builder: (context, state) {
          if (state is DriverProfileLoading) {
            return const Center(
                child: CircularProgressIndicator(
              color: ThemeColors.primaryColor,
            ));
          } else if (state is DriverProfileError) {
            return Center(child: Text(state.message));
          } else if (state is DriverProfileLoaded) {
            final profile = state.profile;
            return Padding(
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          radius: 70,
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
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                //color: Colors.black.withOpacity(0.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                  onPressed: () async {
                                    // Get the current user's ID
                                    String? driverId = await ProfileRepository()
                                        .getCurrentUserId();

                                    // Check if we have a valid driverId (user is logged in)
                                    if (driverId != null) {
                                      // Navigate to ProfileEditScreen and pass the driverId
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditProfileScreen(
                                                  driverId: driverId),
                                        ),
                                      );
                                    } else {
                                      // Handle the case where user is not logged in
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('User not logged in!')),
                                      );
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    color: ThemeColors.titleColor,
                                  )),
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
                    Column(
                      children: [
                        RatingBar.builder(
                          initialRating: state.averageRating,
                          minRating: 0,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 24,
                          ignoreGestures: true,
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (_) {},
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${state.averageRating} (${state.totalRatings} reviews)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                    CustomListTileCard(
                      leadingIcon: Icons.warning_amber_outlined,
                      title: "Notifications",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotificationScreen(
                              driverId: userId,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    CustomListTileCard(
                      leadingIcon: Icons.privacy_tip_outlined,
                      title: "Privacy Policy",
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const PrivacyPolicyScreen()));
                      },
                    ),
                    const SizedBox(height: 10),
                    CustomListTileCard(
                      leadingIcon: Icons.help_outline_outlined,
                      title: "Help and Support",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HelpSupportScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    CustomListTileCard(
                      leadingIcon: Icons.sync_problem,
                      title: "Legal & Compliance",
                      onTap: () async {
                        String? driverId =
                            await ProfileRepository().getCurrentUserId();
                        if (driverId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FeedbackAndComplaintsScreen(
                                  driverId: driverId),
                            ),
                          );
                        }
                      },
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
                                title: const Text("Logout Confirmation",
                                    style: TextStyle()),
                                content: const Text(
                                  "Are you sure you want to logout?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      "Cancel",
                                      style: TextStyle(
                                          color: ThemeColors.baseColor,
                                          fontSize: 17),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      // Log out the user and navigate to the sign-in screen
                                      // await auth.signout();
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SignInScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "Logout",
                                      style: TextStyle(
                                          color: ThemeColors.primaryColor,
                                          fontSize: 17),
                                    ),
                                  ),
                                ],
                              );
                            });
                      },
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(child: Text("No profile found"));
        },
      ),
    );
  }
}
