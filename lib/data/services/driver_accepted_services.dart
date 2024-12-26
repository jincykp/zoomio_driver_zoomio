import 'package:firebase_database/firebase_database.dart';

class DriverBookingService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<void> acceptBooking({
    required String bookingId,
    required String driverId,
  }) async {
    try {
      await _database.child('bookings').child(bookingId).update({
        'status': 'driver_accepted',
        'driverId': driverId,
        'acceptedAt': ServerValue.timestamp,
      });
    } catch (e) {
      throw Exception('Failed to accept booking: $e');
    }
  }
}
