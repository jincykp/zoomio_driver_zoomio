import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:latlong2/latlong.dart';
import 'package:meta/meta.dart';

part 'accept_button_event.dart';
part 'accept_button_state.dart';

class AcceptButtonBloc extends Bloc<AcceptButtonEvent, AcceptButtonState> {
  final DatabaseReference _bookingsRef =
      FirebaseDatabase.instance.ref().child('bookings');

  AcceptButtonBloc() : super(AcceptButtonInitial()) {
    on<AcceptButtonClicked>(_onAcceptButtonClicked);
  }

  Future<void> _onAcceptButtonClicked(
    AcceptButtonClicked event,
    Emitter<AcceptButtonState> emit,
  ) async {
    try {
      emit(AcceptButtonLoading());

      // Update booking status in Firebase
      await _bookingsRef.child(event.bookingId).update({
        'status': 'in_trip',
        'driverId': FirebaseAuth.instance.currentUser?.uid,
        'acceptedAt': ServerValue.timestamp,
      });

      // Get route points (implement actual logic based on your needs)
      final List<LatLng> routePoints = await _getRoutePoints(
        event.pickupLocation,
        event.dropoffLocation,
      );

      emit(AcceptButtonSuccess(
        bookingId: event.bookingId,
        pickupLocation: event.pickupLocation,
        dropoffLocation: event.dropoffLocation,
        routePoints: routePoints,
      ));
    } catch (e) {
      print('Error accepting ride: $e');
      emit(AcceptButtonFailure(e.toString()));
    }
  }

  Future<List<LatLng>> _getRoutePoints(
    String pickup,
    String dropoff,
  ) async {
    // Implement your route calculation logic here
    // For now, returning dummy points
    return [
      LatLng(8.5241, 76.9366),
      LatLng(8.5341, 76.9466),
    ];
  }
}
