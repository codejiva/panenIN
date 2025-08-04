import 'package:flutter/material.dart';

enum FieldStatus { healthy, unhealthy, critical }

enum IndicatorStatus { good, warning, critical }

class FieldData {
  final String id;
  final String name;
  final FieldStatus status;
  final String? location;
  final DateTime? lastUpdated;
  final Map<String, dynamic>? sensorData;

  FieldData({
    required this.id,
    required this.name,
    required this.status,
    this.location,
    this.lastUpdated,
    this.sensorData,
  });

  factory FieldData.fromJson(Map<String, dynamic> json) {
    return FieldData(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      status: _parseStatus(json['status']),
      location: json['location'],
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
      sensorData: json['sensorData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status.name,
      'location': location,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'sensorData': sensorData,
    };
  }

  static FieldStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'healthy':
        return FieldStatus.healthy;
      case 'unhealthy':
        return FieldStatus.unhealthy;
      case 'critical':
        return FieldStatus.critical;
      default:
        return FieldStatus.healthy;
    }
  }
}

class SensorIndicator {
  final IconData icon;
  final String name;
  final String value;
  final IndicatorStatus status;

  SensorIndicator({
    required this.icon,
    required this.name,
    required this.value,
    required this.status,
  });
}

class ChartDataPoint {
  final double x;
  final double y;

  ChartDataPoint(this.x, this.y);
}