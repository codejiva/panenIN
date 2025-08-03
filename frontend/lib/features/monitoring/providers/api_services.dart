// File: lib/features/monitoring/services/field_health_api_service.dart

import 'package:PanenIn/models/field_models.dart';

class FieldHealthApiService {
  static const String baseUrl = 'your-api-base-url';

  static Future<List<FieldData>> fetchFieldData() async {
    try {
      // TODO: Implement actual API call
      // final response = await http.get(
      //   Uri.parse('$baseUrl/fields'),
      //   headers: {'Authorization': 'Bearer $token'},
      // );
      // if (response.statusCode == 200) {
      //   final List<dynamic> data = json.decode(response.body);
      //   return data.map((json) => FieldData.fromJson(json)).toList();
      // }

      // For now, return sample data
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      return [
        FieldData(
          id: '1',
          name: 'Land 1',
          status: FieldStatus.healthy,
          location: 'Pemalang, Jawa Tengah',
          lastUpdated: DateTime.now(),
        ),
        FieldData(
          id: '2',
          name: 'Land 2',
          status: FieldStatus.unhealthy,
          location: 'Tegal, Jawa Tengah',
          lastUpdated: DateTime.now(),
        ),
        FieldData(
          id: '3',
          name: 'Land 3',
          status: FieldStatus.critical,
          location: 'Brebes, Jawa Tengah',
          lastUpdated: DateTime.now(),
        ),
      ];
    } catch (e) {
      throw Exception('Failed to fetch field data: $e');
    }
  }

  static Future<FieldData> fetchFieldDetail(String fieldId) async {
    try {
      // TODO: Implement actual API call for field details
      // final response = await http.get(
      //   Uri.parse('$baseUrl/fields/$fieldId'),
      //   headers: {'Authorization': 'Bearer $token'},
      // );
      // if (response.statusCode == 200) {
      //   return FieldData.fromJson(json.decode(response.body));
      // }

      await Future.delayed(const Duration(milliseconds: 500));
      return FieldData(
        id: fieldId,
        name: 'Land $fieldId',
        status: FieldStatus.healthy,
        location: 'Pemalang, Jawa Tengah',
        lastUpdated: DateTime.now(),
        sensorData: {
          'temperature': 25.5,
          'humidity': 60.2,
          'soilMoisture': 45.8,
          'soilPH': 6.5,
          'lightIntensity': 78.0,
          'rainfallIntensity': 50.0,
        },
      );
    } catch (e) {
      throw Exception('Failed to fetch field detail: $e');
    }
  }
}