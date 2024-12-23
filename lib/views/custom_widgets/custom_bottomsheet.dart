import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zoomio_driverzoomio/views/custom_widgets/custom_button.dart';
import 'package:zoomio_driverzoomio/views/styles/app_styles.dart';

class CustomBottomSheet extends StatelessWidget {
  final String bookingId;
  final String pickupLocation;
  final String dropoffLocation;

  const CustomBottomSheet({
    Key? key,
    required this.bookingId,
    required this.pickupLocation,
    required this.dropoffLocation,
  }) : super(key: key);

  Future<Map<String, String>> _getUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user is currently logged in.");
      return {'displayName': 'Unknown', 'phone': 'Not available'};
    }

    print("Looking for user details with ID: ${user.uid}");

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        print("User document found: ${userDoc.data()}");
        var data = userDoc.data() as Map<String, dynamic>;
        return {
          'displayName': data['displayName'] ?? 'Unknown',
          'phone': data['phone'] ?? 'Not available',
        };
      } else {
        print("User document does not exist.");
      }
    } catch (e) {
      print("Error in _getUserDetails: $e");
    }

    return {'displayName': 'Unknown', 'phone': 'Not available'};
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        color: Colors.white,
      ),
      child: FutureBuilder<Map<String, String>>(
        future: _getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 200, // Fixed height for loading state
              child: Center(
                child: SizedBox(
                  width: 24, // Smaller size for progress indicator
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0, // Thinner stroke
                  ),
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return SizedBox(
              height: 100,
              child: Center(child: Text('Error: ${snapshot.error}')),
            );
          }

          if (snapshot.hasData) {
            var userDetails = snapshot.data!;
            return IntrinsicHeight(
              // This will make the height fit the content
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.my_location,
                        color: ThemeColors.successColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          pickupLocation,
                          style: const TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: ThemeColors.alertColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          dropoffLocation,
                          style: const TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'User: ${userDetails['displayName']}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mobile: ${userDetails['phone']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: CustomButtons(
                      text: 'Start now',
                      onPressed: () {},
                      backgroundColor: ThemeColors.primaryColor,
                      textColor: ThemeColors.textColor,
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          }

          return const SizedBox(
            height: 100,
            child: Center(child: Text('No user data available')),
          );
        },
      ),
    );
  }
}
