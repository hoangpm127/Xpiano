class Piano {
  final int id;
  final String name;
  final String imageUrl;
  final String category;
  final double pricePerHour;
  final double rating;
  final String description;
  final String? brand;
  final bool? isAvailable;

  Piano({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.category,
    required this.pricePerHour,
    required this.rating,
    required this.description,
    this.brand,
    this.isAvailable,
  });

  factory Piano.fromJson(Map<String, dynamic> json) {
    return Piano(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown Piano',
      imageUrl: json['image_url'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      pricePerHour: (json['price_per_hour'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      brand: json['brand'] as String?,
      isAvailable: json['is_available'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'category': category,
      'price_per_hour': pricePerHour,
      'rating': rating,
      'description': description,
      'brand': brand,
      'is_available': isAvailable,
    };
  }

  String get formattedPrice => '${pricePerHour.toStringAsFixed(0)}K VNĐ/giờ';
  String get formattedRating => rating.toStringAsFixed(1);
}
