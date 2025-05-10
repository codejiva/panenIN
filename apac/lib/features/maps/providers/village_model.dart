import 'package:google_maps_flutter/google_maps_flutter.dart';

class Village {
  final String name;
  final String province;
  final List<List<LatLng>> polygons;

  Village({
    required this.name,
    required this.province,
    required this.polygons,
  });

  factory Village.fromJson(Map<String, dynamic> json) {
    return Village(
      name: json['nama_kabupaten'],
      province: json['provinsi'],
      polygons: (json['koordinat'] as List).map((polygon) {
        return (polygon as List).map((point) {
          return LatLng(point[1], point[0]); // Convert [lng,lat] to LatLng
        }).toList();
      }).toList(),
    );
  }
}