part of 'completed_trip_bloc.dart';

@immutable
sealed class CompletedTripEvent {}

class FetchCompletedTrips extends CompletedTripEvent {
  final String driverId;
  FetchCompletedTrips(this.driverId);
}
