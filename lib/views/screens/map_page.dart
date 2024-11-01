import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _showHistoryPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryPage()),
    );
  }

  void _showDrivingPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DrivingPage()),
    );
  }

  void _showLocationPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[400], // ใช้สีหลักของแอป
        elevation: 0, // ลบเงาของ AppBar
        title: const Text(
          'Map Page',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context); // ปิดหน้า MapPage
          },
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(13.7563, 100.5018),
              zoom: 15.0,
            ),
            markers: {
              const Marker(
                markerId: MarkerId('currentLocation'),
                position: LatLng(13.7563, 100.5018),
                infoWindow: InfoWindow(title: 'ตำแหน่งของคุณ'),
              ),
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    onPressed: _showHistoryPage,
                    backgroundColor: Colors.grey[400], // ใช้สีหลักของแอป
                    child: const Icon(Icons.history),
                  ),
                  FloatingActionButton(
                    onPressed: _showDrivingPage,
                    backgroundColor: Colors.grey[400], // ใช้สีหลักของแอป
                    child: const Icon(Icons.directions_car),
                  ),
                  FloatingActionButton(
                    onPressed: _showLocationPage,
                    backgroundColor: Colors.grey[400], // ใช้สีหลักของแอป
                    child: const Icon(Icons.my_location),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ตัวอย่างหน้าจอใหม่สำหรับการทดสอบ
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History Page')),
      body: const Center(child: Text('History Page Content')),
    );
  }
}

class DrivingPage extends StatelessWidget {
  const DrivingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driving Page')),
      body: const Center(child: Text('Driving Page Content')),
    );
  }
}

class LocationPage extends StatelessWidget {
  const LocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location Page')),
      body: const Center(child: Text('Location Page Content')),
    );
  }
}
