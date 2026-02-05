/// Piano model
class Piano {
  final String id;
  final String brand;
  final String model;
  final int keysCount;
  final bool hasMidi;
  final bool hasBluetooth;
  final double dailyRate;
  final double monthlyRate;
  final String imageUrl;
  final String warehouseId;
  final String warehouseName;
  final double distanceKm;
  final bool isAvailable;
  
  Piano({
    required this.id,
    required this.brand,
    required this.model,
    required this.keysCount,
    required this.hasMidi,
    required this.hasBluetooth,
    required this.dailyRate,
    required this.monthlyRate,
    required this.imageUrl,
    required this.warehouseId,
    required this.warehouseName,
    required this.distanceKm,
    required this.isAvailable,
  });
  
  factory Piano.fromJson(Map<String, dynamic> json) {
    return Piano(
      id: json['id'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      keysCount: json['keysCount'] as int,
      hasMidi: json['hasMidi'] as bool,
      hasBluetooth: json['hasBluetooth'] as bool,
      dailyRate: (json['dailyRate'] as num).toDouble(),
      monthlyRate: (json['monthlyRate'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      warehouseId: json['warehouseId'] as String,
      warehouseName: json['warehouseName'] as String,
      distanceKm: (json['distanceKm'] as num).toDouble(),
      isAvailable: json['isAvailable'] as bool,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'keysCount': keysCount,
      'hasMidi': hasMidi,
      'hasBluetooth': hasBluetooth,
      'dailyRate': dailyRate,
      'monthlyRate': monthlyRate,
      'imageUrl': imageUrl,
      'warehouseId': warehouseId,
      'warehouseName': warehouseName,
      'distanceKm': distanceKm,
      'isAvailable': isAvailable,
    };
  }
}
