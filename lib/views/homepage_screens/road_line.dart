import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RoadLinesScreen extends StatefulWidget {
  final String pickupLocation;
  final String dropoffLocation;
  final Map<String, String> userDetails;

  const RoadLinesScreen({
    super.key,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.userDetails,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trip Details',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Text('Current Location: Kerala'),
                  Text('Pickup: ${widget.pickupLocation}'),
                  Text('Dropoff: ${widget.dropoffLocation}'),
                  const SizedBox(height: 16),
                  Text(
                    'User Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ...widget.userDetails.entries.map(
                    (entry) => Text('${entry.key}: ${entry.value}'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
