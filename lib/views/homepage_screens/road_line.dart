import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:zoomio_driverzoomio/views/bottom_screens.dart';
import 'dart:convert';

import 'package:zoomio_driverzoomio/views/custom_widgets/custom_button.dart';
import 'package:zoomio_driverzoomio/views/homepage_screens/home.dart';
import 'package:zoomio_driverzoomio/views/styles/app_styles.dart';

class RoadLinesScreen extends StatefulWidget {
  final String pickupLocation;
  final String dropoffLocation;
  final Map<String, String> userDetails;
  final double totalPrice;

  const RoadLinesScreen({
    super.key,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.userDetails,
    required this.totalPrice,
  });

  @override
  State<RoadLinesScreen> createState() => _RoadLinesScreenState();
}

class _RoadLinesScreenState extends State<RoadLinesScreen> {
  List<LatLng> routePoints = [];
  // Kerala coordinates
  final LatLng keralaLocation = const LatLng(10.8505, 76.2711);
  LatLng? pickupCoords;
  LatLng? dropoffCoords;

  @override
  void initState() {
    super.initState();
    _fetchRoutePoints();
  }

  Future<void> _fetchRoutePoints() async {
    try {
      final pickupUrl = Uri.parse(
          'https://api.openrouteservice.org/v2/directions/driving-car');
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization':
            'YOUR_API_KEY_HERE' // Replace with your OpenRouteService API key
      };

      final body = jsonEncode({
        "coordinates": [
          [keralaLocation.longitude, keralaLocation.latitude],
          [76.9366, 8.5241] // Example destination in Kerala
        ]
      });

      final response = await http.post(pickupUrl, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final coords = data['features'][0]['geometry']['coordinates'] as List;

        setState(() {
          routePoints = coords
              .map((coord) => LatLng(coord[1] as double, coord[0] as double))
              .toList();
        });
      }
    } catch (e) {
      print('Error fetching route: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: FlutterMap(
              options: MapOptions(
                center: keralaLocation,
                zoom: 7.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 5,
                      color: Colors.blue,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: keralaLocation,
                      builder: (ctx) => const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Trip Details',
                        style: TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                        )),
                    const SizedBox(height: 16),
                    // Text('Current Location: Kerala'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Pickup: ${widget.pickupLocation}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Dropoff: ${widget.dropoffLocation}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 10), const Divider(),
                    const Text(
                      'Customer Information',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // First Card with Text
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                widget.userDetails.entries.isNotEmpty
                                    ? ' ${widget.userDetails.entries.first.value}'
                                    : '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                overflow: TextOverflow
                                    .ellipsis, // To handle text overflow
                              ),
                            ),
                          ),
                        ),

                        // Card with two Icons
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.message),
                                  onPressed: () {
                                    // Handle message icon press
                                    print('Message icon pressed');
                                  },
                                  iconSize: 30,
                                  color: Colors.blue,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.call),
                                  onPressed: () {},
                                  iconSize: 30,
                                  color: ThemeColors.successColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Divider(),
                    const Text(
                      "Collect the amount from the customer",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Total Price: ₹${widget.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: ThemeColors.successColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    CustomButtons(
                        text: 'Trip Completed',
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BottomScreens()));
                        },
                        backgroundColor: ThemeColors.primaryColor,
                        textColor: ThemeColors.textColor,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight)
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
