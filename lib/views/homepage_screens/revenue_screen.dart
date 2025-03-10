import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zoomio_driverzoomio/data/model/trip_model.dart';
import 'package:zoomio_driverzoomio/views/homepage_screens/completed_trip_screen.dart';
import 'package:zoomio_driverzoomio/views/revenue_screens/bloc/revenue_bloc.dart';
import 'package:zoomio_driverzoomio/views/styles/app_styles.dart';

class RevenueScreen extends StatelessWidget {
  final String driverId;
  const RevenueScreen({super.key, required this.driverId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          RevenueBloc(FirebaseDatabase.instance.ref('bookings'))
            ..add(FetchRevenueData(driverId)),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: ThemeColors.primaryColor,
          title: const Text(
            "Revenue",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocBuilder<RevenueBloc, RevenueState>(
          builder: (context, state) {
            if (state is RevenueLoading) {
              return const Center(
                  child: CircularProgressIndicator(
                color: ThemeColors.primaryColor,
              ));
            }

            if (state is RevenueError) {
              return Center(child: Text(state.message));
            }

            if (state is RevenueLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      "You earn 40% of every trip you complete",
                      style: TextStyle(
                          color: ThemeColors.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    // Earnings Summary Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildEarningsCard(
                            "Today",
                            state.todayEarnings,
                            state.completedTripsToday,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildEarningsCard(
                            "This Week",
                            state.weeklyEarnings,
                            state.completedTripsWeekly,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildEarningsCard(
                      "This Month",
                      state.monthlyEarnings,
                      state.completedTripsMonthly,
                    ),
                    const SizedBox(height: 16),

                    // Trips List
                    DefaultTabController(
                      length: 3,
                      child: Column(
                        children: [
                          const TabBar(
                            tabs: [
                              Tab(text: "Today"),
                              Tab(text: "This Week"),
                              Tab(text: "This Month"),
                            ],
                          ),
                          SizedBox(
                            height: 400, // Adjust height as needed
                            child: TabBarView(
                              children: [
                                _buildTripsList(state.todayTrips),
                                _buildTripsList(state.weeklyTrips),
                                _buildTripsList(state.monthlyTrips),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return const Center(child: Text("No data available"));
          },
        ),
      ),
    );
  }

  Widget _buildEarningsCard(String period, double earnings, int trips) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              period,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "₹${earnings.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ThemeColors.primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "$trips trips",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripsList(List<Trip> trips) {
    return ListView.builder(
      itemCount: trips.length,
      itemBuilder: (context, index) => TripCard(trip: trips[index]),
    );
  }
}
