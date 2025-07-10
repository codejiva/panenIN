// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:PanenIn/features/maps/providers/village_model.dart';

class ApiService {
  static const String _baseUrl = 'http://192.168.1.100:5000/api';

  static Future<Village> fetchVillageData(String kabupaten) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/search?kabupaten=$kabupaten'),
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
      throw Exception('Failed to load village data');
    }
  }
}