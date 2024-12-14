import 'package:firebase_database/firebase_database.dart';

class RideRequestService {
  final DatabaseReference _ridesRef = FirebaseDatabase.instance.ref('rides');
  final DatabaseReference _driverRef = FirebaseDatabase.instance.ref('drivers');

  // Fetch ride requests for online drivers
  Future<List<Map<String, dynamic>>> fetchRideRequests(
      String vehicleType) async {
    List<Map<String, dynamic>> rideRequests = [];

    // First, fetch online drivers
    final driverSnapshot =
        await _driverRef.orderByChild('isOnline').equalTo(true).get();
    if (driverSnapshot.exists) {
      // Only process online drivers
      final onlineDriverIds =
          driverSnapshot.children.map((driver) => driver.key).toList();

      // Now, fetch ride requests that match the vehicle type
      final rideSnapshot = await _ridesRef
          .orderByChild('vehicleType')
          .equalTo(vehicleType)
          .get();

      if (rideSnapshot.exists) {
        // Filter requests for the online drivers
        for (var ride in rideSnapshot.children) {
          Map<String, dynamic> rideData = ride.value as Map<String, dynamic>;
          // Check if the ride request is for one of the online drivers
          if (onlineDriverIds.contains(rideData['driverId'])) {
            rideRequests.add(rideData);
          }
        }
      }
    }

    return rideRequests;
  }
}
