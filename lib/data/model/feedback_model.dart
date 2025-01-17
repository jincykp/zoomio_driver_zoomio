class FeedbackModel {
  final double rating;
  final String? comment;
  final String bookingId;
  final DateTime timestamp;

  FeedbackModel({
    required this.rating,
    this.comment,
    required this.bookingId,
    required this.timestamp,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String?,
      bookingId: json['bookingId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'comment': comment,
      'bookingId': bookingId,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
