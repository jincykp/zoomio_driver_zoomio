import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:zoomio_driverzoomio/data/services/auth_services.dart';
import 'package:zoomio_driverzoomio/data/services/profile_services.dart';
import 'package:zoomio_driverzoomio/firebase_options.dart';
import 'package:zoomio_driverzoomio/views/app_settings_screens/bloc/notification_bloc.dart';
import 'package:zoomio_driverzoomio/views/auth_screens/bloc/sign_up_bloc.dart';
import 'package:zoomio_driverzoomio/views/bloc/themestate/thememode.dart';
import 'package:zoomio_driverzoomio/views/homepage_screens/bloc/completed_trip_bloc.dart';
import 'package:zoomio_driverzoomio/views/profile_screens/bloc/driver_profile_bloc.dart';
import 'package:zoomio_driverzoomio/views/revenue_screens/bloc/revenue_bloc.dart';
import 'package:zoomio_driverzoomio/views/splash_screen.dart';
import 'views/homepage_screens/bloc/driver_status_bloc.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase App Check
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  // Initialize Local Notifications
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings();
  const initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => ProfileRepository()),
        BlocProvider(create: (context) => ThemeCubit()),
        BlocProvider(create: (_) => SignUpBloc(AuthServices())),
        BlocProvider(
          create: (context) =>
              DriverProfileBloc(context.read<ProfileRepository>()),
        ),
        BlocProvider(
          create: (context) =>
              DriverStatusBloc(context.read<ProfileRepository>()),
        ),
        BlocProvider(create: (context) => CompletedTripsBloc()),
        BlocProvider(
          create: (context) =>
              RevenueBloc(FirebaseDatabase.instance.ref('bookings')),
        ),
        // Add the new notification bloc provider
        BlocProvider(
          create: (context) => NotificationBloc(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeModeState>(
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Zoomio_Driver_App',
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: state == ThemeModeState.light
                ? ThemeMode.light
                : ThemeMode.dark,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
