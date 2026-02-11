class Booking {
  final int id;
  final int pianoId;
  final DateTime startTime;
  final DateTime endTime;
  final double totalPrice;
  final String status;
  final DateTime createdAt;
  final String? pianoName;
  final String? pianoImage;

  Booking({
    required this.id,
    required this.pianoId,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.pianoName,
    this.pianoImage,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as int,
      pianoId: json['piano_id'] as int,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      totalPrice: (json['total_price'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      pianoName: json['pianos'] != null ? json['pianos']['name'] as String? : null,
      pianoImage: json['pianos'] != null ? json['pianos']['image_url'] as String? : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'piano_id': pianoId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'total_price': totalPrice,
      'status': status,
    };
  }
}
