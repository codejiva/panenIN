import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:PanenIn/features/maps/providers/village_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ApiService {
  static const String _baseUrl = 'https://panen-in-teal.vercel.app/api';

  static Future<Village> fetchVillageData(String kabupaten) async {
    // Coba search di API dulu
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search?kabupaten=${Uri.encodeComponent(kabupaten)}'),
      );

      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);

        // Handle both single object and array responses
        if (jsonData is List) {
          if (jsonData.isEmpty) {
            throw Exception('No village data found');
          }
          return Village.fromJson(jsonData.first);
        } else if (jsonData is Map<String, dynamic>) {
          return Village.fromJson(jsonData);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load village data: ${response.statusCode}');
      }
    } catch (e) {
      // Jika API gagal, cari di data lokal Kabupaten Bogor
      final localData = await searchLocalBogorData(kabupaten);
      if (localData != null) {
        return localData;
      }
      throw Exception('Data tidak ditemukan: ${e.toString()}');
    }
  }

  // Method untuk mencari data lokal Kabupaten Bogor
  static Future<Village?> searchLocalBogorData(String query) async {
    final kecamatanList = getBogorKecamatanList();

    // Cari kecamatan yang cocok dengan query
    for (var kecamatan in kecamatanList) {
      if (kecamatan.name.toLowerCase().contains(query.toLowerCase()) ||
          query.toLowerCase().contains(kecamatan.name.toLowerCase().replaceAll('kec. ', ''))) {
        return kecamatan;
      }
    }

    return null;
  }

  // Data kecamatan Kabupaten Bogor yang lengkap
  static List<Village> getBogorKecamatanList() {
    return [
      Village(
        name: "Kec. Nanggung",
        province: "Jawa Barat",
        polygons: [
          [
            LatLng(-6.4394, 106.6342),
            LatLng(-6.4394, 106.6742),
            LatLng(-6.3994, 106.6742),
            LatLng(-6.3994, 106.6342),
          ]
        ],
        district: "Nanggung",
        regency: "Bogor",
        status: "Zona Pertanian Aktif",
      ),
      Village(
        name: "Kec. Leuwiliang",
        province: "Jawa Barat",
        polygons: [
          [
            LatLng(-6.4783, 106.6717),
            LatLng(-6.4783, 106.7117),
            LatLng(-6.4383, 106.7117),
            LatLng(-6.4383, 106.6717),
          ]
        ],
        district: "Leuwiliang",
        regency: "Bogor",
        status: "Zona Pertanian Aktif",
      ),
      Village(
        name: "Kec. Pamijahan",
        province: "Jawa Barat",
        polygons: [
          [
            LatLng(-6.5367, 106.7133),
            LatLng(-6.5367, 106.7533),
            LatLng(-6.4967, 106.7533),
            LatLng(-6.4967, 106.7133),
          ]
        ],
        district: "Pamijahan",
        regency: "Bogor",
        status: "Zona Pertanian Aktif",
      ),
      Village(
        name: "Kec. Cibungbulang",
        province: "Jawa Barat",
        polygons: [
          [
            LatLng(-6.5033, 106.7467),
            LatLng(-6.5033, 106.7867),
            LatLng(-6.4633, 106.7867),
            LatLng(-6.4633, 106.7467),
          ]
        ],
        district: "Cibungbulang",
        regency: "Bogor",
        status: "Zona Pertanian Aktif",
      ),
      Village(
        name: "Kec. Ciampea",
        province: "Jawa Barat",
        polygons: [
          [
            LatLng(-6.5700, 106.6800),
            LatLng(-6.5700, 106.7200),
            LatLng(-6.5300, 106.7200),
            LatLng(-6.5300, 106.6800),
          ]
        ],
        district: "Ciampea",
        regency: "Bogor",
        status: "Zona Pertanian Aktif",
      ),
      Village(
        name: "Kec. Dramaga",
        province: "Jawa Barat",
        polygons: [
          [
            LatLng(-6.5658, 106.7161),
            LatLng(-6.5658, 106.7561),
            LatLng(-6.5258, 106.7561),
            LatLng(-6.5258, 106.7161),
          ]
        ],
        district: "Dramaga",
        regency: "Bogor",
        status: "Zona Pertanian Aktif",
      ),
      Village(
        name: "Kec. Ciomas",
        province: "Jawa Barat",
        polygons: [
          [
            LatLng(-6.6172, 106.7633),
            LatLng(-6.6172, 106.8033),
            LatLng(-6.5772, 106.8033),
            LatLng(-6.5772, 106.7633),
          ]
        ],
        district: "Ciomas",
        regency: "Bogor",
        status: "Zona Pertanian Aktif",
      ),
      Village(
        name: "Kec. Tamansari",
        province: "Jawa Barat",
        polygons: [
          [
            LatLng(-6.6533, 106.7800),
            LatLng(-6.6533, 106.8200),
            LatLng(-6.6133, 106.8200),
            LatLng(-6.6133, 106.7800),
          ]
        ],
        district: "Tamansari",
        regency: "Bogor",
        status: "Zona Pertanian Aktif",
      ),
      Village(
        name: "Kec. Kemang",
        province: "Jawa Barat",
        polygons: [
          [
            LatLng(-6.6367, 106.8133),
            LatLng(-6.6367, 106.8533),
            LatLng(-6.5967, 106.8533),
            LatLng(-6.5967, 106.8133),
          ]
        ],
        district: "Kemang",
        regency: "Bogor",
        status: "Zona Pertanian Aktif",
      ),
      Village(
        name: "Kec. Ranca Bungur",
        province: "Jawa Barat",
        polygons: [
          [
            LatLng(-6.6700, 106.8467),
            LatLng(-6.6700, 106.8867),
            LatLng(-6.6300, 106.8867),
            LatLng(-6.6300, 106.8467),
          ]
        ],
        district: "Ranca Bungur",
        regency: "Bogor",
        status: "Zona Pertanian Aktif",
      ),
      Village(
        name: "Kec. Parung",
        province: "Jawa Barat",
        polygons: [
          [
            LatLng(-6.4417, 106.7106),
            LatLng(-6.4417, 106.7506),
            LatLng(-6.4017, 106.7506),
            LatLng(-6.4017, 106.7106),
          ]
        ],
        district: "Parung",
        regency: "Bogor",
        status: "Zona Pertanian Aktif",
      ),
      Village(
        name: "Kec. Gunung Sindur",
        province: "Jawa Barat",
        polygons: [
          [
            LatLng(-6.4200, 106.6800),
            LatLng(-6.4200, 106.7200),
            LatLng(-6.3800, 106.7200),
            LatLng(-6.3800, 106.6800),
          ]
        ],
        district: "Gunung Sindur",
        regency: "Bogor",
        status: "Zona Pertanian Aktif",
      ),
      Village(
        name: "Kec. Cibinong",
        province: "Jawa Barat",
        polygons: [
          [
            LatLng(-6.5017, 106.8342),
            LatLng(-6.5017, 106.8742),
            LatLng(-6.4617, 106.8742),
            LatLng(-6.4617, 106.8342),
          ]
        ],
        district: "Cibinong",
        regency: "Bogor",
        status: "Zona Pertanian Aktif",
      ),
      // Tambahkan kecamatan lainnya sesuai kebutuhan
    ];
  }

  // Method untuk mendapatkan semua data Kabupaten Bogor
  static Future<List<Village>> getAllBogorKecamatan() async {
    return getBogorKecamatanList();
  }

  // Method untuk search kecamatan di Bogor
  static Future<List<Village>> searchBogorKecamatan(String query) async {
    final allKecamatan = getBogorKecamatanList();

    if (query.isEmpty) return allKecamatan;

    return allKecamatan.where((kecamatan) {
      return kecamatan.name.toLowerCase().contains(query.toLowerCase()) ||
          kecamatan.district?.toLowerCase().contains(query.toLowerCase()) == true;
    }).toList();
  }
}