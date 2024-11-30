// driver_profile_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zoomio_driverzoomio/data/services/profile_services.dart';
import 'driver_profile_event.dart';
import 'driver_profile_state.dart';

class DriverProfileBloc extends Bloc<DriverProfileEvent, DriverProfileState> {
  final ProfileRepository repository;

  DriverProfileBloc(this.repository) : super(DriverProfileInitial()) {
    on<SaveProfileEvent>(_onSaveProfile);
    on<FetchProfileEvent>(_onFetchProfile);
  }

  Future<void> _onSaveProfile(
      SaveProfileEvent event, Emitter<DriverProfileState> emit) async {
    emit(DriverProfileLoading());
    try {
      await repository.saveProfileData(profileModel: event.profile);
      emit(DriverProfileSaved());
    } catch (e) {
      emit(DriverProfileError('Failed to save profile: $e'));
    }
  }

  Future<void> _onFetchProfile(
      FetchProfileEvent event, Emitter<DriverProfileState> emit) async {
    emit(DriverProfileLoading());
    try {
      final userId = await repository.getCurrentUserId();
      final profile = await repository.getProfileData();
      emit(DriverProfileLoaded(profile));
    } catch (e) {
      emit(DriverProfileError('Failed to fetch profile: $e'));
    }
  }
}
