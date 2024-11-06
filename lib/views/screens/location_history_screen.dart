import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/models/user_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'map_page.dart';

class LocationHistoryScreen extends StatefulWidget {
  final String employeeId;

  const LocationHistoryScreen({super.key, required this.employeeId});

  @override
  State<LocationHistoryScreen> createState() => _LocationHistoryScreenState();
}

class _LocationHistoryScreenState extends State<LocationHistoryScreen> {
  List locationHistory = [];
  UserModel userModel = UserModel();
  List<Marker> markerEmployees = [];

  @override
  void initState() {
    super.initState();
    getEmployeeLocationHistory();
  }

void getEmployeeLocationHistory() async {
  List locations = await userModel.getLocationHistoryByUserId(widget.employeeId);

  setState(() {
    markerEmployees = locations.map((location) {
      return Marker(
        markerId: MarkerId(location['id']),
        position: LatLng(location['latitude'], location['longitude']),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed), // ตั้งค่าให้หมุดเป็นสีแดง
        infoWindow: InfoWindow(
          title: location['status'],
          snippet: timeStampToString(location['createdAt']),
        ),
      );
    }).toList();

    locationHistory = locations;
  });
}


  String timeStampToString(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd MMMM yyyy - HH:mm').format(dateTime);
  }

  void navigateToEmployeeLocation(double latitude, double longitude) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPage(
          employeeData: [
            {
              'id': widget.employeeId,
              'displayName': 'ชื่อพนักงาน',
              'status': 'สถานะ',
              'latitude': latitude,
              'longitude': longitude,
              'imageUrl': 'https://example.com/image.png',
            },
          ],
          employeeId: '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ประวัติตำแหน่ง',
          style: TextStyle(color: isDarkMode ? Colors.black : Colors.white),
        ),
        iconTheme: IconThemeData(color: isDarkMode ? Colors.black : Colors.white),
        backgroundColor: isDarkMode ? Colors.white : const Color.fromARGB(255, 71, 124, 168),
      ),
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  zoomControlsEnabled: true,
                  initialCameraPosition: locationHistory.isNotEmpty
                      ? CameraPosition(
                          target: LatLng(locationHistory[0]['latitude'], locationHistory[0]['longitude']),
                          zoom: 12,
                        )
                      : const CameraPosition(
                          target: LatLng(13.736717, 100.523186),
                          zoom: 12,
                        ),
                  markers: markerEmployees.toSet(), // แปลงเป็น Set<Marker> ด้วย toSet()
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: locationHistory.isEmpty
                  ? Center(
                      child: Text(
                        'ไม่มีข้อมูลประวัติการตำแหน่ง',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: locationHistory.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            color: isDarkMode ? Colors.grey[850] : Colors.white,
                            child: ListTile(
                              title: Text(
                                locationHistory[index]['status'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              subtitle: Text(
                                timeStampToString(locationHistory[index]['createdAt']),
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white70 : Colors.black54,
                                ),
                              ),
                              onTap: () {
                                double latitude = locationHistory[index]['latitude'];
                                double longitude = locationHistory[index]['longitude'];
                                navigateToEmployeeLocation(latitude, longitude);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
