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
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controller untuk Google Maps
  GoogleMapController? mapController;

  // Koordinat default untuk peta (misalnya: Jakarta)
  final LatLng _center = const LatLng(-6.2088, 106.8456);
  int touchedIndex = -1;
  bool _isMapLoading = true;
  String? _mapError;

  @override
  void initState() {
    super.initState();
    _initializeGoogleMaps();
  }

  Future<void> _initializeGoogleMaps() async {
    try {
      // Initialize Google Maps service
      await GoogleMapsService.initialize();

      // Validate API key
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
        appBar: SharedAppBar(
          onNotificationPressed: () {
            print('Notifikasi ditekan dari HomeScreen!');
            // Tambahkan aksi khusus untuk notifikasi di halaman ini
          },
          onProfilePressed: () {
            print('Profile ditekan dari HomeScreen!');
            // Tambahkan aksi khusus untuk profile di halaman ini
          },
        ),
        body:
        SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text(
                  'Dashboard Monitoring',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  )
              ),
              Text(
                  'Start your smarter farming journey with technology!',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Colors.grey[600]
                  )
              ),
              SizedBox(height: 5),
              Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(16.0),
                    color: Colors.white,
                  ),
                  child: Padding(
                      padding: EdgeInsets.all(20),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Check if we have enough width for row layout
                          bool useRowLayout = constraints.maxWidth > 600;

                          if (useRowLayout) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Kolom kiri - Sensor Data
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      _buildSensorTile(
                                        icon: Icons.thermostat_outlined,
                                        title: 'Temperature',
                                        value: '34°C',
                                        description: 'High - risk of heat stress',
                                        status: SensorStatus.bad,
                                      ),
                                      SizedBox(height: 16),
                                      _buildSensorTile(
                                        icon: Icons.water_drop_outlined,
                                        title: 'Soil Moisture',
                                        value: '20%',
                                        description: 'Low - below optimal range of 30-40%',
                                        status: SensorStatus.bad,
                                      ),
                                      SizedBox(height: 16),
                                      _buildSensorTile(
                                        icon: Icons.science_outlined,
                                        title: 'Soil pH',
                                        value: '5.4',
                                        description: 'Slightly acidic - ideal: 6.0-6.8',
                                        status: SensorStatus.bad,
                                      ),
                                      SizedBox(height: 16),
                                      _buildSensorTile(
                                        icon: Icons.wb_sunny_outlined,
                                        title: 'Light Intensity',
                                        value: '78%',
                                        description: 'Optimal for photosynthesis',
                                        status: SensorStatus.good,
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(width: 16),

                                // Kolom kanan - Plant Status & Recommendations
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildPlantStatusSection(),
                                      SizedBox(height: 20),
                                      _buildRecommendationSection(),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          } else {
                            // Stack vertically for smaller screens
                            return Column(
                              children: [
                                _buildPlantStatusSection(),
                                SizedBox(height: 20),
                                // Sensor Data
                                _buildSensorTile(
                                  icon: Icons.thermostat_outlined,
                                  title: 'Temperature',
                                  value: '34°C',
                                  description: 'High - risk of heat stress',
                                  status: SensorStatus.bad,
                                ),
                                SizedBox(height: 16),
                                _buildSensorTile(
                                  icon: Icons.water_drop_outlined,
                                  title: 'Soil Moisture',
                                  value: '20%',
                                  description: 'Low - below optimal range of 30-40%',
                                  status: SensorStatus.bad,
                                ),
                                SizedBox(height: 16),
                                _buildSensorTile(
                                  icon: Icons.science_outlined,
                                  title: 'Soil pH',
                                  value: '5.4',
                                  description: 'Slightly acidic - ideal: 6.0-6.8',
                                  status: SensorStatus.bad,
                                ),
                                SizedBox(height: 16),
                                _buildSensorTile(
                                  icon: Icons.wb_sunny_outlined,
                                  title: 'Light Intensity',
                                  value: '78%',
                                  description: 'Optimal for photosynthesis',
                                  status: SensorStatus.good,
                                ),
                                SizedBox(height: 24),
                                // Plant Status & Recommendations
                                _buildRecommendationSection(),
                              ],
                            );
                          }
                        },
                      )
                  )
              ),
              SizedBox(height: 20),
              Text(
                  'The area around you!',
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 14
                  )
              ),
              _buildMapSection(),
              SizedBox(height: 30),
              Text(
                  'Plant Health',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  )
              ),
              Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 30),
                          Expanded(  // Gunakan Expanded untuk fleksibilitas
                            child: SizedBox(
                              height: 200,
                              width: 200,
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
                                        touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                      });
                                    },
                                  ),
                                  borderData: FlBorderData(show: false),
                                  sectionsSpace: 0,
                                  centerSpaceRadius: 0,
                                  sections: showingSections(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 40),
                          Expanded(  // Gunakan Expanded untuk legenda
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _legendItem(Colors.green[800]!, 'Healthy'),
                                SizedBox(height: 10),
                                _legendItem(Colors.orange, 'Unhealthy'),
                                SizedBox(height: 10),
                                _legendItem(Colors.red, 'Critical'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        )
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 200, // Tinggi peta
      width: double.infinity, // Lebar penuh
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildMapContent(),
      ),
    );
  }

  Widget _buildMapContent() {
    if (_isMapLoading) {
      return Container(
        color: Colors.grey[200],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.green),
              SizedBox(height: 16),
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
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              SizedBox(height: 16),
              Text(
                'Map Error',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Failed to load Google Maps. Please check your API key configuration.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.red[700],
                  ),
                ),
              ),
              SizedBox(height: 16),
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
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GoogleMap(
      onMapCreated: (controller) {
        _onMapCreated(controller);
        mapController = controller;
        print('Google Maps loaded successfully with API key from constants');
      },
      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: AppConstants.defaultMapZoom,
      ),
      markers: {
        Marker(
          markerId: MarkerId('farm_location'),
          position: _center,
          infoWindow: InfoWindow(
            title: 'Your Farm',
            snippet: 'Smart Farming Location',
          ),
        ),
      },
    );
  }

  Widget _buildSensorTile({
    required IconData icon,
    required String title,
    required String value,
    required String description,
    required SensorStatus status,
  }) {
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case SensorStatus.good:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case SensorStatus.warning:
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        break;
      case SensorStatus.bad:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 24, color: Colors.grey[600]),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Icon(statusIcon, color: statusColor, size: 24),
      ],
    );
  }

  Widget _buildPlantStatusSection() {
    return Row(
      children: [
        Container(
          child: SvgPicture.asset(
              'assets/images/wheat.svg',
              width: 40,
              color: Colors.grey[600]),
        ),
        SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plant Status',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        )),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sentiment_dissatisfied, size: 24, color: Colors.red),
            SizedBox(width: 4),
            Text(
              'Bad',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecommendationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lightbulb_outline, size: 20, color: Colors.grey[600]),
            SizedBox(width: 8),
            Text(
              'Diagnose & Recommendation',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Text(
          'Your plant is experiencing water stress due to low soil moisture and high ambient temperature. The soil is also slightly acidic, which may hinder nutrient absorption.',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Recommendation action:',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        ..._buildRecommendationList(),
      ],
    );
  }

  List<Widget> _buildRecommendationList() {
    final recommendations = [
      'Irrigate the soil to increase soil moisture to at least 30%.',
      'Consider mulching to reduce evaporation due to high temperatures.',
      'Apply lime or soil amendment to balance the pH to neutral.',
      'Monitor again in 6 hours.',
    ];

    return recommendations.asMap().entries.map((entry) {
      int index = entry.key + 1;
      String recommendation = entry.value;

      return Padding(
        padding: EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$index. ',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            Expanded(
              child: Text(
                recommendation,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[700],
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(3, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 90.0 : 80.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.green[800]!,
            value: 55,
            title: '55%',
            radius: radius,
            titleStyle: TextStyle(
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
            titleStyle: TextStyle(
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
            titleStyle: TextStyle(
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

  Widget _legendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black12),
            ),
          ),
          const SizedBox(width: 8),
          Text(
              label,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              )
          ),
        ],
      ),
    );
  }
}