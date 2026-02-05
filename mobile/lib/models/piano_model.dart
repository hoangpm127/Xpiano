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
}
