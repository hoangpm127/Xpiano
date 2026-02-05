class PianoModel {
  final String id;
  final String name;
  final String imageUrl;
  final int pricePerMonth;
  final bool isAvailable;
  final String brand;
  final String description;
  final int keys; // Số phím (61, 76, 88)

  PianoModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.pricePerMonth,
    required this.isAvailable,
    required this.brand,
    required this.description,
    required this.keys,
  });

  factory PianoModel.fromJson(Map<String, dynamic> json) {
    return PianoModel(
      id: json['id'].toString(),
      name: json['name'] ?? 'Unknown',
      imageUrl: json['image_url'] ?? 'https://source.unsplash.com/random/800x600/?piano',
      pricePerMonth: json['price_per_month'] ?? 0,
      isAvailable: json['is_available'] ?? true,
      brand: json['brand'] ?? 'Yamaha',
      description: json['description'] ?? '',
      keys: json['keys'] ?? 88,
    );
  }
}
