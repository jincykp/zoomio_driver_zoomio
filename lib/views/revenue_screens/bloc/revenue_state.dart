part of 'revenue_bloc.dart';

@immutable
sealed class RevenueState {}

final class RevenueInitial extends RevenueState {}

class RevenueLoading extends RevenueState {}

class RevenueLoaded extends RevenueState {
  final double todayEarnings;
  final double weeklyEarnings;
  final double monthlyEarnings;
  final int completedTripsToday;
  final int completedTripsWeekly;
  final int completedTripsMonthly;
  final List<Trip> todayTrips;
  final List<Trip> weeklyTrips;
  final List<Trip> monthlyTrips;

  RevenueLoaded({
    required this.todayEarnings,
    required this.weeklyEarnings,
    required this.monthlyEarnings,
    required this.completedTripsToday,
    required this.completedTripsWeekly,
    required this.completedTripsMonthly,
    required this.todayTrips,
    required this.weeklyTrips,
    required this.monthlyTrips,
  });
}

class RevenueError extends RevenueState {
  final String message;

  RevenueError(this.message);
}
