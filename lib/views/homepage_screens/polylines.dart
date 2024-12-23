// import 'dart:convert';
// import 'package:latlong2/latlong.dart';

// class Polylines {
//   List<LatLng> routePoints = [];

//   Future<void> getRoutePoints(
//       String pickupLocation, String dropoffLocation) async {
//     try {
//       // First, convert addresses to coordinates using Nominatim
//       final pickupCoords = await getCoordinatesFromAddress(pickupLocation);
//       final dropoffCoords = await getCoordinatesFromAddress(dropoffLocation);

//       if (pickupCoords != null && dropoffCoords != null) {
//         // Get route using OSRM
//         final response = await http.get(Uri.parse(
//             'http://router.project-osrm.org/route/v1/driving/${pickupCoords.longitude},${pickupCoords.latitude};${dropoffCoords.longitude},${dropoffCoords.latitude}?overview=full&geometries=geojson'));

//         if (response.statusCode == 200) {
//           final data = jsonDecode(response.body);
//           final coordinates =
//               data['routes'][0]['geometry']['coordinates'] as List;

//           setState(() {
//             routePoints = coordinates.map((coord) {
//               return LatLng(coord[1], coord[0]);
//             }).toList();
//           });
//         }
//       }
//     } catch (e) {
//       print('Error getting route: $e');
//     }
//   }

//   Future<LatLng?> getCoordinatesFromAddress(String address) async {
//     try {
//       final response = await http.get(Uri.parse(
//           'https://nominatim.openstreetmap.org/search?format=json&q=$address'));

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data.isNotEmpty) {
//           return LatLng(
//             double.parse(data[0]['lat']),
//             double.parse(data[0]['lon']),
//           );
//         }
//       }
//     } catch (e) {
//       print('Error geocoding address: $e');
//     }
//     return null;
//   }
// }
