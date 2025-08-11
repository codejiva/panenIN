import 'dart:convert';
import 'package:PanenIn/features/home/models/dashboard_model.dart';
import 'package:http/http.dart' as http;

class DashboardService {
  static const String _baseUrl = 'https://panen-in-teal.vercel.app/api';

  static Future<DashboardData?> fetchDashboardData() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/dashboard/summary'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return DashboardData.fromJson(data);
      } else {
        print('Failed to load dashboard data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching dashboard data: $e');
      return null;
    }
  }
}