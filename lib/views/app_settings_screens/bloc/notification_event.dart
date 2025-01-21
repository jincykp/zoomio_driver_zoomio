part of 'notification_bloc.dart';

@immutable
sealed class NotificationEvent {}

class FetchNotificationStatus extends NotificationEvent {
  final String driverId;
  FetchNotificationStatus(this.driverId);
}
