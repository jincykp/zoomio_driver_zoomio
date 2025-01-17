// driver_profile_bloc.dart
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zoomio_driverzoomio/data/services/profile_services.dart';
import 'driver_profile_event.dart';
import 'driver_profile_state.dart';

class DriverProfileBloc extends Bloc<DriverProfileEvent, DriverProfileState> {
  final ProfileRepository repository;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  DriverProfileBloc(this.repository) : super(DriverProfileInitial()) {
    on<FetchProfileEvent>(_onFetchProfile);
    on<SaveProfileEvent>(_onSaveProfile);
  }

  Future<void> _onFetchProfile(
    FetchProfileEvent event,
    Emitter<DriverProfileState> emit,
  ) async {
    try {
      emit(DriverProfileLoading());

      final profile = await repository.getProfileData();
      final userId = await repository.getCurrentUserId();

      if (userId == null) {
        emit(DriverProfileError('User ID not found'));
        return;
      }

      print('Fetching ratings for driver ID: $userId');

      final RatingData ratingData = await getDriverRatings(userId);
      print(
          'Fetched Rating Data - Average: ${ratingData.average}, Total: ${ratingData.total}');

      emit(DriverProfileLoaded(
        profile,
        averageRating: ratingData.average,
        totalRatings: ratingData.total,
      ));
    } catch (e) {
      print('Error in FetchProfileEvent: $e');
      emit(DriverProfileError('Failed to load profile: $e'));
    }
  }

  Future<void> _onSaveProfile(
    SaveProfileEvent event,
    Emitter<DriverProfileState> emit,
  ) async {
    try {
      emit(DriverProfileLoading());
      await repository.saveProfileData(profileModel: event.profile);
      emit(DriverProfileSaved());
    } catch (e) {
      print('Error in SaveProfileEvent: $e');
      emit(DriverProfileError('Failed to save profile: $e'));
    }
  }

  Future<RatingData> getDriverRatings(String driverId) async {
    try {
      print('Starting to fetch ratings for driver: $driverId');

      final DataSnapshot snapshot = await _database.child('bookings').get();

      if (!snapshot.exists) {
        print('No bookings found in database');
        return RatingData(average: 0.0, total: 0);
      }

      final Map<dynamic, dynamic>? bookings =
          snapshot.value as Map<dynamic, dynamic>?;

      if (bookings == null) {
        print('Bookings map is null');
        return RatingData(average: 0.0, total: 0);
      }

      print('Total bookings found: ${bookings.length}');

      double totalRating = 0;
      int ratingCount = 0;

      bookings.forEach((key, booking) {
        print('Processing booking: $key');

        if (booking is Map) {
          // Get feedback data
          var feedbackData = booking['feedback'];

          // Check if feedback exists and contains the correct driver ID
          if (feedbackData is Map &&
              feedbackData['driverId']?.toString() == driverId &&
              booking['hasCustomerFeedback'] == true) {
            print('Found feedback for driver: ${feedbackData['driverId']}');
            var rating = feedbackData['rating'];

            if (rating != null && _isValidRating(rating)) {
              double ratingValue = (rating as num).toDouble();
              totalRating += ratingValue;
              ratingCount++;
              print('Valid rating found: $ratingValue');
              print('Current totals - Sum: $totalRating, Count: $ratingCount');
            }
          }
        }
      });

      double averageRating = ratingCount > 0 ? totalRating / ratingCount : 0.0;
      print(
          'Final calculation - Total: $totalRating, Count: $ratingCount, Average: $averageRating');

      return RatingData(
        average: double.parse(averageRating.toStringAsFixed(1)),
        total: ratingCount,
      );
    } catch (e) {
      print('Error calculating ratings: $e');
      throw Exception('Failed to fetch driver ratings: $e');
    }
  }

  bool _isValidRating(dynamic rating) {
    if (rating is num) {
      double ratingValue = rating.toDouble();
      bool isValid = ratingValue >= 0 && ratingValue <= 5;
      print('Rating validation - Value: $ratingValue, Is valid: $isValid');
      return isValid;
    }
    return false;
  }
}

class RatingData {
  final double average;
  final int total;

  RatingData({required this.average, required this.total});
}
