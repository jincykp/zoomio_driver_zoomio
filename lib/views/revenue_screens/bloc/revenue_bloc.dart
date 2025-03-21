import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:meta/meta.dart';
import 'package:zoomio_driverzoomio/data/model/trip_model.dart';

part 'revenue_event.dart';
part 'revenue_state.dart';

class RevenueBloc extends Bloc<RevenueEvent, RevenueState> {
  final DatabaseReference _bookingsRef;
  StreamSubscription? _revenueSubscription;

  RevenueBloc(this._bookingsRef) : super(RevenueInitial()) {
    on<FetchRevenueData>(_onFetchRevenueData);
  }

  DateTime _getDateTimeFromTimestamp(dynamic timestamp) {
    if (timestamp is DateTime) return timestamp;
    return timestamp as DateTime;
  }

  Future<void> _onFetchRevenueData(
    FetchRevenueData event,
    Emitter<RevenueState> emit,
  ) async {
    print('Fetching revenue data for driver: ${event.driverId}');
    emit(RevenueLoading());

    try {
      await _revenueSubscription?.cancel();
      final controller = StreamController<RevenueState>.broadcast();

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      final startOfWeek =
          startOfDay.subtract(Duration(days: startOfDay.weekday - 1));
      final startOfMonth = DateTime(now.year, now.month, 1);

      _revenueSubscription = _bookingsRef
          .orderByChild('driverId')
          .equalTo(event.driverId)
          .onValue
          .listen(
        (DatabaseEvent event) {
          if (event.snapshot.value != null) {
            try {
              final Map<dynamic, dynamic> tripsMap =
                  event.snapshot.value as Map;

              final List<Trip> allTrips = tripsMap.entries
                  .map((e) {
                    try {
                      return Trip.fromMap(e.key, e.value as Map);
                    } catch (e) {
                      print('Error parsing trip: $e');
                      return null;
                    }
                  })
                  .whereType<Trip>()
                  .where((trip) =>
                      trip.status == 'trip_completed') // Updated status check
                  .toList();

              // Filter trips for different time periods
              final List<Trip> todayTrips = allTrips.where((trip) {
                final tripDate = _getDateTimeFromTimestamp(trip.timestamp);
                return tripDate.isAfter(startOfDay) &&
                    tripDate.isBefore(endOfDay);
              }).toList();

              final List<Trip> weeklyTrips = allTrips.where((trip) {
                final tripDate = _getDateTimeFromTimestamp(trip.timestamp);
                return tripDate.isAfter(startOfWeek) &&
                    tripDate.isBefore(endOfDay);
              }).toList();

              final List<Trip> monthlyTrips = allTrips.where((trip) {
                final tripDate = _getDateTimeFromTimestamp(trip.timestamp);
                return tripDate.isAfter(startOfMonth) &&
                    tripDate.isBefore(endOfDay);
              }).toList();

              // Calculate 40% earnings
              final double todayEarnings = todayTrips.fold(
                  0, (sum, trip) => sum + (trip.totalPrice * 0.4));
              final double weeklyEarnings = weeklyTrips.fold(
                  0, (sum, trip) => sum + (trip.totalPrice * 0.4));
              final double monthlyEarnings = monthlyTrips.fold(
                  0, (sum, trip) => sum + (trip.totalPrice * 0.4));

              controller.add(RevenueLoaded(
                todayEarnings: todayEarnings,
                weeklyEarnings: weeklyEarnings,
                monthlyEarnings: monthlyEarnings,
                completedTripsToday: todayTrips.length,
                completedTripsWeekly: weeklyTrips.length,
                completedTripsMonthly: monthlyTrips.length,
                todayTrips: todayTrips,
                weeklyTrips: weeklyTrips,
                monthlyTrips: monthlyTrips,
              ));
            } catch (e, stackTrace) {
              print('Error processing trips: $e');
              print('Stack trace: $stackTrace');
              controller.add(RevenueError('Error processing trips: $e'));
            }
          } else {
            controller.add(RevenueLoaded(
              todayEarnings: 0,
              weeklyEarnings: 0,
              monthlyEarnings: 0,
              completedTripsToday: 0,
              completedTripsWeekly: 0,
              completedTripsMonthly: 0,
              todayTrips: [],
              weeklyTrips: [],
              monthlyTrips: [],
            ));
          }
        },
        onError: (error) {
          print('Firebase error: $error');
          controller.add(RevenueError('Failed to fetch revenue data: $error'));
        },
      );

      await emit.forEach(
        controller.stream,
        onData: (RevenueState state) => state,
      );
    } catch (e) {
      print('Error in revenue bloc: $e');
      emit(RevenueError('Failed to fetch revenue data: $e'));
    }
  }

  @override
  Future<void> close() {
    _revenueSubscription?.cancel();
    return super.close();
  }
}
