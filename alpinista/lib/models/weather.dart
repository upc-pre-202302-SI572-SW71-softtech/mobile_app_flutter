class DeviceData {
  final int id;
  final double temperature;
  final int humidity;
  final String position;

  DeviceData({
    required this.id,
    required this.temperature,
    required this.humidity,
    required this.position,
  });

  factory DeviceData.fromJson(Map<String, dynamic> json) {
    return DeviceData(
      id: json['ID'] ?? 0,
      temperature: _parseDouble(json['temperature']) ?? 0.0,
      humidity: _parseInt(json['humidity']) ?? 0,
      position: json['position'] ?? '',
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value is int) {
      return value;
    } else if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }
}