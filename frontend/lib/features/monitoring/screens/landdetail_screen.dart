import 'package:PanenIn/models/field_model.dart';
import 'package:PanenIn/features/monitoring/providers/api_services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LandDetailScreen extends StatefulWidget {
  final String landId;
  final String landName;
  final FieldStatus currentStatus;
  final FieldData? fieldData; // Optional field data from navigation

  const LandDetailScreen({
    super.key,
    required this.landId,
    required this.landName,
    required this.currentStatus,
    this.fieldData,
  });

  @override
  _LandDetailScreenState createState() => _LandDetailScreenState();
}

class _LandDetailScreenState extends State<LandDetailScreen> {
  String selectedTimeRange = 'Annually';
  bool _isLoading = false;
  FieldData? _currentFieldData;

  // Sample sensor data
  List<SensorIndicator> _indicators = [];

  // Sample chart data
  final List<ChartDataPoint> _temperatureData = [
    ChartDataPoint(0, 30),
    ChartDataPoint(1, 32),
    ChartDataPoint(2, 28),
    ChartDataPoint(3, 35),
    ChartDataPoint(4, 33),
    ChartDataPoint(5, 34),
    ChartDataPoint(6, 31),
  ];

  @override
  void initState() {
    super.initState();
    _currentFieldData = widget.fieldData;
    _loadFieldData();
  }

  Future<void> _loadFieldData() async {
    setState(() => _isLoading = true);

    try {
      // If we don't have field data, fetch it
      _currentFieldData ??= await FieldHealthApiService.fetchFieldDetail(widget.landId);

      _updateIndicators();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading field data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('Error loading field data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _updateIndicators() {
    final sensorData = _currentFieldData?.sensorData ?? {};

    _indicators = [
      SensorIndicator(
        icon: Icons.thermostat,
        name: 'Temperature',
        value: '${sensorData['temperature']?.toStringAsFixed(1) ?? '34.0'}°C',
        status: _getTemperatureStatus(sensorData['temperature']?.toDouble() ?? 34.0),
      ),
      SensorIndicator(
        icon: Icons.water_drop,
        name: 'Soil Moisture',
        value: '${sensorData['soilMoisture']?.toStringAsFixed(0) ?? '20'}%',
        status: _getSoilMoistureStatus(sensorData['soilMoisture']?.toDouble() ?? 20.0),
      ),
      SensorIndicator(
        icon: Icons.science,
        name: 'Soil pH',
        value: '${sensorData['soilPH']?.toStringAsFixed(1) ?? '5.4'}',
        status: _getSoilPHStatus(sensorData['soilPH']?.toDouble() ?? 5.4),
      ),
      SensorIndicator(
        icon: Icons.wb_sunny,
        name: 'Light Intensity',
        value: '${sensorData['lightIntensity']?.toStringAsFixed(0) ?? '78'}%',
        status: _getLightIntensityStatus(sensorData['lightIntensity']?.toDouble() ?? 78.0),
      ),
      SensorIndicator(
        icon: Icons.cloud,
        name: 'Rainfall Intensity',
        value: '${sensorData['rainfallIntensity']?.toStringAsFixed(0) ?? '50'}%',
        status: _getRainfallIntensityStatus(sensorData['rainfallIntensity']?.toDouble() ?? 50.0),
      ),
    ];
  }

  IndicatorStatus _getTemperatureStatus(double temp) {
    if (temp >= 25 && temp <= 30) return IndicatorStatus.good;
    if (temp >= 20 && temp <= 35) return IndicatorStatus.warning;
    return IndicatorStatus.critical;
  }

  IndicatorStatus _getSoilMoistureStatus(double moisture) {
    if (moisture >= 40 && moisture <= 70) return IndicatorStatus.good;
    if (moisture >= 25 && moisture <= 80) return IndicatorStatus.warning;
    return IndicatorStatus.critical;
  }

  IndicatorStatus _getSoilPHStatus(double ph) {
    if (ph >= 6.0 && ph <= 7.5) return IndicatorStatus.good;
    if (ph >= 5.5 && ph <= 8.0) return IndicatorStatus.warning;
    return IndicatorStatus.critical;
  }

  IndicatorStatus _getLightIntensityStatus(double light) {
    if (light >= 60 && light <= 80) return IndicatorStatus.good;
    if (light >= 40 && light <= 90) return IndicatorStatus.warning;
    return IndicatorStatus.critical;
  }

  IndicatorStatus _getRainfallIntensityStatus(double rainfall) {
    if (rainfall >= 40 && rainfall <= 70) return IndicatorStatus.good;
    if (rainfall >= 20 && rainfall <= 80) return IndicatorStatus.warning;
    return IndicatorStatus.critical;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPlantStatusSection(),
                  const SizedBox(height: 20),
                  _buildIndicatorsSection(),
                  const SizedBox(height: 20),
                  _buildGraphSection(),
                  const SizedBox(height: 20),
                  if (_currentFieldData?.location != null)
                    _buildLocationSection(),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () => context.pop(),
      ),
      title: Text(
        widget.landName,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.black),
          onPressed: _refreshData,
        ),
      ],
    );
  }

  Widget _buildPlantStatusSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Plant Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              if (_currentFieldData?.lastUpdated != null)
                Text(
                  'Updated: ${_formatDateTime(_currentFieldData!.lastUpdated!)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatusOption(
                icon: Icons.sentiment_very_satisfied,
                label: 'Healthy',
                isSelected: widget.currentStatus == FieldStatus.healthy,
                color: Colors.green,
              ),
              _buildStatusOption(
                icon: Icons.sentiment_neutral,
                label: 'UnHealthy',
                isSelected: widget.currentStatus == FieldStatus.unhealthy,
                color: Colors.orange,
              ),
              _buildStatusOption(
                icon: Icons.sentiment_very_dissatisfied,
                label: 'Critical',
                isSelected: widget.currentStatus == FieldStatus.critical,
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey[600],
            size: 30,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? color : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildIndicatorsSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Indicators',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: _refreshIndicators,
                color: Colors.grey[600],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.circle, color: Colors.blue, size: 12),
              const SizedBox(width: 8),
              const Text(
                'Parameter',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Spacer(),
              const Text(
                'Value',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 16),
          ...(_indicators.map((indicator) => _buildIndicatorRow(indicator)).toList()),
        ],
      ),
    );
  }

  Widget _buildIndicatorRow(SensorIndicator indicator) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            indicator.icon,
            size: 20,
            color: Colors.grey[700],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              indicator.name,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            indicator.value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 12),
          _buildStatusIcon(indicator.status),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _refreshSingleIndicator(indicator),
            child: const Icon(
              Icons.refresh,
              size: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(IndicatorStatus status) {
    IconData iconData;
    Color color;

    switch (status) {
      case IndicatorStatus.good:
        iconData = Icons.check_circle;
        color = Colors.green;
        break;
      case IndicatorStatus.warning:
        iconData = Icons.warning;
        color = Colors.orange;
        break;
      case IndicatorStatus.critical:
        iconData = Icons.error;
        color = Colors.red;
        break;
    }

    return Icon(
      iconData,
      size: 18,
      color: color,
    );
  }

  Widget _buildGraphSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Grafik Indicators',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Temperature',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              _buildTimeRangeButtons(),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: _buildSimpleChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeButtons() {
    final timeRanges = ['Daily', 'Weekly', 'Annually'];

    return Row(
      children: timeRanges.map((range) {
        final isSelected = range == selectedTimeRange;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedTimeRange = range;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? Colors.black87 : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              range,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSimpleChart() {
    return CustomPaint(
      size: Size.infinite,
      painter: SimpleChartPainter(_temperatureData),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentFieldData!.location!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);

    try {
      _currentFieldData = await FieldHealthApiService.fetchFieldDetail(widget.landId);
      _updateIndicators();

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
      debugPrint('Error refreshing data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _refreshIndicators() {
    _refreshData();
  }

  void _refreshSingleIndicator(SensorIndicator indicator) {
    // In a real app, this would refresh only the specific indicator
    print('Refreshing ${indicator.name}...');
    _refreshData();
  }
}

// Models
enum FieldStatus { healthy, unhealthy, critical }

enum IndicatorStatus { good, warning, critical }

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

class FieldHealthApiService {
  static const String baseUrl = 'your-api-base-url';

  static Future<FieldData> fetchFieldDetail(String fieldId) async {
    try {
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

// Simple Chart Painter for basic line chart without external dependencies
class SimpleChartPainter extends CustomPainter {
  final List<ChartDataPoint> data;

  SimpleChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final highlightPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Calculate scaling factors
    final maxX = data.map((e) => e.x).reduce((a, b) => a > b ? a : b);
    final minX = data.map((e) => e.x).reduce((a, b) => a < b ? a : b);
    final maxY = data.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    final minY = data.map((e) => e.y).reduce((a, b) => a < b ? a : b);

    final scaleX = size.width / (maxX - minX);
    final scaleY = size.height / (maxY - minY);

    // Create path for line
    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = (data[i].x - minX) * scaleX;
      final y = size.height - (data[i].y - minY) * scaleY;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Complete fill path
    final lastX = (data.last.x - minX) * scaleX;
    fillPath.lineTo(lastX, size.height);
    fillPath.close();

    // Draw fill area
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    canvas.drawPath(path, paint);

    // Draw dots
    for (int i = 0; i < data.length; i++) {
      final x = (data[i].x - minX) * scaleX;
      final y = size.height - (data[i].y - minY) * scaleY;

      if (i == 3) { // Highlight middle point
        canvas.drawCircle(Offset(x, y), 6, highlightPaint);
        canvas.drawCircle(Offset(x, y), 4, Paint()
          ..color = Colors.white);
      } else {
        canvas.drawCircle(Offset(x, y), 3, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}