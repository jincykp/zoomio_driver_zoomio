// driver_status_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zoomio_driverzoomio/data/services/profile_services.dart';
import 'driver_status_event.dart';
import 'driver_status_state.dart';

class DriverStatusBloc extends Bloc<DriverStatusEvent, DriverStatusState> {
  final ProfileRepository profileRepository;

  DriverStatusBloc(this.profileRepository)
      : super(const DriverStatusInitial()) {
    on<LoadDriverStatus>(_onLoadDriverStatus);
    on<UpdateDriverStatus>(_onUpdateDriverStatus);
  }

  Future<void> _onLoadDriverStatus(
      LoadDriverStatus event, Emitter<DriverStatusState> emit) async {
    emit(const DriverStatusLoading());
    try {
      final isOnline = await profileRepository.getDriverStatus();
      emit(DriverStatusUpdated(isOnline));
    } catch (e) {
      emit(const DriverStatusInitial()); // Handle errors or provide fallback
    }
  }

  Future<void> _onUpdateDriverStatus(
      UpdateDriverStatus event, Emitter<DriverStatusState> emit) async {
    try {
      // Add logging to verify the event value
      print('Updating driver status: ${event.isOnline}'); // Debug print

      await profileRepository.updateDriverStatus(event.isOnline);
      emit(DriverStatusUpdated(event.isOnline));
    } catch (e) {
      print('Error in _onUpdateDriverStatus: $e'); // Error logging
      // Optionally re-emit the previous state or handle the error
    }
  }
}
