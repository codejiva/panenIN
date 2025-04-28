import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({Key? key}) : super(key: key);

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  // Controller untuk Google Maps
  GoogleMapController? mapController;
  Set<Polygon> _polygons = {};

  bool _isLoading = false;
  String _selectedVillage = "Kohod";

  // Atur kamera ke area Indramayu
  final LatLng _center = LatLng(-6.3230, 108.3300);


  @override
  void initState() {
    super.initState();
    _loadIndramayuPolygon();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _loadIndramayuPolygon() {
    // Koordinat polygon Desa Indramayu (contoh)
    List<LatLng> indramayuCoords = [
      const LatLng(-6.3276, 108.3288),
      const LatLng(-6.3270, 108.3320),
      const LatLng(-6.3250, 108.3340),
      const LatLng(-6.3220, 108.3350),
      const LatLng(-6.3200, 108.3330),
      const LatLng(-6.3190, 108.3300),
      const LatLng(-6.3200, 108.3270),
      const LatLng(-6.3230, 108.3260),
      const LatLng(-6.3260, 108.3270),
    ];

    createPolygon(indramayuCoords, "Desa Indramayu");
  }

  void createPolygon(List<LatLng> points, String name) {
    final Polygon polygon = Polygon(
      polygonId: PolygonId(name),
      points: points,
      fillColor: Colors.green.withOpacity(0.3),
      strokeColor: Colors.green,
      strokeWidth: 3,
      geodesic: true,
    );

    setState(() {
      _polygons.clear();
      _polygons.add(polygon);
      _selectedVillage = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(15.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ]
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(15.0)),
              child: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                title: SvgPicture.asset(
                  'assets/images/nama_app.svg',
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
            ),
          ),
        ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search for a village...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (value) {
                        _searchVillage(value);
                      },
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      // Search using the current text field value
                    },
                  ),
                ),
              ],
            ),
          ),

          // Loading indicator
          if (_isLoading)
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.yellow[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(strokeWidth: 2),
                  SizedBox(width: 10),
                  Text("Loading boundary data..."),
                ],
              ),
            ),

          // Selected village info
          if (_selectedVillage.isNotEmpty)
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.blue[100],
              child: Text("Selected: $_selectedVillage",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

          // Map
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 12.0,
              ),
              polygons: _polygons,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onTap: _onMapTapped,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _clearSelection,
        tooltip: 'Clear Selection',
        child: Icon(Icons.clear),
      ),
    );
  }

  // When a user taps on the map
  void _onMapTapped(LatLng position) async {
    // This would call a reverse geocoding service to identify the village
    _fetchVillageBoundary(position);
  }

  // Search for a village by name
  Future<void> _searchVillage(String villageName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In a real implementation, you would:
      // 1. Use a geocoding API to convert the village name to coordinates
      // 2. Then use those coordinates to fetch the boundary

      // Simulating search delay
      await Future.delayed(Duration(seconds: 1));

      // For demonstration, we'll just use a fixed position
      _fetchVillageBoundary(LatLng(-7.8112, 112.0011));

      setState(() {
        _selectedVillage = villageName;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error searching for village: $e"))
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Clear the current selection
  void _clearSelection() {
    setState(() {
      _polygons.clear();
      _selectedVillage = "";
    });
  }

  // Fetch village boundary for a given coordinate
  Future<void> _fetchVillageBoundary(LatLng position) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In a real implementation, you would make an API call to:
      // 1. A reverse geocoding service to get the village/administrative area name
      // 2. A boundary data service to get the polygon coordinates

      // For demonstration purposes, this shows how you would structure the API call
      // and process the response

      // Example API call (this is a placeholder URL)
      // final response = await http.get(Uri.parse(
      //   'https://boundaries-api.example.com/get-boundary?lat=${position.latitude}&lng=${position.longitude}&level=village'
      // ));

      // if (response.statusCode == 200) {
      //   final data = json.decode(response.body);
      //   _processVillageBoundary(data);
      // }

      // For this demo, we'll just create a simulated polygon
      await Future.delayed(Duration(seconds: 1)); // Simulate API delay
      _createExamplePolygon(position);

      setState(() {
        _selectedVillage = "Desa Example"; // Would come from API
      });

      // Move camera to center on the village
      mapController?.animateCamera(CameraUpdate.newLatLngZoom(position, 14));

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching village boundary: $e"))
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Process the boundary data from an API
  void _processVillageBoundary(Map<String, dynamic> data) {
    // In a real implementation, you would:
    // 1. Extract the village name from the data
    // 2. Extract the boundary coordinates from the data
    // 3. Create a polygon from those coordinates

    // This would be the structure to parse GeoJSON data
    // final List<dynamic> coordinates = data['geometry']['coordinates'][0];
    // List<LatLng> polygonPoints = coordinates.map((coord) =>
    //   LatLng(coord[1], coord[0])).toList();

    // createPolygon(polygonPoints, data['properties']['name']);
  }

  // Create a polygon from a list of points
  // For demo purposes - create a simple polygon around the given position
  void _createExamplePolygon(LatLng center) {
    // Create a simple square polygon around the center point
    const double offset = 0.01; // roughly 1km
    List<LatLng> points = [
      LatLng(center.latitude - offset, center.longitude - offset),
      LatLng(center.latitude - offset, center.longitude + offset),
      LatLng(center.latitude + offset, center.longitude + offset),
      LatLng(center.latitude + offset, center.longitude - offset),
    ];

  }
}