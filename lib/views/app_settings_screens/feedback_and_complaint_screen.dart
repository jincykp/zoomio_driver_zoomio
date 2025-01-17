import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:zoomio_driverzoomio/views/styles/app_styles.dart';

class FeedbackAndComplaintsScreen extends StatelessWidget {
  final String driverId;

  FeedbackAndComplaintsScreen({Key? key, required this.driverId})
      : super(key: key);

  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeColors.primaryColor,
        title: Text(
          'Feedback & Complaints',
          style: GoogleFonts.alikeAngular(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder(
        stream: _database.child('bookings').onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return Center(
              child: Text(
                'No feedback yet',
                style: GoogleFonts.alikeAngular(fontSize: 16),
              ),
            );
          }

          // Convert the data to a Map
          Map<dynamic, dynamic> bookings =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

          // Filter bookings with feedback for this driver
          List<MapEntry<dynamic, dynamic>> driverFeedbacks =
              bookings.entries.where((entry) {
            final booking = entry.value as Map<dynamic, dynamic>;
            return booking['hasCustomerFeedback'] == true &&
                booking['feedback'] != null &&
                booking['feedback']['driverId'] == driverId;
          }).toList();

          if (driverFeedbacks.isEmpty) {
            return Center(
              child: Text(
                'No feedback available',
                style: GoogleFonts.alikeAngular(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: driverFeedbacks.length,
            itemBuilder: (context, index) {
              final booking =
                  driverFeedbacks[index].value as Map<dynamic, dynamic>;
              final feedback = booking['feedback'] as Map<dynamic, dynamic>;
              final timestamp = feedback['timestamp'] as int;
              final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
              final formattedDate =
                  DateFormat('MMM dd, yyyy - hh:mm a').format(date);

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          const SizedBox(width: 8),
                          Text(
                            'Rating: ${feedback['rating']?.toString() ?? 'N/A'}',
                            style: GoogleFonts.alikeAngular(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      if (feedback['feedback'] != null) ...[
                        Text(
                          'Feedback:',
                          style: GoogleFonts.alikeAngular(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          feedback['feedback'],
                          style: GoogleFonts.alikeAngular(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (feedback['complaint'] != null) ...[
                        Text(
                          'Complaint:',
                          style: GoogleFonts.alikeAngular(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          feedback['complaint'],
                          style: GoogleFonts.alikeAngular(fontSize: 16),
                        ),
                      ],
                      const Divider(height: 24),
                      Text(
                        formattedDate,
                        style: GoogleFonts.alikeAngular(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
