import 'dart:async';

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:zoomio_driverzoomio/data/services/profile_services.dart';
import 'package:zoomio_driverzoomio/views/custom_widgets/custom_bottomsheet.dart';
import 'package:zoomio_driverzoomio/views/custom_widgets/custom_button.dart';
import 'package:zoomio_driverzoomio/views/homepage_screens/accept/bloc/accept_button_bloc.dart';
import 'package:zoomio_driverzoomio/views/push_notifications/notification_services.dart';
import 'package:zoomio_driverzoomio/views/styles/app_styles.dart';
import 'package:http/http.dart' as http;

import 'bloc/driver_status_bloc.dart';
import 'bloc/driver_status_event.dart';
import 'bloc/driver_status_state.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<LatLng> polylinePoints = [];
  bool _isAppInitialized = false; // Flag to check if the app has initialized
  String realPickuplocation = '';
  String realDropOfflocation = '';
  String? bookingId;
  bool isOnline = false; // Initial state of the switch
  final ProfileRepository profileRepository =
      ProfileRepository(); // Initialize your profile repository
  final LatLng defaultPoint =
      const LatLng(8.5241, 76.9366); // Default map center
  LatLng? currentLocation; // To store the user's current location
  NotificationServices notificationServices = NotificationServices();
  final MapController mapController = MapController(); // Map controller
  // Function to fetch the current location
  Future<void> fetchCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return;
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print(
          'Location permissions are permanently denied. We cannot request permissions.');
      return;
    }

    // Fetch the user's current location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });

    // Move the map to the current location
    mapController.move(currentLocation!, 15.0); // Adjust zoom as needed
  }

  // Function to handle the toggle change and update Firebase
  Future<void> toggleStatus(bool value) async {
    setState(() {
      isOnline = value;
    });

    try {
      await profileRepository.updateDriverStatus(value);
      context.read<DriverStatusBloc>().add(UpdateDriverStatus(value));

      if (value) {
        listenToPickUpLocation();
      } else {
        _cancelPreviousRideRequestListener();
        setState(() {
          realPickuplocation = '';
          realDropOfflocation = '';
        });
      }
    } catch (e) {
      print('Error updating driver status: $e');
      // Revert the local state if there's an error
      setState(() {
        isOnline = !value;
      });
    }
  }

  void _cancelPreviousRideRequestListener() {
    DatabaseReference bookingsRef =
        FirebaseDatabase.instance.ref().child('bookings');
    bookingsRef.onDisconnect();
  }

  void listenToPickUpLocation() {
    _cancelPreviousRideRequestListener();
    DatabaseReference _testRef =
        FirebaseDatabase.instance.ref().child('bookings');

    _testRef.onValue.listen((event) {
      if (event.snapshot.exists) {
        var bookingData = event.snapshot.value as Map<dynamic, dynamic>;

        // Iterate through all bookings and fetch the booking ID
        bookingData.forEach((bookingKey, bookingDetails) {
          if (bookingDetails != null && bookingDetails['status'] == 'pending') {
            setState(() {
              // Booking ID is a String (Firebase key)
              bookingId = bookingKey.toString(); // Assign as String
              realPickuplocation = bookingDetails['pickupLocation'] as String;
              realDropOfflocation = bookingDetails['dropOffLocation'] as String;
            });

            // Use the fetched booking ID here
            print('Booking ID: $bookingId');

            print('Pickup Location: $realPickuplocation');
            print('Dropoff Location: $realDropOfflocation');
          } else {
            setState(() {
              realPickuplocation = '';
              realDropOfflocation = '';
            });
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchCurrentLocation();
    listenToPickUpLocation();
    notificationServices.requestNotificationPermission();

    // Delay the initialization to prevent showing the ride request container prematurely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isAppInitialized = true;
      // listenToDriverStatus(); // Start listening to driver status after initialization
    });
  }

  @override
  void dispose() {
    // _cancelPreviousRideRequestListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverStatusBloc, DriverStatusState>(
        builder: (context, state) {
      isOnline = state is DriverStatusUpdated ? state.isOnline : false;
      print('Driver is online: $isOnline');

      print('Pickup Location: $realPickuplocation');
      print('Dropoff Location: $realDropOfflocation');
      print(
          'Should show container: ${isOnline && realPickuplocation.isNotEmpty && realDropOfflocation.isNotEmpty}');
      double screenWidth = MediaQuery.of(context).size.width;
      double screenHeight = MediaQuery.of(context).size.height;

      return Scaffold(
        body: Stack(
          children: [
            // Fullscreen OpenStreetMap
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                // Set initial zoom level and center
                onTap: (tapPosition, latLng) {
                  // Handle map tap event (optional)
                  print('Tapped on: $latLng');
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: polylinePoints,
                      strokeWidth: 4,
                      color: Colors.blue,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    if (currentLocation != null)
                      Marker(
                        point: currentLocation!,
                        builder: (ctx) => const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 50,
                        ),
                      ),
                  ],
                ),
                if (isOnline &&
                    realPickuplocation.isNotEmpty &&
                    realDropOfflocation.isNotEmpty) ...[
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black
                            : Colors.white,
                      ),
                      constraints: const BoxConstraints(
                        maxWidth: 350,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 200,
                              height: 150,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.black
                                  : Colors.white,
                              child: Image.asset(
                                "assets/images/yellow_car_original.png",
                                fit: BoxFit.cover,
                              ),
                            ),
                            const Text(
                              "New Ride Request",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Divider(
                              thickness: 2,
                              color: ThemeColors.baseColor,
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.my_location,
                                  color: ThemeColors.successColor,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    realPickuplocation,
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: ThemeColors.alertColor,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    realDropOfflocation,
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(
                              thickness: 2,
                              color: ThemeColors.baseColor,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomButtons(
                                    text: "CANCEL",
                                    onPressed: () {},
                                    backgroundColor: ThemeColors.alertColor,
                                    textColor: ThemeColors.textColor,
                                    screenWidth: screenWidth,
                                    screenHeight: screenHeight,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: CustomButtons(
                                    text: "ACCEPT",
                                    backgroundColor: ThemeColors.successColor,
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (context) {
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: CustomBottomSheet(
                                              bookingId: bookingId!,
                                              pickupLocation:
                                                  realPickuplocation,
                                              dropoffLocation:
                                                  realDropOfflocation,
                                              // Pass the user ID dynamically
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    textColor: ThemeColors.textColor,
                                    screenWidth: screenWidth,
                                    screenHeight: screenHeight,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),

            // Overlay toggle switch in the top-right corner
            Positioned(
              top: 20,
              right: 20,
              child: BlocBuilder<DriverStatusBloc, DriverStatusState>(
                builder: (context, state) {
                  final bool currentOnline =
                      state is DriverStatusUpdated ? state.isOnline : false;

                  return AnimatedToggleSwitch<bool>.size(
                    current: currentOnline,
                    values: const [false, true],
                    iconOpacity: 0.2,
                    indicatorSize: const Size.fromWidth(70),
                    customIconBuilder: (context, local, global) => Text(
                      local.value ? 'Online' : 'Offline',
                      style: TextStyle(
                        color: Color.lerp(
                          ThemeColors.alertColor,
                          ThemeColors.textColor,
                          local.animationValue,
                        ),
                        fontSize: 10,
                      ),
                    ),
                    borderWidth: 3.0,
                    iconAnimationType: AnimationType.onHover,
                    style: ToggleStyle(
                      indicatorColor: ThemeColors.primaryColor,
                      borderColor: Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    onChanged: toggleStatus,
                  );
                },
              ),
            ),
          ],
        ),

        // Floating Action Button for resetting the map view
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            fetchCurrentLocation(); // Reset map center and zoom
          },
          child: const Icon(Icons.my_location),
        ),
      );
    });
  }
}
