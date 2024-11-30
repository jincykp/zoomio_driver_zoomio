// driver_profile_event.dart
import 'package:zoomio_driverzoomio/data/model/profile_model.dart';

abstract class DriverProfileEvent {}

class SaveProfileEvent extends DriverProfileEvent {
  final ProfileModel profile;

  SaveProfileEvent({required this.profile});
}

class FetchProfileEvent extends DriverProfileEvent {}
