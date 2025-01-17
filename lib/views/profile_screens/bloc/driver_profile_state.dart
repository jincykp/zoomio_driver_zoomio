// driver_profile_state.dart
import 'package:zoomio_driverzoomio/data/model/profile_model.dart';

abstract class DriverProfileState {}

class DriverProfileInitial extends DriverProfileState {}

class DriverProfileLoading extends DriverProfileState {}

class DriverProfileSaved extends DriverProfileState {}

class DriverProfileLoaded extends DriverProfileState {
  final ProfileModel profile;
  final double averageRating;
  final int totalRatings;

  DriverProfileLoaded(
    this.profile, {
    this.averageRating = 0.0,
    this.totalRatings = 0,
  });
}

class DriverProfileError extends DriverProfileState {
  final String message;
  DriverProfileError(this.message);
}
