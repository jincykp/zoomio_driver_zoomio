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
import 'package:zoomio_driverzoomio/data/model/profile_model.dart';
import 'package:zoomio_driverzoomio/data/services/driver_accepted_services.dart';
import 'package:zoomio_driverzoomio/data/services/profile_services.dart';
import 'package:zoomio_driverzoomio/views/custom_widgets/custom_bottomsheet.dart';
import 'package:zoomio_driverzoomio/views/custom_widgets/custom_button.dart';
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
  ProfileModel? driverProfile;
  bool _isAppInitialized = false; // Flag to check if the app has initialized
  String realPickuplocation = '';
  String realDropOfflocation = '';
  double totalPrice = 0.0;
  String vehicleType = '';
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
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled.')),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied.')),
            );
          }
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      if (mounted) {
        setState(() {
          currentLocation = LatLng(position.latitude, position.longitude);
          // Move map to current location
          mapController.move(currentLocation!, 15.0);
        });
        print(
            "DEBUG: Current location updated: ${position.latitude}, ${position.longitude}");
      }
    } catch (e) {
      print("DEBUG: Error fetching location: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    }
  }

  // Function to handle the toggle change and update Firebase
  Future<void> toggleStatus(bool value) async {
    try {
      setState(() {
        isOnline = value;
      });

      await profileRepository.updateDriverStatus(value);
      context.read<DriverStatusBloc>().add(UpdateDriverStatus(value));

      if (value) {
        print("DEBUG: Driver went online, starting booking listener");
        await fetchDriverProfile(); // Refresh profile data
        listenToPickUpLocation();
      } else {
        print("DEBUG: Driver went offline, canceling listener");
        _cancelPreviousRideRequestListener();
        setState(() {
          realPickuplocation = '';
          realDropOfflocation = '';
          vehicleType = '';
          bookingId = null;
        });
      }
    } catch (e) {
      print('Error updating driver status: $e');
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
    if (driverProfile == null) {
      print("DEBUG: Cannot listen for rides - driver profile not loaded");
      return;
    }

    _cancelPreviousRideRequestListener();
    DatabaseReference _testRef =
        FirebaseDatabase.instance.ref().child('bookings');

    print("DEBUG: Starting ride listener for ${driverProfile?.name}");
    print(
        "DEBUG: Driver vehicle preference: ${driverProfile?.vehiclePreference}");

    _testRef.onValue.listen((event) {
      print("DEBUG: Received booking update");
      if (!event.snapshot.exists) {
        print("DEBUG: No bookings found");
        return;
      }

      try {
        Map bookingData = event.snapshot.value as Map;
        print("DEBUG: Found ${bookingData.length} bookings to check");

        bookingData.forEach((key, value) {
          if (value['status']?.toString().toLowerCase() != 'pending') {
            print("DEBUG: Skipping non-pending booking $key");
            return;
          }

          String? requestedVehicleType = value['vehicleDetails']?['vehicleType']
              ?.toString()
              .trim()
              .toLowerCase();

          if (requestedVehicleType == null) {
            print("DEBUG: Skipping booking $key - no vehicle type");
            return;
          }

          String driverVehicle =
              driverProfile!.vehiclePreference?.toLowerCase() ?? '';
          print(
              "DEBUG: Checking booking $key - Request: $requestedVehicleType, Driver preference: $driverVehicle");

          bool shouldShowRequest = false;

          // Explicit vehicle type matching logic
          switch (driverVehicle) {
            case 'car':
              shouldShowRequest = (requestedVehicleType == 'car');
              break;
            case 'bike':
              shouldShowRequest = (requestedVehicleType == 'bike');
              break;
            case 'both':
              shouldShowRequest = (requestedVehicleType == 'car' ||
                  requestedVehicleType == 'bike');
              break;
            default:
              print("DEBUG: Invalid driver vehicle preference: $driverVehicle");
              return;
          }

          if (shouldShowRequest) {
            print("DEBUG: Found matching ride! Updating state");
            setState(() {
              bookingId = key;
              realPickuplocation = value['pickupLocation']?.toString() ?? '';
              realDropOfflocation = value['dropOffLocation']?.toString() ?? '';
              totalPrice =
                  double.tryParse(value['totalPrice']?.toString() ?? '0.0') ??
                      0.0;
              vehicleType = requestedVehicleType;

              // Print booking details
              print("DEBUG: Booking Details:");
              print("  Booking ID: $bookingId");
              print("  Pickup Location: $realPickuplocation");
              print("  Drop-off Location: $realDropOfflocation");
              print("  Total Price: $totalPrice");
              print("  Vehicle Type: $vehicleType");
            });
          } else {
            print("DEBUG: Skipping non-matching vehicle type for booking $key");
          }
        });
      } catch (e) {
        print("DEBUG: Error processing bookings: $e");
        print(e.toString());
      }
    }, onError: (error) {
      print("DEBUG: Booking listener error: $error");
    });
  }

  Future<void> fetchDriverProfile() async {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (currentUserId.isEmpty) {
        print("DEBUG: User not authenticated");
        return;
      }

      print("DEBUG: Fetching profile for driver: $currentUserId");

      final docSnapshot = await FirebaseFirestore.instance
          .collection('driverProfiles')
          .doc(currentUserId)
          .get();

      if (!docSnapshot.exists) {
        print("DEBUG: No driver profile found");
        return;
      }

      final data = docSnapshot.data();
      if (data != null) {
        setState(() {
          driverProfile = ProfileModel.fromMap(data, docId: currentUserId);
        });

        print("DEBUG: Driver profile fetched successfully");
        print("DEBUG: Name: ${driverProfile?.name}");
        print("DEBUG: Vehicle Preference: ${driverProfile?.vehiclePreference}");
        print("DEBUG: Experience: ${driverProfile?.experienceYears}");
      }
    } catch (e) {
      print("DEBUG: Error fetching driver profile: $e");
    }
  }

  Future<void> initializeDriver() async {
    await fetchDriverProfile(); // Wait for profile to be fetched

    // Only start listening if driver is online
    if (isOnline && driverProfile != null) {
      print("DEBUG: Starting ride listener after profile fetch");
      listenToPickUpLocation();
    } else {
      print(
          "DEBUG: Not starting listener - Online: $isOnline, Profile: ${driverProfile != null}");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchCurrentLocation();

    // Initialize async setup
    initializeDriver();
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
      print('DEBUG: Build method states:');
      print('Driver is online: $isOnline');
      print('Current Location: $currentLocation');
      print('Pickup Location: $realPickuplocation');
      print('Dropoff Location: $realDropOfflocation');
      print('Vehicle Type: $vehicleType');
      // print('Booking ID: $bookingId');
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
                                vehicleType.toLowerCase() == 'car'
                                    ? "assets/images/yellow_car_original.png"
                                    : "assets/images/bike.png",
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
                            const SizedBox(
                              height: 10,
                            ),
                            const Divider(
                              thickness: 2,
                              color: ThemeColors.baseColor,
                            ),
                            Text(
                              "Total Price : ₹${totalPrice.toStringAsFixed(2)}", // Display totalPrice with 2 decimals
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Divider(
                              thickness: 2,
                              color: ThemeColors.baseColor,
                            ),
                            const SizedBox(
                              height: 10,
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
                                    onPressed: () async {
                                      try {
                                        print(
                                            "DEBUG: Initial bookingId value: $bookingId"); // Debug print
                                        // Correct way to validate nullable bookingId
                                        if (bookingId?.isEmpty ?? true) {
                                          print(
                                              "DEBUG: BookingId is null or empty"); // Debug print
                                          throw Exception('Invalid booking ID');
                                        }

                                        // Validate location information
                                        if (realPickuplocation.isEmpty ||
                                            realDropOfflocation.isEmpty) {
                                          throw Exception(
                                              'Missing location information');
                                        }
                                        print(
                                            "DEBUG: BookingId after validation: $bookingId"); // Debug print

                                        final driverId = FirebaseAuth
                                            .instance.currentUser?.uid;
                                        if (driverId == null) {
                                          throw Exception(
                                              'Driver not authenticated');
                                        }

                                        // Accept the booking with null safety
                                        final bookingService =
                                            DriverBookingService();
                                        print(
                                            "DEBUG: About to call acceptBooking with bookingId: $bookingId"); //
                                        await bookingService.acceptBooking(
                                          bookingId:
                                              bookingId!, // Now safe to use ! because we validated above
                                          driverId: driverId,
                                        );
                                        print(
                                            "DEBUG: Booking accepted successfully");

                                        if (!context.mounted) return;

                                        // Show success message
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Ride accepted successfully!'),
                                            backgroundColor:
                                                ThemeColors.successColor,
                                          ),
                                        );

                                        // Show bottom sheet
                                        if (context.mounted) {
                                          await showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            builder: (BuildContext context) {
                                              print(
                                                  "DEBUG: Building bottom sheet with bookingId: $bookingId");
                                              return SafeArea(
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                    bottom:
                                                        MediaQuery.of(context)
                                                            .viewInsets
                                                            .bottom,
                                                    left: 8.0,
                                                    right: 8.0,
                                                    top: 8.0,
                                                  ),
                                                  child: CustomBottomSheet(
                                                    bookingId:
                                                        bookingId!, // Now safe to use ! because we validated above
                                                    pickupLocation:
                                                        realPickuplocation,
                                                    dropoffLocation:
                                                        realDropOfflocation,
                                                    totalPrice: totalPrice,
                                                  ),
                                                ),
                                              );
                                            },
                                          ).catchError((error) {
                                            print(
                                                'Error showing bottom sheet: $error');
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Error showing ride details: $error'),
                                                  backgroundColor:
                                                      ThemeColors.alertColor,
                                                ),
                                              );
                                            }
                                          });
                                        }
                                      } catch (e) {
                                        if (!context.mounted) return;

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content:
                                                Text('Error: ${e.toString()}'),
                                            backgroundColor:
                                                ThemeColors.alertColor,
                                          ),
                                        );
                                        print('Error in accept booking: $e');
                                      }
                                    },
                                    textColor: ThemeColors.textColor,
                                    screenWidth: screenWidth,
                                    screenHeight: screenHeight,
                                  ),
                                )
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
