part of 'accept_button_bloc.dart';

@immutable
sealed class AcceptButtonState {}

final class AcceptButtonInitial extends AcceptButtonState {}

class AcceptButtonLoading extends AcceptButtonState {}

class AcceptButtonSuccess extends AcceptButtonState {
  final String bookingId;
  final String pickupLocation;
  final String dropoffLocation;
  final List<LatLng> routePoints;

  AcceptButtonSuccess({
    required this.bookingId,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.routePoints,
  });
}

class AcceptButtonFailure extends AcceptButtonState {
  final String error;
  AcceptButtonFailure(this.error);
}
