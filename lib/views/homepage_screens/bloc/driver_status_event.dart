// driver_status_event.dart
sealed class DriverStatusEvent {
  const DriverStatusEvent();
}

class LoadDriverStatus extends DriverStatusEvent {
  const LoadDriverStatus();
}

class UpdateDriverStatus extends DriverStatusEvent {
  final bool isOnline;

  const UpdateDriverStatus(this.isOnline);
}
