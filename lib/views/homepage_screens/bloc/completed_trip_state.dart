part of 'completed_trip_bloc.dart';

@immutable

// States
abstract class CompletedTripState {
  const CompletedTripState();
}

class CompletedTripsInitial extends CompletedTripState {}

class CompletedTripsLoading extends CompletedTripState {}

class CompletedTripsLoaded extends CompletedTripState {
  final List<Trip> trips;
  CompletedTripsLoaded(this.trips);
}

class CompletedTripsError extends CompletedTripState {
  final String message;
  CompletedTripsError(this.message);
}
