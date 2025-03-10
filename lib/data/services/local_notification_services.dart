// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:permission_handler/permission_handler.dart';

// class LocalNotificationServices {
//   // Initialize Firestore and FlutterLocalNotifications instances
//   final firestore = FirebaseFirestore.instance;
//   final _currentUser = FirebaseAuth.instance.currentUser;
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   // Request notification permissions
//   Future<void> requestPermission() async {
//     PermissionStatus status = await Permission.notification.request();
//     if (status != PermissionStatus.granted) {
//       throw Exception('Permission not granted');
//     }
//   }

//   // Initialize local notifications
//   Future<void> init() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const InitializationSettings initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);

//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   }

//   // Upload FCM token to Firestore
//   Future<void> uploadFcmToken() async {
//     try {
//       final token = await FirebaseMessaging.instance.getToken();
//       print('FCM Token: $token');

//       if (_currentUser != null && token != null) {
//         // Update the notification token in the existing driver document
//         await firestore
//             .collection('driverProfiles')
//             .doc(_currentUser!.uid)
//             .update({
//           'notification': token,
//         });

//         // Listen for token refreshes
//         FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
//           print('Token Refreshed: $newToken');
//           await firestore
//               .collection('driverProfiles')
//               .doc(_currentUser!.uid)
//               .update({
//             'notification': newToken,
//           });
//         });
//       }
//     } catch (e) {
//       print('Error uploading FCM Token: ${e.toString()}');
//     }
//   }

//   // Show local notification
//   Future<void> showNotification(RemoteMessage message) async {
//     const AndroidNotificationDetails androidNotificationDetails =
//         AndroidNotificationDetails(
//       'channel_id',
//       'channel Name',
//       channelDescription: 'channel Description',
//       importance: Importance.max,
//       priority: Priority.high,
//       ticker: 'ticker',
//     );

//     const NotificationDetails notificationDetails =
//         NotificationDetails(android: androidNotificationDetails);

//     await flutterLocalNotificationsPlugin.show(
//       1, // notification ID
//       message.notification!.title,
//       message.notification!.body,
//       notificationDetails,
//       payload: 'No Present',
//     );
//   }

//   // Initialize Firebase Messaging handlers
//   Future<void> setupFirebaseMessaging() async {
//     // Handle notification when app is in foreground
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('Got a message whilst in the foreground!');
//       print('Message data: ${message.data}');

//       if (message.notification != null) {
//         print('Message also contained a notification: ${message.notification}');
//         showNotification(message);
//       }
//     });

//     // Handle notification when app is in background and user taps on it
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('A new onMessageOpenedApp event was published!');
//       print('Message data: ${message.data}');
//     });
//   }
// }
