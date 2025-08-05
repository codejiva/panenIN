import 'package:PanenIn/shared/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:PanenIn/features/maps/providers/village_model.dart';
import 'package:PanenIn/features/maps/providers/api_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final Set<Polygon> _polygons = {};
  bool _isLoading = false;
  Village? _selectedVillage;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _searchVillage(String villageName) async {
    if (villageName.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.fetchVillageData(villageName);
      _showVillagePolygon(response);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      debugPrint('Error fetching village data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showVillagePolygon(Village village) {
    setState(() {
      _polygons.clear();
      _selectedVillage = village;

      for (int i = 0; i < village.polygons.length; i++) {
        _polygons.add(
          Polygon(
            polygonId: PolygonId('${village.name}_$i'),
            points: village.polygons[i],
            strokeWidth: 2,
            strokeColor: Colors.blue,
            fillColor: Colors.blue.withOpacity(0.15),
          ),
        );
      }
    });

    _zoomToPolygon(village.polygons);
  }

  void _zoomToPolygon(List<List<LatLng>> polygons) {
    if (polygons.isEmpty) return;
    final bounds = _boundsFromLatLngList(polygons.expand((p) => p).toList());
    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    if (list.isEmpty) {
      return LatLngBounds(
        northeast: const LatLng(0, 0),
        southwest: const LatLng(0, 0),
      );
    }

    double x0 = list.first.latitude, x1 = list.first.latitude;
    double y0 = list.first.longitude, y1 = list.first.longitude;

    for (final latLng in list) {
      if (latLng.latitude > x1) x1 = latLng.latitude;
      if (latLng.latitude < x0) x0 = latLng.latitude;
      if (latLng.longitude > y1) y1 = latLng.longitude;
      if (latLng.longitude < y0) y0 = latLng.longitude;
    }

    return LatLngBounds(
      northeast: LatLng(x1, y1),
      southwest: LatLng(x0, y0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SharedAppBar(
        onNotificationPressed: () {
          print('Notifikasi ditekan dari HomeScreen!');
        },
        onProfilePressed: () {
          print('Profile ditekan dari HomeScreen!');
        },
      ),
      body:Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => mapController = controller,
            initialCameraPosition: const CameraPosition(
              target: LatLng(-6.1754, 106.8272),
              zoom: 10,
            ),
            polygons: _polygons,
            myLocationEnabled: true,
          ),
          // Search box positioned at the top
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: _buildSearchBox(),
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search...',
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                fillColor: Colors.transparent,
                filled: false,
              ),
              onSubmitted: (value) {
                _searchVillage(value.trim());
              },
            ),
          ),
          Container(
            width: 78,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                _searchVillage(_searchController.text.trim());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVillageInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedVillage!.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Provinsi: ${_selectedVillage!.province}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Jumlah Polygon: ${_selectedVillage!.polygons.length}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}