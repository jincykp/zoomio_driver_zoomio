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
  Future<void> ensureUserDocument() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!doc.exists) {
        // Create the document if it doesn't exist
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .set({
          'email': currentUser.email,
          'displayName': currentUser.displayName ?? 'User',
          'phone': currentUser.phoneNumber ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
        print("Created new document for user ${currentUser.uid}");
      }
    }
  }

  Future<Map<String, String>> _getUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    print("Looking for user details with ID: ${user?.uid}");

    // Print all collections to verify structure
    QuerySnapshot collections =
        await FirebaseFirestore.instance.collection('users').get();
    print("All documents in users collection:");
    collections.docs.forEach((doc) {
      print("Document ID: ${doc.id}");
      print("Document data: ${doc.data()}");
    });

    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection(
                'users') // Make sure this is the correct collection name
            .doc(user.uid)
            .get();

        print("Attempting to fetch document from: users/${user.uid}");
        print("Document exists: ${userDoc.exists}");
        print("Document data: ${userDoc.data()}");

        if (userDoc.exists) {
          var data = userDoc.data() as Map<String, dynamic>;
          return {
            'displayName': data['displayName'] ?? 'Unknown',
            'phone': data['phone'] ?? 'Not available',
          };
        }
      } catch (e) {
        print("Error in _getUserDetails: $e");
      }
    }

    return {'displayName': 'Unknown', 'phone': 'Not available'};
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: SingleChildScrollView(
        child: FutureBuilder<Map<String, String>>(
          future: _getUserDetails(),
          builder: (context, snapshot) {
            print("Loading user details...");
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // Show loading indicator while fetching data
            }

            if (snapshot.hasError) {
              print("Error in FutureBuilder: ${snapshot.error}");
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.hasData) {
              print("User details: ${snapshot.data}");
              var userDetails = snapshot.data!;
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.my_location),
                        Expanded(
                          child: Text(
                            pickupLocation,
                            style: const TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      dropoffLocation,
                      style: const TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 20),
                    // Display user details
                    Text(
                      'User: ${userDetails['displayName']}',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Mobile: ${userDetails['phone']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    Center(
                        child: SizedBox(
                      child: CustomButtons(
                          text: 'Start now',
                          onPressed: () {},
                          backgroundColor: ThemeColors.primaryColor,
                          textColor: ThemeColors.textColor,
                          screenWidth: screenWidth,
                          screenHeight: screenHeight),
                    )),
                  ]);
            }

            return const Text('No user data available');
          },
        ),
      ),
    );
  }
}
