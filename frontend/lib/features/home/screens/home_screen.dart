import 'package:PanenIn/shared/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

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
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text(
                  'Dashboard Monitoring',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  )
              ),
              Text(
                  'Start your smarter farming journey with technology!',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w300,
                      fontSize: 12
                  )
              ),
              SizedBox(height: 10),
              Container(
                 decoration: BoxDecoration(
                   boxShadow: [
                     BoxShadow(
                       color: Colors.grey,
                       blurRadius: 2,
                       offset: Offset(0, 3), // changes position of shadow
                     ),
                   ],
                   borderRadius: BorderRadius.circular(12.0),
                   color: Colors.white,
                 ),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // kolom kiri
                      Expanded(
                        flex: 1,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildIndicatorTile(
                                icon: Icons.thermostat,
                                title: 'Temperature',
                                value: '34°C',
                                description: 'High – risk of heat stress',
                              ),
                              _buildIndicatorTile(
                                icon: Icons.water_drop_outlined,
                                title: 'Soil Moisture',
                                value: '20%',
                                description: 'Low – below optimal range of 30–40%',
                              ),
                              _buildIndicatorTile(
                                icon: Icons.thermostat,
                                title: 'Soil pH',
                                value: '5.4',
                                description: 'Slightly acidic – ideal: 6.0–6.8',
                              ),
                              _buildIndicatorTile(
                                icon: Icons.thermostat,
                                title: 'Light Intensity',
                                value: '78%',
                                description: 'Optimal for photosynthesis',
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(width: 16), // jarak antar kolom

                      // kolom kiri
                      Expanded(
                        flex: 1,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildIndicatorTile(
                                icon: Icons.thermostat,
                                title: 'Temperature',
                                value: '34°C',
                                description: 'High – risk of heat stress',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )

                )
              ),
              SizedBox(height: 20),
              Container(
                height: 200, // Tinggi peta
                width: double.infinity, // Lebar penuh
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _center,
                      zoom: 14.0,
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
                  ),
                ),
              ),
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
                                _legendItem(Colors.green[200]!, 'Unhealthy'),
                                SizedBox(height: 10),
                                _legendItem(Colors.red[300]!, 'Critical'),
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

  Widget _buildIndicatorTile({
    required IconData icon,
    required String title,
    required String value,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 30),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                Text(value,
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                Text(description,
                    style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w400)),
              ],
            ),
          ),
          Icon(Icons.thumb_down, color: Colors.red, size: 20),
        ],
      ),
    );
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

  List<PieChartSectionData> showingSections() {
    return List.generate(3, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 90.0 : 80.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.green[800]!,
            value: 60,
            title: '60%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.green[200]!,
            value: 30,
            title: '30%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        case 2:
          return PieChartSectionData(
            color: Colors.red[300]!,
            value: 10,
            title: '10%',
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
}