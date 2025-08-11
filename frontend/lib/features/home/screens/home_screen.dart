import 'package:PanenIn/shared/widgets/appbar.dart';
import 'package:PanenIn/features/home/services/google_maps_service.dart';
import 'package:PanenIn/features/home/services/dashboard_service.dart';
import 'package:PanenIn/config/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';

import '../models/dashboard_model.dart';

enum SensorStatus { good, warning, bad }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  // Google Maps Controller dengan proper disposal
  GoogleMapController? mapController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Dashboard data
  DashboardData? _dashboardData;
  bool _isLoadingData = true;
  String? _dataError;
  Timer? _dataRefreshTimer;

  // Map state management
  final LatLng _center = const LatLng(-6.2088, 106.8456);
  int touchedIndex = -1;
  bool _isMapLoading = true;
  String? _mapError;
  bool _mapDisposed = false;

  // Responsive breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeGoogleMaps();
    _initializeDashboard();
    _animationController.forward();
  }

  void _initializeAnimations() {
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
  }

  @override
  void dispose() {
    _mapDisposed = true;
    _animationController.dispose();
    _dataRefreshTimer?.cancel();

    // Properly dispose map controller
    if (mapController != null) {
      mapController!.dispose();
      mapController = null;
    }
    super.dispose();
  }

  Future<void> _initializeDashboard() async {
    await _fetchDashboardData();
    if (mounted) {
      _dataRefreshTimer = Timer.periodic(
        const Duration(seconds: 30), // Reduced frequency
            (timer) => _fetchDashboardData(),
      );
    }
  }

  Future<void> _fetchDashboardData() async {
    if (_mapDisposed || !mounted) return;

    try {
      final data = await DashboardService.fetchDashboardData();
      if (mounted && !_mapDisposed) {
        setState(() {
          _dashboardData = data;
          _isLoadingData = false;
          _dataError = data == null ? 'Failed to load data' : null;
        });
      }
    } catch (e) {
      if (mounted && !_mapDisposed) {
        setState(() {
          _isLoadingData = false;
          _dataError = 'Error: $e';
        });
      }
    }
  }

  Future<void> _initializeGoogleMaps() async {
    if (_mapDisposed) return;

    try {
      await GoogleMapsService.initialize();
      if (!GoogleMapsService.isValidApiKey(AppConstants.googleMapsApiKey)) {
        throw Exception('Invalid Google Maps API key format');
      }
      if (mounted && !_mapDisposed) {
        setState(() {
          _isMapLoading = false;
        });
      }
    } catch (e) {
      if (mounted && !_mapDisposed) {
        setState(() {
          _isMapLoading = false;
          _mapError = e.toString();
        });
      }
      debugPrint('Error initializing Google Maps: $e');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    if (_mapDisposed) {
      controller.dispose();
      return;
    }

    mapController = controller;

    // Set map style for better performance
    mapController?.setMapStyle('''
    [
      {
        "featureType": "poi",
        "stylers": [{"visibility": "off"}]
      },
      {
        "featureType": "transit",
        "stylers": [{"visibility": "off"}]
      }
    ]
    ''');
  }

  // Responsive helper methods
  bool _isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  bool _isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
          MediaQuery.of(context).size.width < tabletBreakpoint;

  double _getResponsivePadding(BuildContext context) {
    if (_isMobile(context)) return 16.0;
    if (_isTablet(context)) return 24.0;
    return 32.0;
  }

  double _getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return baseSize * 0.9;
    if (screenWidth > 600) return baseSize * 1.1;
    return baseSize;
  }

  // Sensor status methods
  SensorStatus _getTemperatureStatus(double temperature) {
    if (temperature >= 35) return SensorStatus.bad;
    if (temperature >= 30) return SensorStatus.warning;
    return SensorStatus.good;
  }

  SensorStatus _getHumidityStatus(double humidity) {
    if (humidity < 30 || humidity > 80) return SensorStatus.bad;
    if (humidity < 40 || humidity > 70) return SensorStatus.warning;
    return SensorStatus.good;
  }

  SensorStatus _getSoilPHStatus(double ph) {
    if (ph < 5.5 || ph > 7.5) return SensorStatus.bad;
    if (ph < 6.0 || ph > 7.0) return SensorStatus.warning;
    return SensorStatus.good;
  }

  SensorStatus _getLightIntensityStatus(double intensity) {
    // Adjusted thresholds for the new scale (API returns values around 12668)
    if (intensity < 5000) return SensorStatus.bad;
    if (intensity < 10000) return SensorStatus.warning;
    return SensorStatus.good;
  }

  // Description methods
  String _getTemperatureDescription(double temperature) {
    if (temperature >= 35) return 'Very high temperature';
    if (temperature >= 30) return 'High temperature';
    if (temperature >= 25) return 'Optimal temperature';
    if (temperature >= 20) return 'Cool temperature';
    return 'Low temperature';
  }

  String _getHumidityDescription(double humidity) {
    if (humidity > 80) return 'Very high humidity';
    if (humidity > 70) return 'High humidity';
    if (humidity >= 40) return 'Optimal humidity';
    if (humidity >= 30) return 'Low humidity';
    return 'Very low humidity';
  }

  String _getSoilPHDescription(double ph) {
    if (ph > 7.5) return 'Alkaline soil';
    if (ph > 7.0) return 'Slightly alkaline';
    if (ph >= 6.0) return 'Optimal pH';
    if (ph >= 5.5) return 'Slightly acidic';
    return 'Very acidic soil';
  }

  String _getLightIntensityDescription(double intensity) {
    // Updated for the new scale
    if (intensity >= 15000) return 'Excellent light';
    if (intensity >= 10000) return 'Good light';
    if (intensity >= 5000) return 'Moderate light';
    return 'Low light';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final padding = _getResponsivePadding(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: SharedAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: RefreshIndicator(
            onRefresh: _fetchDashboardData,
            color: const Color(0xFF307D32),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: padding,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeHeader(context),
                  SizedBox(height: _isMobile(context) ? 20 : 24),
                  _buildMainDashboard(context),
                  SizedBox(height: _isMobile(context) ? 20 : 24),
                  // _buildMapSection(context),
                  // SizedBox(height: _isMobile(context) ? 20 : 24),
                  // _buildPlantHealthChart(context),
                  // const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(_isMobile(context) ? 16 : 20),
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
                    fontSize: _getResponsiveFontSize(context, 20),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                // Text(
                //   'Monitor your crops with smart technology',
                //   style: GoogleFonts.inter(
                //     fontWeight: FontWeight.w400,
                //     fontSize: _getResponsiveFontSize(context, 14),
                //     color: Colors.white.withOpacity(0.9),
                //   ),
                // ),
                if (_dashboardData != null)
                  Text(
                    'Last updated: ${_dashboardData!.timestamp.toString().substring(11, 19)}',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w300,
                      fontSize: _getResponsiveFontSize(context, 12),
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(_isMobile(context) ? 10 : 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.agriculture,
              size: _isMobile(context) ? 28 : 32,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainDashboard(BuildContext context) {
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
        padding: EdgeInsets.all(_isMobile(context) ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Sensor Monitoring',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: _getResponsiveFontSize(context, 18),
                      color: Colors.black87,
                    ),
                  ),
                ),
                Row(
                  children: [
                    if (_isLoadingData)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFF307D32),
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: _isMobile(context) ? 8 : 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _dataError != null
                            ? Colors.red.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: _dataError != null ? Colors.red : Colors.green,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _dataError != null ? 'Offline' : 'Live Data',
                            style: GoogleFonts.inter(
                              fontSize: _getResponsiveFontSize(context, 12),
                              fontWeight: FontWeight.w600,
                              color: _dataError != null ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: _isMobile(context) ? 16 : 20),
            _isLoadingData && _dashboardData == null
                ? _buildLoadingSkeleton(context)
                : _buildEnhancedSensorGrid(context),
            SizedBox(height: _isMobile(context) ? 16 : 20),
            _buildRecommendationSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildSkeletonTile(context)),
            SizedBox(width: _isMobile(context) ? 8 : 12),
            Expanded(child: _buildSkeletonTile(context)),
          ],
        ),
        SizedBox(height: _isMobile(context) ? 8 : 12),
        Row(
          children: [
            Expanded(child: _buildSkeletonTile(context)),
            SizedBox(width: _isMobile(context) ? 8 : 12),
            Expanded(child: _buildSkeletonTile(context)),
          ],
        ),
      ],
    );
  }

  Widget _buildSkeletonTile(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(_isMobile(context) ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 60,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 80,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSensorGrid(BuildContext context) {
    if (_dashboardData == null) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Unable to load sensor data',
              style: GoogleFonts.inter(
                fontSize: _getResponsiveFontSize(context, 16),
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _fetchDashboardData,
              child: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF307D32),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    // Use API light intensity instead of generated value
    final lightIntensity = _dashboardData!.lightIntensity;
    final spacing = _isMobile(context) ? 8.0 : 12.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildModernSensorTile(
                context: context,
                icon: Icons.thermostat_outlined,
                title: 'Temperature',
                value: '${_dashboardData!.temperature.toStringAsFixed(1)}°C',
                description: _getTemperatureDescription(_dashboardData!.temperature),
                status: _getTemperatureStatus(_dashboardData!.temperature),
                gradient: _getTemperatureStatus(_dashboardData!.temperature) == SensorStatus.good
                    ? [Colors.green.shade400, Colors.green.shade600]
                    : _getTemperatureStatus(_dashboardData!.temperature) == SensorStatus.warning
                    ? [Colors.amber.shade400, Colors.amber.shade600]
                    : [Colors.red.shade400, Colors.red.shade600],
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: _buildModernSensorTile(
                context: context,
                icon: Icons.water_drop_outlined,
                title: 'Humidity',
                value: '${_dashboardData!.humidity.toStringAsFixed(1)}%',
                description: _getHumidityDescription(_dashboardData!.humidity),
                status: _getHumidityStatus(_dashboardData!.humidity),
                gradient: _getHumidityStatus(_dashboardData!.humidity) == SensorStatus.good
                    ? [Colors.blue.shade400, Colors.blue.shade600]
                    : _getHumidityStatus(_dashboardData!.humidity) == SensorStatus.warning
                    ? [Colors.orange.shade400, Colors.orange.shade600]
                    : [Colors.red.shade400, Colors.red.shade600],
              ),
            ),
          ],
        ),
        SizedBox(height: spacing),
        Row(
          children: [
            Expanded(
              child: _buildModernSensorTile(
                context: context,
                icon: Icons.science_outlined,
                title: 'Soil pH',
                value: _dashboardData!.soilPH.toStringAsFixed(1),
                description: _getSoilPHDescription(_dashboardData!.soilPH),
                status: _getSoilPHStatus(_dashboardData!.soilPH),
                gradient: _getSoilPHStatus(_dashboardData!.soilPH) == SensorStatus.good
                    ? [Colors.green.shade400, Colors.green.shade600]
                    : _getSoilPHStatus(_dashboardData!.soilPH) == SensorStatus.warning
                    ? [Colors.amber.shade400, Colors.amber.shade600]
                    : [Colors.red.shade400, Colors.red.shade600],
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: _buildModernSensorTile(
                context: context,
                icon: Icons.wb_sunny_outlined,
                title: 'Light Intensity',
                value: '${(lightIntensity / 1000).toStringAsFixed(1)}k lux',
                description: _getLightIntensityDescription(lightIntensity),
                status: _getLightIntensityStatus(lightIntensity),
                gradient: _getLightIntensityStatus(lightIntensity) == SensorStatus.good
                    ? [Colors.yellow.shade400, Colors.yellow.shade600]
                    : _getLightIntensityStatus(lightIntensity) == SensorStatus.warning
                    ? [Colors.orange.shade400, Colors.orange.shade600]
                    : [Colors.grey.shade400, Colors.grey.shade600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernSensorTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required String description,
    required SensorStatus status,
    required List<Color> gradient,
  }) {
    return Container(
      padding: EdgeInsets.all(_isMobile(context) ? 12 : 16),
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
              Icon(
                icon,
                color: Colors.white,
                size: _isMobile(context) ? 20 : 24,
              ),
              Icon(
                _getStatusIcon(status),
                color: Colors.white,
                size: _isMobile(context) ? 14 : 16,
              ),
            ],
          ),
          SizedBox(height: _isMobile(context) ? 8 : 12),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: _getResponsiveFontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: _getResponsiveFontSize(context, 11),
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          if (!_isMobile(context))
            Text(
              description,
              style: GoogleFonts.inter(
                fontSize: _getResponsiveFontSize(context, 9),
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

  Widget _buildMapSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Farm Location',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: _getResponsiveFontSize(context, 18),
                  color: Colors.black87,
                ),
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
        SizedBox(height: _isMobile(context) ? 8 : 12),
        Container(
          height: _isMobile(context) ? 180 : 220,
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
            child: _buildMapContent(context),
          ),
        ),
      ],
    );
  }

  Widget _buildMapContent(BuildContext context) {
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
                  fontSize: _getResponsiveFontSize(context, 14),
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
          child: Padding(
            padding: EdgeInsets.all(_isMobile(context) ? 16 : 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_outlined, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Map Unavailable',
                  style: GoogleFonts.montserrat(
                    fontSize: _getResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Using offline map view',
                  style: GoogleFonts.inter(
                    fontSize: _getResponsiveFontSize(context, 12),
                    color: Colors.red[600],
                  ),
                  textAlign: TextAlign.center,
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
        ),
      );
    }

    // Optimized GoogleMap widget
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
        // Performance optimizations
        buildingsEnabled: false,
        trafficEnabled: false,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        compassEnabled: false,
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
        // Reduce texture memory usage
        liteModeEnabled: _isMobile(context),
      );
    } catch (e) {
      return Container(
        color: Colors.green[50],
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(_isMobile(context) ? 16 : 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, color: Colors.green, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Farm Location',
                  style: GoogleFonts.montserrat(
                    fontSize: _getResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  'Jakarta, Indonesia',
                  style: GoogleFonts.inter(
                    fontSize: _getResponsiveFontSize(context, 12),
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildPlantHealthChart(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(_isMobile(context) ? 16 : 20),
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
              fontSize: _getResponsiveFontSize(context, 18),
              color: Colors.black87,
            ),
          ),
          SizedBox(height: _isMobile(context) ? 16 : 20),
          _isMobile(context)
              ? _buildMobileChart(context)
              : _buildDesktopChart(context),
        ],
      ),
    );
  }

  Widget _buildMobileChart(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
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
              centerSpaceRadius: 30,
              sections: showingSections(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            _buildModernLegendItem(
              context: context,
              color: const Color(0xFF4CAF50),
              label: 'Healthy',
              percentage: '55%',
            ),
            const SizedBox(height: 8),
            _buildModernLegendItem(
              context: context,
              color: Colors.orange,
              label: 'Warning',
              percentage: '20%',
            ),
            const SizedBox(height: 8),
            _buildModernLegendItem(
              context: context,
              color: Colors.red,
              label: 'Critical',
              percentage: '25%',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopChart(BuildContext context) {
    return Row(
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
                context: context,
                color: const Color(0xFF4CAF50),
                label: 'Healthy',
                percentage: '55%',
              ),
              const SizedBox(height: 12),
              _buildModernLegendItem(
                context: context,
                color: Colors.orange,
                label: 'Warning',
                percentage: '20%',
              ),
              const SizedBox(height: 12),
              _buildModernLegendItem(
                context: context,
                color: Colors.red,
                label: 'Critical',
                percentage: '25%',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernLegendItem({
    required BuildContext context,
    required Color color,
    required String label,
    required String percentage,
  }) {
    return Row(
      children: [
        Container(
          width: _isMobile(context) ? 10 : 12,
          height: _isMobile(context) ? 10 : 12,
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
              fontSize: _getResponsiveFontSize(context, 14),
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          percentage,
          style: GoogleFonts.montserrat(
            fontSize: _getResponsiveFontSize(context, 14),
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationSection(BuildContext context) {
    if (_dashboardData == null) {
      return Container(
        padding: EdgeInsets.all(_isMobile(context) ? 12 : 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey.shade400, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Load sensor data to get recommendations',
                style: GoogleFonts.inter(
                  fontSize: _getResponsiveFontSize(context, 14),
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Use API diagnosis and recommendation
    final diagnosis = _dashboardData!.diagnosis;
    final recommendation = _dashboardData!.recommendation;
    final plantStatus = _dashboardData!.plantStatus;

    // Determine colors based on plant status
    Color containerColor = Colors.green.shade50;
    Color borderColor = Colors.green.shade200;
    Color textColor = Colors.green.shade800;
    String title = 'Plant Status : $plantStatus';
    IconData iconData = Icons.check_circle;

    if (plantStatus.toLowerCase().contains('optimal') ||
        plantStatus.toLowerCase().contains('baik')) {
      // Keep green colors for optimal status
    } else if (plantStatus.toLowerCase().contains('warning') ||
        plantStatus.toLowerCase().contains('hati')) {
      containerColor = Colors.orange.shade50;
      borderColor = Colors.orange.shade200;
      textColor = Colors.orange.shade800;
      iconData = Icons.warning;
    } else if (plantStatus.toLowerCase().contains('critical') ||
        plantStatus.toLowerCase().contains('buruk')) {
      containerColor = Colors.red.shade50;
      borderColor = Colors.red.shade200;
      textColor = Colors.red.shade800;
      title = 'Urgent Action Required';
      iconData = Icons.error;
    }

    return Container(
      padding: EdgeInsets.all(_isMobile(context) ? 12 : 16),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: textColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: _getResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Diagnosis section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.analytics, color: textColor, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Diagnosis:',
                      style: GoogleFonts.montserrat(
                        fontSize: _getResponsiveFontSize(context, 14),
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      diagnosis,
                      style: GoogleFonts.inter(
                        fontSize: _getResponsiveFontSize(context, 13),
                        color: textColor,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Recommendation section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(iconData, color: textColor, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recommendation:',
                      style: GoogleFonts.montserrat(
                        fontSize: _getResponsiveFontSize(context, 14),
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recommendation,
                      style: GoogleFonts.inter(
                        fontSize: _getResponsiveFontSize(context, 13),
                        color: textColor,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Timestamp
          Text(
            'Data from: ${_dashboardData!.summaryDate.toString().substring(0, 16)}',
            style: GoogleFonts.inter(
              fontSize: _getResponsiveFontSize(context, 11),
              color: textColor.withOpacity(0.7),
              fontStyle: FontStyle.italic,
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