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
  final Set<Marker> _markers = {};
  bool _isLoading = false;
  Village? _selectedVillage;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _loadKabupatenBogor() {
    setState(() {
      _polygons.clear();
      _markers.clear();

      // Koordinat batas Kabupaten Bogor yang beneran
      final List<LatLng> bogorBoundary = [
        // Batas utara
        LatLng(-6.3500, 106.6500),
        LatLng(-6.3200, 106.7500),
        LatLng(-6.3000, 106.8500),
        LatLng(-6.2800, 106.9500),
        LatLng(-6.3000, 107.0500),
        LatLng(-6.3500, 107.1000),

        // Batas timur
        LatLng(-6.4000, 107.1200),
        LatLng(-6.5000, 107.1500),
        LatLng(-6.6000, 107.1200),
        LatLng(-6.7000, 107.0800),
        LatLng(-6.7500, 107.0000),

        // Batas selatan
        LatLng(-6.8000, 106.9500),
        LatLng(-6.8200, 106.8500),
        LatLng(-6.8000, 106.7500),
        LatLng(-6.7800, 106.6500),
        LatLng(-6.7500, 106.5500),

        // Batas barat
        LatLng(-6.7000, 106.4800),
        LatLng(-6.6000, 106.4500),
        LatLng(-6.5000, 106.4800),
        LatLng(-6.4000, 106.5500),
        LatLng(-6.3800, 106.6000),
      ];

      _polygons.add(Polygon(
        polygonId: const PolygonId('kabupaten_bogor'),
        points: bogorBoundary,
        strokeWidth: 2,
        strokeColor: Colors.red,
        fillColor: Colors.red.withOpacity(0.3),
      ));

      // 1 marker di pusat
      _markers.add(Marker(
        markerId: const MarkerId('bogor_center'),
        position: const LatLng(-6.5972, 106.7833),
        infoWindow: const InfoWindow(title: 'Kabupaten Bogor'),
      ));
    });
  }

  void _showPestGuardInfo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPestGuardSheet(),
    );
  }

  Widget _buildPestGuardSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.bug_report, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'PestGuard - Pest Information',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Table
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Table(
                border: TableBorder.all(color: Colors.grey.shade300),
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(3),
                },
                children: [
                  // Header row
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey.shade100),
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('Pest Name', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('Symptoms', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('Management Strategies', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),

                  // Brown Planthopper
                  const TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('Brown Planthopper\n(Nilaparvata lugens)', style: TextStyle(fontSize: 12)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('Plants turn yellow, dry out, and die (stunted hopperburn).', style: TextStyle(fontSize: 12)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('• Use resistant rice varieties\n• Plant synchronously with neighbors\n• Use light traps to capture the hoppers in rice sequences of Ratoon/main/tootat.', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),

                  // Armyworm
                  const TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('Armyworm\n(Spodoptera spp.)', style: TextStyle(fontSize: 12)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('Leaves are chewed or eaten at night.', style: TextStyle(fontSize: 12)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('• Spray organic or insecticide chemical treatment\n• Use light traps to capture adult moths', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),

                  // White Grub
                  const TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('White Grub\n(Uret) (Lepidiota stigma)', style: TextStyle(fontSize: 12)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('Root damage causes plant wilting and death.', style: TextStyle(fontSize: 12)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('• Apply entomopathogenic nematodes (Steinernema spp.)\n• Use Metarhizium fungi\n• Granular insecticides as baits/feeding preparation.', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),

                  // Leaf Miner
                  const TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('Leaf Miner\n(Liriomyza spp.)', style: TextStyle(fontSize: 12)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('Tunnels or mines in leaves, reduced photosynthesis.', style: TextStyle(fontSize: 12)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('• Remove and destroy infected leaves\n• Maintain greenhouse hygiene\n• Use beneficial insects\n• Remove and destroy infected plants', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showVillagePolygon(Village village) {
    setState(() {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SharedAppBar(),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              mapController = controller;
              _loadKabupatenBogor();
            },
            initialCameraPosition: const CameraPosition(
              target: LatLng(-6.6000, 106.8000),
              zoom: 11,
            ),
            polygons: _polygons,
            markers: _markers,
            myLocationEnabled: true,
          ),

          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
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
                  const SizedBox(width: 16),
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      onSubmitted: (value) {
                        _searchVillage(value.trim());
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.search, color: Colors.white, size: 20),
                      onPressed: () {
                        _searchVillage(_searchController.text.trim());
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _showPestGuardInfo(),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.bug_report, color: Colors.white, size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("PestGuard", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              Text("Identification of Potential Pests and Mitigation Strategies", style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                        Text("More Information", style: TextStyle(color: Colors.white, fontSize: 12)),
                        Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.analytics, color: Colors.white, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Prediction", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            Text("Land fertility prediction", style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                      Text("More Information", style: TextStyle(color: Colors.white, fontSize: 12)),
                      Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.eco, color: Colors.white, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Sustainable", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            Text("Crop Rotation Recommendations", style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                      Text("More Information", style: TextStyle(color: Colors.white, fontSize: 12)),
                      Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (_isLoading)
            const Center(child: CircularProgressIndicator()),

          if (_selectedVillage != null)
            Positioned(
              top: 80,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(_selectedVillage!.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _selectedVillage = null;
                                _loadKabupatenBogor();
                              });
                            },
                          ),
                        ],
                      ),
                      Text('Provinsi: ${_selectedVillage!.province}', style: TextStyle(color: Colors.grey[600])),
                      Text('Jumlah Polygon: ${_selectedVillage!.polygons.length}'),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}