import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:zoomio_driverzoomio/data/services/auth_services.dart';
import 'package:zoomio_driverzoomio/data/services/profile_services.dart';
import 'package:zoomio_driverzoomio/firebase_options.dart';
import 'package:zoomio_driverzoomio/views/auth_screens/bloc/sign_up_bloc.dart';
import 'package:zoomio_driverzoomio/views/bloc/themestate/thememode.dart';
import 'package:zoomio_driverzoomio/views/homepage_screens/bloc/completed_trip_bloc.dart';

import 'package:zoomio_driverzoomio/views/profile_screens/bloc/driver_profile_bloc.dart';
import 'package:zoomio_driverzoomio/views/revenue_screens/bloc/revenue_bloc.dart';
import 'package:zoomio_driverzoomio/views/splash_screen.dart';

import 'views/homepage_screens/bloc/driver_status_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialize Firebase App Check
  await FirebaseAppCheck.instance.activate(
    // For debug/testing
    androidProvider: AndroidProvider.debug,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
            create: (_) =>
                ProfileRepository()), // Provide ProfileRepository globally
        BlocProvider(
          create: (context) => ThemeCubit(), // Create ThemeCubit
        ),
        BlocProvider(
          create: (_) => SignUpBloc(AuthServices()), // Create SignUpBloc
        ),
        BlocProvider(
          create: (context) => DriverProfileBloc(context
              .read<ProfileRepository>()), // Use the provided ProfileRepository
        ),
        BlocProvider(
          create: (context) => DriverStatusBloc(context
              .read<ProfileRepository>()), // Use the provided ProfileRepository
        ),
        BlocProvider(
          create: (context) =>
              CompletedTripsBloc(), // Use the provided ProfileRepository
        ),
        BlocProvider(
          create: (context) => RevenueBloc(
            FirebaseDatabase.instance.ref('bookings'),
          ), // Use the provided ProfileRepository
        )
      ],
      child: BlocBuilder<ThemeCubit, ThemeModeState>(
        // Build the app based on the current theme
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Zoomio_Driver_App',
            theme: ThemeData.light(), // Light theme
            darkTheme: ThemeData.dark(), // Dark theme
            themeMode: state == ThemeModeState.light
                ? ThemeMode.light
                : ThemeMode.dark, // Set theme mode based on cubit state
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
