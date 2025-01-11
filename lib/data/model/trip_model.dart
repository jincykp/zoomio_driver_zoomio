class Trip {
  final String id;
  final String pickupLocation;
  final String dropOffLocation;
  final double totalPrice;
  final DateTime timestamp;
  final String passengerName;

  Trip({
    required this.id,
    required this.pickupLocation,
    required this.dropOffLocation,
    required this.totalPrice,
    required this.timestamp,
    required this.passengerName,
  });

  factory Trip.fromMap(String id, Map<dynamic, dynamic> map) {
    return Trip(
      id: id,
      pickupLocation: map['pickupLocation'] ?? 'Unknown Location',
      dropOffLocation: map['dropOffLocation'] ?? 'Unknown Location',
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      timestamp:
          DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      passengerName: map['passengerName'] ?? 'Unknown Passenger',
    );
  }
}
