import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:zoomio_driverzoomio/data/services/profile_services.dart';
import 'package:zoomio_driverzoomio/views/custom_widgets/custom_button.dart';
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
  String realPickuplocation = '';
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
    fetchCurrentLocation();
    notificationServices.requestNotificationPermission();
    Future<void> acceptRideRequest(String rideId) async {
      await FirebaseDatabase.instance.ref("rides/$rideId").update({
        'status': 'accepted',
        'driverId': 'driverUniqueId', // Replace with the actual driver ID
      });
      print('Ride $rideId accepted');
    }

    listenForPickupLocation();
  }

  void listenForPickupLocation() {
    DatabaseReference bookingsRef =
        FirebaseDatabase.instance.ref().child('bookings');

    bookingsRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        // Assuming 'pickupLocation' is in each booking node
        Map firstBooking = data.values.first; // Get the first booking
        setState(() {
          realPickuplocation = firstBooking['pickupLocation'] ?? 'Unknown';
        });
      } else {
        setState(() {
          realPickuplocation = 'No bookings found';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
              MarkerLayer(
                markers: [
                  if (currentLocation != null)
                    Marker(
                      point: currentLocation!,
                      builder: (ctx) => const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 50, // Adjust size as needed
                      ),
                    ),
                ],
              ),
              Center(
                child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: 350, // Limit max width
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 200,
                            height: 150,
                            color: Colors.grey,
                            child: Image.asset(
                              "assets/images/yellow_car.png",
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
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  "$realPickuplocation",
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: ThemeColors.alertColor,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  "$realPickuplocation",
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
                                    screenHeight: screenHeight),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: CustomButtons(
                                    text: "ACCEPT",
                                    onPressed: () {},
                                    backgroundColor: ThemeColors.successColor,
                                    textColor: ThemeColors.textColor,
                                    screenWidth: screenWidth,
                                    screenHeight: screenHeight),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          )
                        ],
                      ),
                    )),
              )
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
}
