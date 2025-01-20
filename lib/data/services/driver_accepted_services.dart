import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class DriverBookingService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> acceptBooking({
    required String bookingId,
    required String driverId,
  }) async {
    try {
      print('DEBUG: Starting acceptBooking for driver: $driverId');

      // 1. Get booking details
      final bookingSnapshot =
          await _database.child('bookings').child(bookingId).get();
      if (!bookingSnapshot.exists) {
        throw Exception('Booking not found');
      }

      final bookingData = bookingSnapshot.value as Map<dynamic, dynamic>;

      // Get the vehicle ID from vehicleDetails
      final vehicleId = bookingData['vehicleDetails']?['id'];
      final vehicleType = bookingData['vehicleDetails']?['vehicleType'];

      print('DEBUG: Vehicle ID from booking: $vehicleId');
      print('DEBUG: Vehicle Type from booking: $vehicleType');

      if (vehicleId == null) {
        throw Exception('Vehicle ID not found in booking details');
      }

      // 2. Update vehicle status in Firestore
      await _firestore.collection('vehicles').doc(vehicleId).update({
        'status': 'onTrip',
        'currentBookingId': bookingId,
        'assignedDriver': driverId,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      print('DEBUG: Vehicle status updated successfully');

      // 3. Update driver profile
      await _firestore.collection('driverProfiles').doc(driverId).update(
          {'currentBookingId': bookingId, 'assignedVehicleId': vehicleId});

      print('DEBUG: Driver profile updated successfully');

      // 4. Update booking status
      await _database.child('bookings').child(bookingId).update({
        'status': 'driver_accepted',
        'driverId': driverId,
        'acceptedAt': ServerValue.timestamp,
      });

      print('DEBUG: Booking status updated successfully');
    } catch (e) {
      print('DEBUG: Error in acceptBooking: $e');
      throw Exception('Failed to accept booking: $e');
    }
  }

  Future<void> completeTrip(String bookingId) async {
    try {
      // Get booking details
      final bookingSnapshot =
          await _database.child('bookings').child(bookingId).get();
      if (!bookingSnapshot.exists) {
        throw Exception('Booking not found');
      }

      final bookingData = bookingSnapshot.value as Map<dynamic, dynamic>;
      final driverId = bookingData['driverId'];
      final vehicleId = bookingData['vehicleDetails']?['id'];

      if (vehicleId == null || driverId == null) {
        throw Exception('Missing vehicle or driver information');
      }

      // Update vehicle status
      await _firestore.collection('vehicles').doc(vehicleId).update({
        'status': 'available',
        'currentBookingId': null,
        'assignedDriver': null,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Update driver profile
      await _firestore.collection('driverProfiles').doc(driverId).update({
        'currentBookingId': null,
        'assignedVehicleId': null,
      });

      // Update booking status
      await updateBookingStatus(bookingId, 'trip_completed');
    } catch (e) {
      print('DEBUG: Error in completeTrip: $e');
      throw Exception('Failed to complete trip: $e');
    }
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _database.child('bookings').child(bookingId).update({
        'status': status,
        'completedAt': ServerValue.timestamp,
      });
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }
}
