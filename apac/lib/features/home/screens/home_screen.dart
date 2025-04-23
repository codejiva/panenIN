import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


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

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          flexibleSpace: Image.asset(
            'assets/images/backgroundheader.png',
            fit: BoxFit.cover,
          ),
          title: Image.asset(
            'assets/images/nama_app.png',
          ),
          actions: [
            InkWell(
              onTap: () {
                print('Notifikasi ditekan!');
              },
              child: Image.asset(
                'assets/images/notifikasi.png',
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: 10),
            InkWell(
              onTap: () {
                print('Profile ditekan!');
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Image.asset(
                  'assets/images/Profile.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      body:SingleChildScrollView(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Tambahkan ini
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
            Container(
              height: 200, // Tinggi peta
              width: double.infinity, // Lebar penuh
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
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
            )
          ],
        ),
      )
    );
  }

  Widget _buildSensorCard(String title, String value, String status, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              status,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}