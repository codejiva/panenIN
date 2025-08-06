import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardData {
  final double temperature;
  final double humidity;
  final double soilPH;
  final DateTime timestamp;

  DashboardData({
    required this.temperature,
    required this.humidity,
    required this.soilPH,
    required this.timestamp,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      temperature: double.parse(json['temperature']),
      humidity: double.parse(json['humidity']),
      soilPH: double.parse(json['soilPH']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
