import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:zoomio_driverzoomio/views/custom_widgets/custom_button.dart';
import 'package:zoomio_driverzoomio/views/homepage_screens/road_line.dart';
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
    try {
      print(
          '===== DEBUG: Getting user details for booking ID: $bookingId =====');

      // Step 1: Get booking data from Realtime Database
      final DatabaseReference bookingsRef =
          FirebaseDatabase.instance.ref().child('bookings');
      final DatabaseEvent bookingEvent =
          await bookingsRef.child(bookingId).once();

      if (bookingEvent.snapshot.value == null) {
        print('DEBUG: Booking data not found for ID: $bookingId');
        return {'displayName': 'Unknown', 'phone': 'Not available'};
      }

      // Convert booking data to Map
      final bookingData =
          Map<String, dynamic>.from(bookingEvent.snapshot.value as Map);
      print('DEBUG: Found booking data: $bookingData');

      // Get userId from booking
      final userId = bookingData['userId'];
      if (userId == null) {
        print('DEBUG: No userId found in booking data');
        return {'displayName': 'Unknown', 'phone': 'Not available'};
      }
      print('DEBUG: Found userId in booking: $userId');

      // Get user data from Firestore instead of Realtime Database
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists || userDoc.data() == null) {
        print('DEBUG: User data not found in Firestore for ID: $userId');
        return {'displayName': 'Unknown', 'phone': 'Not available'};
      }

      final userData = userDoc.data()!;
      print('DEBUG: Found user data in Firestore: $userData');

      return {
        'displayName': userData['displayName'] ?? userData['name'] ?? 'Unknown',
        'phone':
            userData['phone'] ?? userData['phoneNumber'] ?? 'Not available',
      };
    } catch (e, stackTrace) {
      print('DEBUG: Error in _getUserDetails: $e');
      print('DEBUG: Stack trace: $stackTrace');
      return {'displayName': 'Unknown', 'phone': 'Not available'};
    }
  }

  Future<void> updateBookingStatusToOnTrip() async {
    try {
      // Get current driver's uid
      final User? currentDriver = FirebaseAuth.instance.currentUser;
      if (currentDriver == null) {
        throw Exception('No driver logged in');
      }

      // Update only status and driverId in Realtime Database
      final DatabaseReference bookingRef =
          FirebaseDatabase.instance.ref().child('bookings').child(bookingId);

      await bookingRef.update({
        'status': 'on_trip',
        'driverId': currentDriver
            .uid, // This will help user app to fetch driver details
        'tripStartedAt': ServerValue.timestamp,
      });

      print('Booking status updated to on_trip successfully');
    } catch (e) {
      print('Error updating booking status: $e');
      throw e;
    }
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.person,
                          )),
                      Text(
                        ' ${userDetails['displayName']}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const SizedBox(width: 20),
                      Text(
                        ' ${userDetails['phone']}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.phone,
                            size: 30,
                            color: ThemeColors.baseColor,
                          )),
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.message,
                            size: 30,
                            color: ThemeColors.primaryColor,
                          )),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
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
                  Center(
                    child: CustomButtons(
                      text: 'Start Now',
                      onPressed: () async {
                        try {
                          // Show loading indicator
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          );

                          // Update booking status
                          await updateBookingStatusToOnTrip();

                          // Remove loading indicator
                          Navigator.pop(context);

                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Trip started successfully'),
                              backgroundColor: ThemeColors.successColor,
                            ),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RoadLinesScreen(
                                  pickupLocation: pickupLocation,
                                  dropoffLocation: dropoffLocation,
                                  userDetails:
                                      userDetails), // Replace with your desired screen
                            ),
                          );
                        } catch (e) {
                          // Remove loading indicator
                          Navigator.pop(context);

                          // Show error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Failed to start trip: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
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
