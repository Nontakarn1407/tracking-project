import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DrivingPage extends StatefulWidget {
  const DrivingPage({super.key});

  @override
  _DrivingPageState createState() => _DrivingPageState();
}

class _DrivingPageState extends State<DrivingPage> {
  late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.animateCamera(
      CameraUpdate.newLatLng(const LatLng(13.7563, 100.5018)), // พิกัดกรุงเทพ
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color.fromARGB(255, 71, 124, 168);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : primaryColor,
        elevation: 0,
        title: Text(
          'รายงานการขับขี่',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(13.7563, 100.5018), // จุดเริ่มต้น
                zoom: 15.0,
              ),
              polylines: {
                Polyline(
                  polylineId: const PolylineId('route'),
                  points: [
                    LatLng(13.7563, 100.5018),
                    LatLng(13.7583, 100.5030),
                    LatLng(13.7590, 100.5050),
                  ],
                  color: Colors.blue,
                  width: 5,
                ),
              },
              markers: {
                const Marker(
                  markerId: MarkerId('startLocation'),
                  position: LatLng(13.7563, 100.5018), // จุดเริ่มต้น
                  infoWindow: InfoWindow(title: 'Starting Point'),
                ),
                const Marker(
                  markerId: MarkerId('endLocation'),
                  position: LatLng(13.7590, 100.5050), // จุดปลายทาง
                  infoWindow: InfoWindow(title: 'Destination'),
                ),
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'รายงานการขับขี่',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '10.27 – 11.02',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white70 : Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'ไม่มีข้อมูลรายงานการขับขี่ในช่วงเวลานี้',
                  style: TextStyle(
                    fontSize: 18,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                _buildMetricRow('ระยะทางรวม', '0 km', isDarkMode),
                _buildMetricRow('เวลารวม', '00:00', isDarkMode),
                _buildMetricRow('การใช้โทรศัพท์', '-', isDarkMode),
                _buildMetricRow('เบรกแรง', '-', isDarkMode),
                _buildMetricRow('เร่งแรง', '-', isDarkMode),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
