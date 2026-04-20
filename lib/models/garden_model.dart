class GardenModel {
  final String id;
  final String originalImagePath;
  final String resultImagePath;
  final String styleName;
  final DateTime timestamp;
  final Map<String, dynamic> settings;
  final bool isFavorite;

  const GardenModel({
    required this.id,
    required this.originalImagePath,
    required this.resultImagePath,
    required this.styleName,
    required this.timestamp,
    this.settings = const {},
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalImagePath': originalImagePath,
      'resultImagePath': resultImagePath,
      'styleName': styleName,
      'timestamp': timestamp.toIso8601String(),
      'settings': settings,
      'isFavorite': isFavorite,
    };
  }

  factory GardenModel.fromJson(Map<String, dynamic> json) {
    return GardenModel(
      id: json['id'],
      originalImagePath: json['originalImagePath'],
      resultImagePath: json['resultImagePath'],
      styleName: json['styleName'],
      timestamp: DateTime.parse(json['timestamp']),
      settings: json['settings'] ?? {},
      isFavorite: json['isFavorite'] ?? false,
    );
  }
}
