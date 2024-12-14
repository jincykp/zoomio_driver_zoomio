import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:zoomio_driverzoomio/data/services/profile_services.dart';
import 'package:zoomio_driverzoomio/views/homepage_screens/bloc/driver_status_bloc.dart';
import 'package:zoomio_driverzoomio/views/homepage_screens/bloc/driver_status_event.dart';
import 'package:zoomio_driverzoomio/views/homepage_screens/bloc/driver_status_state.dart';
import 'package:zoomio_driverzoomio/views/push_notifications/notification_services.dart';
import 'package:zoomio_driverzoomio/views/styles/app_styles.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isOnline = false; // Initial state of the switch
  final ProfileRepository profileRepository =
      ProfileRepository(); // Initialize your profile repository
  final LatLng defaultPoint = LatLng(8.5241, 76.9366); // Default map center
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

    // Update the driver's online status in Firebase
    try {
      await profileRepository.updateDriverStatus(value);
    } catch (e) {
      print('Error updating driver status: $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notificationServices.requestNotificationPermission();
    // notificationServices.isTokenRefresh();
    notificationServices.getDeviceToken().then((value) {
      print('FCM Device Token');
      print(value);
      fetchCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
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
            ],
          ),

          // Overlay toggle switch in the top-right corner
          Positioned(
            top: 20, // Adjust as needed
            right: 20, // Adjust as needed
            child: BlocBuilder<DriverStatusBloc, DriverStatusState>(
              builder: (context, state) {
                bool isOnline = false;
                if (state is DriverStatusUpdated) {
                  isOnline = state.isOnline;
                }

                return AnimatedToggleSwitch<bool>.size(
                  current: isOnline,
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
                  onChanged: (value) {
                    context
                        .read<DriverStatusBloc>()
                        .add(UpdateDriverStatus(value));
                  },
                );
              },
            ),
          ),
        ],
      ),

      // Floating Action Button for resetting the map view
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          fetchCurrentLocation; // Reset map center and zoom
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }

  void listenForRideRequests() {
    // Replace with the vehicle type of the driver
    final String driverVehicleType =
        "bike"; // Get this from the driver's profile

    FirebaseDatabase.instance
        .ref("rides")
        .orderByChild("vehicleType")
        .equalTo(driverVehicleType)
        .onChildAdded
        .listen((event) {
      if (event.snapshot.exists) {
        final rideData = Map<String, dynamic>.from(event.snapshot.value as Map);
        if (rideData['status'] == 'pending' && isOnline) {
          showRideRequestDialog(rideData, event.snapshot.key!);
        }
      }
    });
  }

  void showRideRequestDialog(Map<String, dynamic> rideData, String rideId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Ride Request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Pickup: ${rideData['pickupLocation']}'),
              Text('Dropoff: ${rideData['dropOffLocation']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                rejectRideRequest(rideId);
              },
              child: const Text('Reject'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                acceptRideRequest(rideId);
              },
              child: const Text('Accept'),
            ),
          ],
        );
      },
    );
  }

  Future<void> acceptRideRequest(String rideId) async {
    await FirebaseDatabase.instance.ref("rides/$rideId").update({
      'status': 'accepted',
      'driverId': 'driverUniqueId', // Replace with the actual driver ID
    });
    print('Ride $rideId accepted');
  }

  Future<void> rejectRideRequest(String rideId) async {
    await FirebaseDatabase.instance.ref("rides/$rideId").update({
      'status': 'rejected',
    });
    print('Ride $rideId rejected');
  }
}
