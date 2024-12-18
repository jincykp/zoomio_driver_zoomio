import 'package:firebase_database/firebase_database.dart';

class RideRepository {
  final DatabaseReference bookingsRef =
      FirebaseDatabase.instance.ref("bookings");

  Future<void> acceptRideRequest(String bookingId, String driverId) async {
    await bookingsRef.child(bookingId).update({
      'status': 'accepted',
      'driverId': driverId,
      'acceptedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> rejectRideRequest(String bookingId, String driverId) async {
    await bookingsRef.child(bookingId).update({
      'status': 'rejected',
      'rejectedBy': driverId,
      'rejectedAt': DateTime.now().toIso8601String(),
    });
  }
}
