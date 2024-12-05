import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class PushNotificationsSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Initialize FCM and handle initial messages
  Future<void> initializeCloudMessaging(BuildContext context) async {
    // Handle when the app is launched by a notification
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        readUserRideRequestInformation(
            remoteMessage.data["rideRequestId"], context);
      }
    });

    // Handle when the app is in the foreground and receives a notification
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        readUserRideRequestInformation(
            remoteMessage.data["rideRequestId"], context);
      }
    });
  }

//whenthe apisopenandrecievesapush notificatrion
  // FirebaseMessaging.onMessage.listen(RemoteMessage?remoteMessage){
  //   readUserRideRequestInformation(remoteMessage!.data["rideRequestId"], context);}

  // Function to handle the user ride request information
  void readUserRideRequestInformation(
      String userRideRequestId, BuildContext context) {
    // Implement your logic to handle the ride request
    // FirebaseDatabase.instance.ref().child("All ride request").child(userRideRequestId).child('driverId').onValue.listen((event){})
    // print("Ride Request ID: $userRideRequestId");
  }
}
