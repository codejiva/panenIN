import 'package:google_maps_flutter/google_maps_flutter.dart';

class Village {
  final String name;
  final String province;
  final List<List<LatLng>> polygons;
  final String? district;
  final String? regency;
  final String? status;
  final Map<String, dynamic>? additionalData;

  Village({
    required this.name,
    required this.province,
    required this.polygons,
    this.district,
    this.regency,
    this.status,
    this.additionalData,
  });

  factory Village.fromJson(Map<String, dynamic> json) {
    List<List<LatLng>> polygonsList = [];

    if (json['koordinat'] != null) {
      polygonsList = (json['koordinat'] as List).map((polygon) {
        return (polygon as List).map((point) {
          // Handle different coordinate formats
          if (point is List && point.length >= 2) {
            return LatLng(
              point[1].toDouble(), // latitude
              point[0].toDouble(), // longitude
            );
          }
          return LatLng(0.0, 0.0); // fallback
        }).toList();
      }).toList();
    }

    return Village(
      name: json['nama_kabupaten'] ?? json['name'] ?? 'Unknown',
      province: json['provinsi'] ?? json['province'] ?? 'Unknown Province',
      polygons: polygonsList,
      district: json['kecamatan'] ?? json['district'],
      regency: json['kabupaten'] ?? json['regency'],
      status: json['status'] ?? 'Unknown',
      additionalData: json['additional_info'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_kabupaten': name,
      'provinsi': province,
      'koordinat': polygons.map((polygon) {
        return polygon.map((point) => [point.longitude, point.latitude]).toList();
      }).toList(),
      'kecamatan': district,
      'kabupaten': regency,
      'status': status,
      'additional_info': additionalData,
    };
  }

  // Get center point of all polygons
  LatLng getCenter() {
    if (polygons.isEmpty || polygons.first.isEmpty) {
      return const LatLng(-6.597147, 106.799148); // Default Bogor center
    }

    double totalLat = 0;
    double totalLng = 0;
    int pointCount = 0;

    for (var polygon in polygons) {
      for (var point in polygon) {
        totalLat += point.latitude;
        totalLng += point.longitude;
        pointCount++;
      }
    }

    if (pointCount == 0) {
      return const LatLng(-6.597147, 106.799148);
    }

    return LatLng(totalLat / pointCount, totalLng / pointCount);
  }

  // Get bounding box of all polygons
  LatLngBounds getBounds() {
    if (polygons.isEmpty || polygons.first.isEmpty) {
      const fallback = LatLng(-6.597147, 106.799148);
      return LatLngBounds(southwest: fallback, northeast: fallback);
    }

    double minLat = polygons.first.first.latitude;
    double maxLat = polygons.first.first.latitude;
    double minLng = polygons.first.first.longitude;
    double maxLng = polygons.first.first.longitude;

    for (var polygon in polygons) {
      for (var point in polygon) {
        minLat = minLat > point.latitude ? point.latitude : minLat;
        maxLat = maxLat < point.latitude ? point.latitude : maxLat;
        minLng = minLng > point.longitude ? point.longitude : minLng;
        maxLng = maxLng < point.longitude ? point.longitude : maxLng;
      }
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  String toString() {
    return 'Village(name: $name, province: $province, district: $district, regency: $regency, status: $status)';
  }
}

// Additional model for district information
class DistrictInfo {
  final String id;
  final String name;
  final String fullName;
  final LatLng center;
  final String province;
  final String regency;
  final String status;
  final List<String> features;
  final Map<String, dynamic>? metadata;

  DistrictInfo({
    required this.id,
    required this.name,
    required this.fullName,
    required this.center,
    required this.province,
    required this.regency,
    required this.status,
    this.features = const [],
    this.metadata,
  });

  factory DistrictInfo.fromJson(Map<String, dynamic> json) {
    return DistrictInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      fullName: json['full_name'] ?? json['name'] ?? '',
      center: LatLng(
        json['center_lat']?.toDouble() ?? 0.0,
        json['center_lng']?.toDouble() ?? 0.0,
      ),
      province: json['province'] ?? '',
      regency: json['regency'] ?? '',
      status: json['status'] ?? 'Unknown',
      features: List<String>.from(json['features'] ?? []),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'full_name': fullName,
      'center_lat': center.latitude,
      'center_lng': center.longitude,
      'province': province,
      'regency': regency,
      'status': status,
      'features': features,
      'metadata': metadata,
    };
  }
}