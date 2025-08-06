import 'package:PanenIn/shared/widgets/appbar.dart';
import 'package:PanenIn/features/home/services/google_maps_service.dart';
import 'package:PanenIn/config/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

// Enum untuk status sensor
enum SensorStatus { good, warning, bad }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Controller untuk Google Maps dan animasi
  GoogleMapController? mapController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Koordinat default untuk peta (misalnya: Jakarta)
  final LatLng _center = const LatLng(-6.2088, 106.8456);
  int touchedIndex = -1;
  bool _isMapLoading = true;
  String? _mapError;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _initializeGoogleMaps();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeGoogleMaps() async {
    try {
      await GoogleMapsService.initialize();
      if (!GoogleMapsService.isValidApiKey(AppConstants.googleMapsApiKey)) {
        throw Exception('Invalid Google Maps API key format');
      }
      setState(() {
        _isMapLoading = false;
      });
    } catch (e) {
      setState(() {
        _isMapLoading = false;
        _mapError = e.toString();
      });
      print('Error initializing Google Maps: $e');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: SharedAppBar(
        onNotificationPressed: () {
          print('Notifikasi ditekan dari HomeScreen!');
        },
        onProfilePressed: () {
          print('Profile ditekan dari HomeScreen!');
        },
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeHeader(),
                const SizedBox(height: 24),
                // _buildQuickStatsCards(),
                // const SizedBox(height: 24),
                _buildMainDashboard(),
                const SizedBox(height: 24),
                _buildMapSection(),
                const SizedBox(height: 24),
                _buildPlantHealthChart(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF307D32),
            const Color(0xFF4CAF50),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF307D32).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back, Farmer!',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Monitor your crops with smart technology',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.agriculture,
              size: 32,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildQuickStatsCards() {
  //   return Row(
  //     children: [
  //       Expanded(
  //         child: _buildStatCard(
  //           title: 'Active Sensors',
  //           value: '12',
  //           icon: Icons.sensors,
  //           color: const Color(0xFF2196F3),
  //           trend: '+2',
  //         ),
  //       ),
  //       const SizedBox(width: 12),
  //       Expanded(
  //         child: _buildStatCard(
  //           title: 'Plant Health',
  //           value: '78%',
  //           icon: Icons.local_florist,
  //           color: const Color(0xFF4CAF50),
  //           trend: '+5%',
  //         ),
  //       ),
  //       const SizedBox(width: 12),
  //       Expanded(
  //         child: _buildStatCard(
  //           title: 'Alerts',
  //           value: '3',
  //           icon: Icons.warning_amber,
  //           color: const Color(0xFFFF9800),
  //           trend: '-1',
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                trend,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: trend.startsWith('+') ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainDashboard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sensor Monitoring',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 8, color: Colors.red),
                      const SizedBox(width: 6),
                      Text(
                        'Alert Status',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildEnhancedSensorGrid(),
            const SizedBox(height: 20),
            _buildRecommendationSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedSensorGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildModernSensorTile(
                icon: Icons.thermostat_outlined,
                title: 'Temperature',
                value: '34°C',
                description: 'High temperature',
                status: SensorStatus.bad,
                gradient: [Colors.red.shade400, Colors.red.shade600],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildModernSensorTile(
                icon: Icons.water_drop_outlined,
                title: 'Soil Moisture',
                value: '20%',
                description: 'Low moisture',
                status: SensorStatus.bad,
                gradient: [Colors.orange.shade400, Colors.orange.shade600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildModernSensorTile(
                icon: Icons.science_outlined,
                title: 'Soil pH',
                value: '5.4',
                description: 'Slightly acidic',
                status: SensorStatus.warning,
                gradient: [Colors.amber.shade400, Colors.amber.shade600],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildModernSensorTile(
                icon: Icons.wb_sunny_outlined,
                title: 'Light Intensity',
                value: '78%',
                description: 'Optimal light',
                status: SensorStatus.good,
                gradient: [Colors.green.shade400, Colors.green.shade600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernSensorTile({
    required IconData icon,
    required String title,
    required String value,
    required String description,
    required SensorStatus status,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              Icon(
                _getStatusIcon(status),
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(SensorStatus status) {
    switch (status) {
      case SensorStatus.good:
        return Icons.check_circle;
      case SensorStatus.warning:
        return Icons.warning;
      case SensorStatus.bad:
        return Icons.error;
    }
  }

  Widget _buildMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Farm Location',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                // Navigate to full map
              },
              icon: Icon(Icons.open_in_full, size: 16),
              label: Text('View Full Map'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF307D32),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _buildMapContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildMapContent() {
    if (_isMapLoading) {
      return Container(
        color: Colors.grey[100],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: const Color(0xFF307D32),
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading Map...',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_mapError != null) {
      return Container(
        color: Colors.red[50],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Map Unavailable',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Using offline map view',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.red[600],
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isMapLoading = true;
                    _mapError = null;
                  });
                  _initializeGoogleMaps();
                },
                child: Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF307D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Fallback jika Google Maps gagal load
    try {
      return GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: AppConstants.defaultMapZoom,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('farm_location'),
            position: _center,
            infoWindow: const InfoWindow(
              title: 'Your Farm',
              snippet: 'Smart Farming Location',
            ),
          ),
        },
      );
    } catch (e) {
      // Jika masih error, tampilkan placeholder
      return Container(
        color: Colors.green[50],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, color: Colors.green, size: 48),
              const SizedBox(height: 16),
              Text(
                'Farm Location',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              Text(
                'Jakarta, Indonesia',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.green[600],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildPlantHealthChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plant Health Overview',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 180,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: showingSections(),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    _buildModernLegendItem(
                      color: const Color(0xFF4CAF50),
                      label: 'Healthy',
                      percentage: '55%',
                    ),
                    const SizedBox(height: 12),
                    _buildModernLegendItem(
                      color: Colors.orange,
                      label: 'Warning',
                      percentage: '20%',
                    ),
                    const SizedBox(height: 12),
                    _buildModernLegendItem(
                      color: Colors.red,
                      label: 'Critical',
                      percentage: '25%',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernLegendItem({
    required Color color,
    required String label,
    required String percentage,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          percentage,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.blue.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                'Smart Recommendations',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Based on current sensor data, your plants need immediate attention due to water stress and high temperature.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.blue.shade700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          ...['Increase irrigation immediately', 'Add mulching for temperature control', 'Monitor pH levels'].map(
                (recommendation) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(3, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 65.0 : 60.0;

      switch (i) {
        case 0:
          return PieChartSectionData(
            color: const Color(0xFF4CAF50),
            value: 55,
            title: '55%',
            radius: radius,
            titleStyle: GoogleFonts.inter(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.orange,
            value: 20,
            title: '20%',
            radius: radius,
            titleStyle: GoogleFonts.inter(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        case 2:
          return PieChartSectionData(
            color: Colors.red,
            value: 25,
            title: '25%',
            radius: radius,
            titleStyle: GoogleFonts.inter(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        default:
          throw Error();
      }
    });
  }
}