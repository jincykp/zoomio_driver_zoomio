import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  Future<void> requestPermission() async {
    // Request permission to show notification
    PermissionStatus status = await Permission.notification.request();
    if (status == PermissionStatus.granted) {
      log('Permission granted');
    } else {
      throw Exception('Permission not granted');
    }
  }

  final FirebaseFirestore firebaseFireStore = FirebaseFirestore.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<void> uploadFcmToken() async {
    try {
      User? currentUser = firebaseAuth.currentUser;
      if (currentUser != null) {
        String userId = currentUser.uid;

        await FirebaseMessaging.instance.getToken().then((token) async {
          log('getToken :: $token');
          if (token != null) {
            await firebaseFireStore
                .collection('driverProfiles')
                .doc(userId)
                .set(
              {
                'notificationToken': token,
              },
              SetOptions(
                  merge:
                      true), // Ensures it updates without overwriting existing data
            );
          }
        });

        FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
          log('onTokenRefresh :: $token');
          await firebaseFireStore.collection('driverProfiles').doc(userId).set(
            {
              'notificationToken': token,
            },
            SetOptions(merge: true),
          );
        });
      } else {
        log("User is not logged in.");
      }
    } catch (e) {
      log(e.toString());
    }
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialize native Android notification
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('channel_id', 'channel Name',
            channelDescription: 'Channel Description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    int notificationId = 1;

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        notificationId,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        payload: 'Not present');
  }
}
