// driver_status_state.dart
sealed class DriverStatusState {
  const DriverStatusState();
}

class DriverStatusInitial extends DriverStatusState {
  const DriverStatusInitial();
}

class DriverStatusLoading extends DriverStatusState {
  const DriverStatusLoading();
}

class DriverStatusUpdated extends DriverStatusState {
  final bool isOnline;

  const DriverStatusUpdated(this.isOnline);
}
