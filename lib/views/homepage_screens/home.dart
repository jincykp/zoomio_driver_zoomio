import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:zoomio_driverzoomio/data/services/profile_services.dart';
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

  final MapController mapController = MapController(); // Map controller
  final LatLng defaultPoint =
      LatLng(8.5241, 76.9366); // Kerala, India (Thiruvananthapuram)
// Default map center

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          AnimatedToggleSwitch<bool>.size(
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
            onChanged: toggleStatus,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Stack(
        children: [
          // OpenStreetMap
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

          // Optional toggle overlay or other UI elements
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.white.withOpacity(0.8),
              child: Text(
                isOnline ? ' Online' : ' Offline',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isOnline ? Colors.green : Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Move the map to the default position on button press
          mapController.move(defaultPoint, 13.0); // Set center and zoom
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
