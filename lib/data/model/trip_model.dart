class Trip {
  final String id;
  final String pickupLocation;
  final String dropOffLocation;
  final double totalPrice;
  final dynamic
      timestamp; // Changed to dynamic to handle both String and DateTime
  final String passengerName;
  final String status;

  Trip({
    required this.id,
    required this.pickupLocation,
    required this.dropOffLocation,
    double? totalPrice,
    required this.timestamp,
    required this.passengerName,
    required this.status,
  }) : totalPrice = totalPrice ?? 0;

  factory Trip.fromMap(String id, Map<dynamic, dynamic> map) {
    // Handle timestamp conversion
    dynamic timestampValue = map['timestamp'];
    DateTime parsedTimestamp;

    if (timestampValue is String) {
      parsedTimestamp = DateTime.parse(timestampValue);
    } else if (timestampValue is int) {
      parsedTimestamp = DateTime.fromMillisecondsSinceEpoch(timestampValue);
    } else if (timestampValue is DateTime) {
      parsedTimestamp = timestampValue;
    } else {
      parsedTimestamp = DateTime.now(); // Fallback value
    }

    return Trip(
      id: id,
      pickupLocation: map['pickupLocation'] ?? 'Unknown Location',
      dropOffLocation: map['dropOffLocation'] ?? 'Unknown Location',
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      timestamp: parsedTimestamp,
      passengerName: map['name'] ?? 'Unknown Passenger',
      status: map['status'] ?? 'Unknown Status',
    );
  }
}
