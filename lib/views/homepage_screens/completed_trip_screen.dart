import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:zoomio_driverzoomio/data/model/trip_model.dart';
import 'package:zoomio_driverzoomio/views/homepage_screens/bloc/completed_trip_bloc.dart';
import 'package:zoomio_driverzoomio/views/styles/app_styles.dart';

class CompletedTripScreen extends StatelessWidget {
  final String driverId;

  const CompletedTripScreen({super.key, required this.driverId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CompletedTripsBloc()..add(FetchCompletedTrips(driverId)),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text(
            'Completed Trips',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: ThemeColors.primaryColor,
        ),
        body: BlocBuilder<CompletedTripsBloc, CompletedTripState>(
          builder: (context, state) {
            if (state is CompletedTripsLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: ThemeColors.primaryColor,
                ),
              );
            }

            if (state is CompletedTripsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<CompletedTripsBloc>()
                          .add(FetchCompletedTrips(driverId)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is CompletedTripsLoaded) {
              if (state.trips.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_taxi_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No completed trips yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final trip = state.trips[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: TripCard(trip: trip),
                        );
                      },
                      childCount: state.trips.length,
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class TripCard extends StatelessWidget {
  final Trip trip;

  const TripCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigate to trip details
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMM dd, yyyy • hh:mm a').format(trip.timestamp),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '₹ ${trip.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              LocationInfo(
                icon: Icons.location_on,
                title: 'Pickup',
                location: trip.pickupLocation,
              ),
              const SizedBox(height: 15),
              LocationInfo(
                icon: Icons.location_on,
                title: 'Dropoff',
                location: trip.dropOffLocation,
              ),
              const SizedBox(height: 16),
              // Row(
              //   children: [
              //     const CircleAvatar(
              //       radius: 16,
              //       backgroundColor: Colors.grey,
              //       child: Icon(
              //         Icons.person,
              //         color: Colors.white,
              //         size: 20,
              //       ),
              //     ),
              //     const SizedBox(width: 8),
              //     Text(
              //       trip.passengerName,
              //       style: const TextStyle(
              //         fontSize: 14,
              //         fontWeight: FontWeight.w500,
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class LocationInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String location;

  const LocationInfo({
    super.key,
    required this.icon,
    required this.title,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: title == 'Pickup' ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                location,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
