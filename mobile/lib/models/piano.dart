class Piano {
  final int id;
  final String name;
  final String imageUrl;
  final String category;
  final double pricePerHour;
  final double dailyPrice;
  final double depositAmount;
  final String status;
  final double rating;
  final String description;
  final String? brand;
  final bool? isAvailable;
  final String location;
  final int reviewsCount;
  final List<String> features;

  Piano({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.category,
    required this.pricePerHour,
    required this.dailyPrice,
    required this.depositAmount,
    required this.status,
    required this.rating,
    required this.description,
    this.brand,
    this.isAvailable,
    required this.location,
    required this.reviewsCount,
    required this.features,
  });

  factory Piano.fromJson(Map<String, dynamic> json) {
    final rawPricePerHour = (json['price_per_hour'] as num?)?.toDouble() ?? 0.0;
    final rawDailyPrice = (json['daily_price'] as num?)?.toDouble() ?? 0.0;
    final rawDepositAmount =
        (json['deposit_amount'] as num?)?.toDouble() ?? 0.0;
    final rawStatus = (json['status'] as String?)?.trim().toLowerCase();
    final rawIsAvailable = json['is_available'] as bool?;

    final normalizedStatus = (rawStatus == null || rawStatus.isEmpty)
        ? ((rawIsAvailable ?? true) ? 'available' : 'rented')
        : rawStatus;

    return Piano(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown Piano',
      imageUrl: json['image_url'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      pricePerHour: rawPricePerHour,
      dailyPrice: rawDailyPrice > 0 ? rawDailyPrice : rawPricePerHour,
      depositAmount: rawDepositAmount,
      status: normalizedStatus,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      brand: json['brand'] as String?,
      isAvailable: rawIsAvailable ?? normalizedStatus == 'available',
      location: json['location'] as String? ?? 'TP.HCM',
      reviewsCount: json['reviews_count'] as int? ?? 0,
      features: json['features'] != null
          ? List<String>.from(json['features'] as List)
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'category': category,
      'price_per_hour': pricePerHour,
      'daily_price': dailyPrice,
      'deposit_amount': depositAmount,
      'status': status,
      'rating': rating,
      'description': description,
      'brand': brand,
      'is_available': isAvailable,
      'location': location,
      'reviews_count': reviewsCount,
      'features': features,
    };
  }

  String get formattedPrice => '${pricePerHour.toStringAsFixed(0)},000đ/giờ';
  String get formattedDailyPrice =>
      '${dailyPrice.toStringAsFixed(0)},000đ/ngày';
  String get formattedDeposit => '${depositAmount.toStringAsFixed(0)},000đ';
  String get formattedRating => rating.toStringAsFixed(1);

  // Convert to pianoData map for PianoDetailScreen.
  Map<String, dynamic> toPianoData() {
    return {
      'id': id.toString(),
      'name': name,
      'category': category,
      'price': formattedPrice,
      'location': location,
      'rating': rating,
      'reviews': reviewsCount,
      'image': imageUrl,
      'available': isAvailable ?? true,
      'daily_price': dailyPrice,
      'deposit_amount': depositAmount,
      'status': status,
      'features': features,
    };
  }
}
