import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/models/user_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class LocationHistoryScreen extends StatefulWidget {
  final String employeeId;

  const LocationHistoryScreen({super.key, required this.employeeId}); // เปลี่ยนให้เป็น const

  @override
  State<LocationHistoryScreen> createState() => _LocationHistoryScreenState();
}

class _LocationHistoryScreenState extends State<LocationHistoryScreen> {
  List locationHistory = [];
  UserModel userModel = UserModel();
  List<Marker> markerEmployees = <Marker>[];

  @override
  void initState() {
    super.initState();
    getEmployeeLocationHistory();
  }

  void getEmployeeLocationHistory() async {
    List locations = await userModel.getLocationHistoryByUserId(widget.employeeId);

    for (var location in locations) {
      markerEmployees.add(
        Marker(
          markerId: MarkerId(location['id']),
          position: LatLng(location['latitude'], location['longitude']),
          infoWindow: InfoWindow(
            title: location['status'],
            snippet: timeStampToString(location['createdAt']),
          ),
        ),
      );
    }

    setState(() {
      locationHistory = locations;
    });
  }

  String timeStampToString(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd MMMM yyyy - HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark; // ตรวจสอบว่าโหมดมืดหรือไม่

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Location History',
          style: TextStyle(color: isDarkMode ? Colors.black : Colors.white), // เปลี่ยนสีข้อความ
        ),
        iconTheme: IconThemeData(color: isDarkMode ? Colors.black : Colors.white), // เปลี่ยนสีไอคอน
        backgroundColor: isDarkMode ? Colors.white : const Color.fromARGB(255, 71, 124, 168), // เปลี่ยนสีพื้นหลัง
      ),
      body: Container(
        color: Colors.grey[200],
        child: Column(
          children: [
            SizedBox(
              height: 300,
              width: double.infinity,
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
                markers: Set<Marker>.of(markerEmployees),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: locationHistory.isEmpty
                  ? const Center(child: CircularProgressIndicator()) // แสดง loading
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
                            child: ListTile(
                              title: Text(
                                locationHistory[index]['status'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                timeStampToString(locationHistory[index]['createdAt']),
                                style: const TextStyle(color: Colors.grey),
                              ),
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
