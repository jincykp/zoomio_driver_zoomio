import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:zoomio_driverzoomio/firebase_options.dart';
import 'package:zoomio_driverzoomio/views/bloc/themestate/thememode.dart';
import 'package:zoomio_driverzoomio/views/provider/user_profile_provider.dart';
import 'package:zoomio_driverzoomio/views/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ThemeCubit(), // Create ThemeCubit
        ),
      ],
      child: ChangeNotifierProvider(
        create: (context) => ProfileProvider(), // Create ProfileProvider
        child: BlocBuilder<ThemeCubit, ThemeModeState>(
          builder: (context, themeMode) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Flutter Demo',
              theme: ThemeData.light(), // Light theme
              darkTheme: ThemeData.dark(), // Dark theme
              themeMode: themeMode == ThemeModeState.dark
                  ? ThemeMode.light
                  : ThemeMode.dark, // Set theme mode based on state
              home: const SplashScreen(),
            );
          },
        ),
      ),
    );
  }
}
