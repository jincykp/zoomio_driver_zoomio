import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:meta/meta.dart';
import 'package:zoomio_driverzoomio/data/model/trip_model.dart';

part 'completed_trip_event.dart';
part 'completed_trip_state.dart';

class CompletedTripsBloc extends Bloc<CompletedTripEvent, CompletedTripState> {
  final DatabaseReference _bookingsRef =
      FirebaseDatabase.instance.ref().child('bookings');
  StreamSubscription<DatabaseEvent>? _tripsSubscription;

  CompletedTripsBloc() : super(CompletedTripsInitial()) {
    on<FetchCompletedTrips>(_onFetchCompletedTrips);
  }

  Future<void> _onFetchCompletedTrips(
    FetchCompletedTrips event,
    Emitter<CompletedTripState> emit,
  ) async {
    emit(CompletedTripsLoading());

    try {
      await _tripsSubscription?.cancel();

      // Create a StreamController to handle the Firebase stream
      final controller = StreamController<CompletedTripState>();

      _tripsSubscription = _bookingsRef
          .orderByChild('driverId')
          .equalTo(event.driverId)
          .onValue
          .listen(
        (DatabaseEvent event) {
          if (event.snapshot.value != null) {
            final Map<dynamic, dynamic> tripsMap =
                event.snapshot.value as Map<dynamic, dynamic>;

            final List<Trip> trips = tripsMap.entries
                .where((e) => (e.value as Map)['status'] == 'trip completed')
                .map((e) => Trip.fromMap(e.key, e.value as Map))
                .toList();

            // Sort by timestamp descending
            trips.sort((a, b) => b.timestamp.compareTo(a.timestamp));

            controller.add(CompletedTripsLoaded(trips));
          } else {
            controller.add(CompletedTripsLoaded([]));
          }
        },
        onError: (error) {
          controller.add(CompletedTripsError('Failed to fetch trips: $error'));
        },
      );

      // Emit states from the controller
      await emit.forEach(controller.stream,
          onData: (CompletedTripState state) => state);

      // Clean up
      await controller.close();
    } catch (e) {
      emit(CompletedTripsError('Failed to fetch trips: $e'));
    }
  }

  @override
  Future<void> close() async {
    await _tripsSubscription?.cancel();
    return super.close();
  }
}
