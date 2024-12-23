part of 'accept_button_bloc.dart';

@immutable
sealed class AcceptButtonEvent {}

class AcceptButtonClicked extends AcceptButtonEvent {
  final String bookingId;
  final String pickupLocation;
  final String dropoffLocation;

  AcceptButtonClicked({
    required this.bookingId,
    required this.pickupLocation,
    required this.dropoffLocation,
  });
}
