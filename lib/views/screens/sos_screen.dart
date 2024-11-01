import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // เพิ่มการนำเข้า Firestore

class SosScreen extends StatefulWidget {
  @override
  _SosScreenState createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  LatLng _currentPosition = LatLng(13.7563, 100.5018); // ตำแหน่งตัวอย่าง (Bangkok)
  TextEditingController _messageController = TextEditingController(); // ตัวควบคุมข้อความ

  // ตัวอย่างรายชื่อผู้ติดต่อฉุกเฉิน
  final List<Map<String, String>> _emergencyContacts = [
    {'name': 'John Doe', 'phone': '123-456-7890'},
    {'name': 'Jane Smith', 'phone': '098-765-4321'},
    {'name': 'Alice Johnson', 'phone': '555-555-5555'},
  ];

  // ฟังก์ชันสำหรับส่ง SOS
  void _sendSOS() async {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      // สร้างข้อมูล SOS สำหรับบันทึกใน Firestore
      SOSModel sos = SOSModel(
        id: '', // รหัสเอกสารจะถูกสร้างโดย Firestore
        userId: 'userId', // เปลี่ยนเป็น userId ที่แท้จริงของผู้ใช้
        location: GeoPoint(_currentPosition.latitude, _currentPosition.longitude),
        timestamp: DateTime.now(),
      );

      // บันทึกข้อมูล SOS ลง Firestore
      try {
        // เพิ่มเอกสารใหม่ในคอลเล็กชัน "sos_messages"
        await FirebaseFirestore.instance.collection('sos_messages').add({
          'latitude': _currentPosition.latitude, // เพิ่ม latitude
          'longitude': _currentPosition.longitude, // เพิ่ม longitude
          'message': message, // เพิ่ม message
          'timestamp': Timestamp.now(), // ใช้ Timestamp ของ Firestore
        });

        print("SOS sent! Message: $message");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('SOS message sent!'))
        );
        _messageController.clear(); // เคลียร์ข้อความหลังส่ง
      } catch (e) {
        print("Error sending SOS: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send SOS'))
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a message before sending'))
      );
    }
  }

  void _callContact(String phoneNumber) async {
    if (await canLaunch("tel:$phoneNumber")) {
      await launch("tel:$phoneNumber");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Calling $phoneNumber'))
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $phoneNumber'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SOS',
          style: TextStyle(color: isDarkMode ? Colors.black : Colors.white), // เปลี่ยนสีข้อความใน AppBar
        ),
        iconTheme: IconThemeData(color: isDarkMode ? Colors.black : Colors.white), // เปลี่ยนสีของไอคอน (ปุ่มกลับ)
        backgroundColor: isDarkMode
            ? Colors.white // สีของ AppBar ในโหมดมืด
            : const Color.fromARGB(255, 71, 124, 168), // สีของ AppBar ในโหมดปกติ
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding รอบๆ
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // จัดแนวให้เต็มกว้าง
          children: [
            // แผนที่
            Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12), // มุมมนของ Container
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12), // มุมมนของ ClipRRect
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition,
                    zoom: 14,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId('current_location'),
                      position: _currentPosition,
                    ),
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            // ช่องให้พิมพ์ข้อความ
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter your message',
                labelStyle: TextStyle(color: isDarkMode ? Colors.grey : Colors.grey), // เปลี่ยนสีของ label
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: isDarkMode ? Colors.blue : const Color.fromARGB(255, 71, 124, 168)), // สีเมื่อฟิลด์ถูกเลือก
                ),
              ),
              maxLines: 2, // จำนวนบรรทัดสูงสุด
            ),
            SizedBox(height: 20),
            // ปุ่มส่ง SOS
            ElevatedButton(
              onPressed: _sendSOS,
              child: Text(
                'Send SOS',
                style: TextStyle(color: isDarkMode ? Colors.black : Colors.white), // เปลี่ยนสีข้อความในปุ่ม
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode
                    ? Colors.white // สีของปุ่มในโหมดมืด
                    : const Color.fromARGB(255, 71, 124, 168), // สีของปุ่มในโหมดปกติ
                padding: EdgeInsets.symmetric(vertical: 16), // ขนาด padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // มุมมนของปุ่ม
                ),
              ),
            ),
            SizedBox(height: 20),
            // รายชื่อผู้ติดต่อฉุกเฉิน
            Text(
              'Emergency Contacts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black, // เปลี่ยนสีข้อความตามโหมด
              ),
            ),
            SizedBox(height: 10), // เพิ่มระยะห่างระหว่างข้อความและ ListView
            Expanded( // ห่อหุ้ม ListView ด้วย Expanded
              child: ListView.builder(
                itemCount: _emergencyContacts.length,
                itemBuilder: (context, index) {
                  var contact = _emergencyContacts[index];
                  return Card( // ใช้ Card เพื่อทำให้ดูน่าสนใจขึ้น
                    margin: EdgeInsets.symmetric(vertical: 8), // Margin ระหว่าง Card
                    color: isDarkMode ? Colors.grey[850] : Colors.white, // สีของ Card ตามโหมด
                    child: ListTile(
                      title: Text(
                        contact['name'] ?? 'Unknown',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black, // ทำให้ชื่อผู้ติดต่อหนาขึ้นและเปลี่ยนสีตามโหมด
                        ),
                      ),
                      subtitle: Text(
                        'Phone: ${contact['phone'] ?? 'N/A'}',
                        style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black), // เปลี่ยนสีของเบอร์โทรตามโหมด
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.call),
                        color: isDarkMode ? Colors.white : const Color.fromARGB(255, 71, 124, 168), // เปลี่ยนสีไอคอนโทรศัพท์
                        onPressed: () {
                          _callContact(contact['phone']!);
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

// เพิ่มคลาส SOSModel สำหรับการจัดการข้อมูล SOS
class SOSModel {
  String id;
  String userId; // ID ของผู้ใช้
  GeoPoint location; // ตำแหน่ง (ใช้ GeoPoint สำหรับ Firebase)
  DateTime timestamp; // เวลาที่เกิดเหตุ

  SOSModel({
    required this.id,
    required this.userId,
    required this.location,
    required this.timestamp,
  });

  // ฟังก์ชันสำหรับแปลงข้อมูลเป็น Map เพื่อบันทึกใน Firebase
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'location': location,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
