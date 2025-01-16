import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:zoomio_driverzoomio/data/services/auth_services.dart';
import 'package:zoomio_driverzoomio/views/homepage_screens/home.dart';
import 'package:zoomio_driverzoomio/views/homepage_screens/completed_trip_screen.dart';
import 'package:zoomio_driverzoomio/views/homepage_screens/profile.dart';
import 'package:zoomio_driverzoomio/views/homepage_screens/revenue_screen.dart';

import 'package:zoomio_driverzoomio/views/styles/app_styles.dart';

class BottomScreens extends StatefulWidget {
  final String? email;
  final String? displayName;
  BottomScreens({super.key, this.displayName, this.email});

  @override
  _BottomScreensState createState() => _BottomScreensState();
}

class _BottomScreensState extends State<BottomScreens> {
  final AuthServices auth = AuthServices();
  int _selectedIndex = 0;
  String driverId = FirebaseAuth.instance.currentUser?.uid ?? '';

  // Use a getter instead of a fixed list
  List<Widget> get _screens => [
        HomeScreen(),
        CompletedTripScreen(driverId: driverId),
        RevenueScreen(
          driverId: driverId,
        ),
        ProfileScreen(userId: driverId),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // Display the selected screen
      bottomNavigationBar: Container(
        color: ThemeColors.primaryColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: GNav(
            backgroundColor: ThemeColors.primaryColor,
            color: Theme.of(context).brightness == Brightness.light
                ? ThemeColors.textColor // Light theme color
                : Colors.black, // Dark theme color (e.g., black)

            activeColor: ThemeColors.primaryColor,
            iconSize: 24,
            tabBackgroundColor: Theme.of(context).brightness == Brightness.light
                ? ThemeColors.textColor // Light theme color
                : Colors.black,
            padding: const EdgeInsets.all(10),
            onTabChange: _onItemTapped,
            tabs: const [
              GButton(
                icon: Icons.home,
                text: "Home",
              ),
              GButton(
                icon: Icons.history,
                text: "Completed Trips",
              ),
              GButton(
                icon: Icons.payment,
                text: "Revenue",
              ),
              GButton(
                icon: Icons.person,
                text: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
