import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zoomio_driverzoomio/views/app_settings_screens/bloc/notification_bloc.dart';
import 'package:zoomio_driverzoomio/views/styles/app_styles.dart';

class NotificationScreen extends StatelessWidget {
  final String driverId;

  const NotificationScreen({
    Key? key,
    required this.driverId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          NotificationBloc()..add(FetchNotificationStatus(driverId)),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: ThemeColors.primaryColor,
          title: const Text('Notifications'),
        ),
        body: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is NotificationError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (state is NotificationLoaded) {
              if (state.isBlocked) {
                return _buildBlockedMessage(state.lastBlockUpdate);
              } else {
                return const Center(
                  child: Text(
                    'Nothing to show',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildBlockedMessage(DateTime? lastBlockUpdate) {
    String formattedDate = lastBlockUpdate?.toString().split(' ')[0] ?? 'N/A';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Account Blocked',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You are blocked because you cancelled two rides in a day. This action was taken on $formattedDate.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please contact support for further assistance.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
