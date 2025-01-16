part of 'revenue_bloc.dart';

@immutable
sealed class RevenueEvent {}

class FetchRevenueData extends RevenueEvent {
  final String driverId;
  FetchRevenueData(this.driverId);
}
