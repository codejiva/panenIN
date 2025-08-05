import 'package:PanenIn/shared/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ListLandDashboard extends StatefulWidget {
  const ListLandDashboard({super.key});

  @override
  _ListLandDashboardState createState() => _ListLandDashboardState();
}

class _ListLandDashboardState extends State<ListLandDashboard> {
  bool _isLoading = false;

  // Sample data - in real app this would come from API service
  final List<FieldData> _fields = [
    FieldData(
      id: '1',
      name: 'Land 1',
      status: FieldStatus.healthy,
      location: 'Pemalang, Jawa Tengah',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    FieldData(
      id: '2',
      name: 'Land 2',
      status: FieldStatus.unhealthy,
      location: 'Tegal, Jawa Tengah',
      lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    FieldData(
      id: '3',
      name: 'Land 3',
      status: FieldStatus.critical,
      location: 'Brebes, Jawa Tengah',
      lastUpdated: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SharedAppBar(
        onNotificationPressed: () {
          print('Notifikasi ditekan dari ListLandDashboard!');
        },
        onProfilePressed: () {
          print('Profile ditekan dari ListLandDashboard!');
        },
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Expanded(
                child: _buildFieldList(),
              ),
            ],
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Field Health Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Stay updated with the latest conditions from your IoT sensors',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldList() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _fields.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildFieldCard(_fields[index]),
          );
        },
      ),
    );
  }

  Widget _buildFieldCard(FieldData field) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onFieldCardTapped(field),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildFieldIcon(field.status),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFieldInfo(field),
                ),
                _buildMoreInfoSection(),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldIcon(FieldStatus status) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: _getStatusBackgroundColor(status),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.eco,
        color: _getStatusColor(status),
        size: 28,
      ),
    );
  }

  Widget _buildFieldInfo(FieldData field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        if (field.location != null)
          Text(
            field.location!,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(field.status),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getStatusText(field.status),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoreInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'More',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        Text(
          'Information',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(FieldStatus status) {
    switch (status) {
      case FieldStatus.healthy:
        return Colors.green;
      case FieldStatus.unhealthy:
        return Colors.orange;
      case FieldStatus.critical:
        return Colors.red;
    }
  }

  Color _getStatusBackgroundColor(FieldStatus status) {
    switch (status) {
      case FieldStatus.healthy:
        return Colors.green.withOpacity(0.1);
      case FieldStatus.unhealthy:
        return Colors.orange.withOpacity(0.1);
      case FieldStatus.critical:
        return Colors.red.withOpacity(0.1);
    }
  }

  String _getStatusText(FieldStatus status) {
    switch (status) {
      case FieldStatus.healthy:
        return 'Healthy';
      case FieldStatus.unhealthy:
        return 'Unhealthy';
      case FieldStatus.critical:
        return 'Critical';
    }
  }

  void _onFieldCardTapped(FieldData field) {
    // Debug print to check if tap is working
    print('Field card tapped: ${field.name} with status: ${field.status}');

    // Navigate to detail screen using GoRouter
    try {
      context.push(
        '/monitoring/detail/${field.id}?landName=${Uri.encodeComponent(field.name)}&status=${field.status.name}',
        extra: field, // Pass the entire field object as extra data
      );
    } catch (e) {
      print('Navigation error: $e');
      // Fallback navigation method
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Navigating to ${field.name} detail...'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Implement actual API call to refresh field data
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

      // Update the fields list with new data
      // final newFields = await FieldHealthApiService.fetchFieldData();
      // setState(() {
      //   _fields.clear();
      //   _fields.addAll(newFields);
      // });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil diperbarui'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('Error refreshing field data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

// Models
enum FieldStatus { healthy, unhealthy, critical }

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

// API Service class (similar to your ApiService)
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