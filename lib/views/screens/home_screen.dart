import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_application_4/models/user_model.dart';
import 'package:flutter_application_4/views/screens/menu_page.dart';
import 'package:flutter_application_4/views/screens/sos_screen.dart'; 
import 'package:flutter_application_4/views/widgets/buttomSheet/friends_list_buttom_sheet.dart';
import 'package:flutter_application_4/views/widgets/customIcon/marker_icon.dart';
import 'package:flutter_application_4/views/widgets/dialogs/update_status_dialog.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  LatLng? _center;
  Position? _currentPosition;
  UserModel userModel = UserModel();
  List<Map<String, dynamic>> employees = [];
  List<Marker> markerEmployees = <Marker>[];

  @override
  void initState() {
    super.initState();
    getUserLocation();
    getFriendList();
    setMarker();
  }

  Future<void> getFriendList() async {
    employees = await userModel.getFriendList();
  }

  Future<void> setMarker() async {
    List employeesLocation = await userModel.getOtherEmployeesStatusAndLocation();

    for (var employee in employeesLocation) {
      final File markerImageFile = await DefaultCacheManager().getSingleFile(employee['imageUrl']);
      final Uint8List markerImageBytes = await markerImageFile.readAsBytes();

      final ui.Codec codec = await ui.instantiateImageCodec(
        markerImageBytes,
        targetWidth: 120,
        targetHeight: 120,
      );
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(pictureRecorder);
      final Paint paint = Paint()..isAntiAlias = true;

      final double radius = 60.0;
      canvas.drawCircle(Offset(radius, radius), radius, paint);

      paint.shader = ImageShader(
        image,
        TileMode.clamp,
        TileMode.clamp,
        Matrix4.identity().scaled(120 / image.width, 120 / image.height).storage,
      );
      canvas.drawCircle(Offset(radius, radius), radius, paint);

      final Paint strokePaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10.0
        ..isAntiAlias = true;
      canvas.drawCircle(Offset(radius, radius), radius, strokePaint);

      final ui.Image finalImage = await pictureRecorder.endRecording().toImage(120, 120);
      final ByteData? byteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List resizedMarkerImageBytesWithStroke = byteData!.buffer.asUint8List();

      employee['imageUrl'] = resizedMarkerImageBytesWithStroke;

      markerEmployees.add(Marker(
        markerId: MarkerId(employee['id']),
        position: LatLng(employee['latitude'], employee['longitude']),
        infoWindow: InfoWindow(
          title: employee['displayName'],
          snippet: employee['status'] ?? 'No status', // ใช้ ?? เพื่อตรวจสอบ null
        ),
        icon: BitmapDescriptor.fromBytes(resizedMarkerImageBytesWithStroke),
      ));
    }

    setState(() {
      markerEmployees = markerEmployees;
    });
  }

  Future<void> getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return;
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        return;
      }
    }

    _currentPosition = await Geolocator.getCurrentPosition();

    await userModel.updateMyLocation(userId: userModel.auth.currentUser!.uid, data: {
      'latitude': _currentPosition!.latitude,
      'longitude': _currentPosition!.longitude,
      'lastUpdate': DateTime.now().millisecondsSinceEpoch,
    });

    setState(() {
      _center = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    });
  }

  void moveToMyLocation() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: _center!,
        zoom: 15,
      ),
    ));
  }

  void onClickMenuPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MenuPage()),
    );
  }

  void zoomIn() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.zoomIn());
  }

  void zoomOut() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.zoomOut());
  }

  void onClickSosScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SosScreen()),
    );
  }

  void onClickFriendsList() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return friendsListBottomSheet(context, employees); // Corrected here
        });
  }


  void onClickUpdateStatus() {
    if (_currentPosition != null) {
      updateStatusDialog(context, _currentPosition!, userModel); // ส่งค่า position และ userModel
    }
  }

  void onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  ButtonStyle buttonStyle() {
    return ElevatedButton.styleFrom(
      shape: const CircleBorder(),
      padding: const EdgeInsets.all(15),
      backgroundColor: const Color.fromARGB(255, 71, 124, 168),
      foregroundColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _center == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  markers: markerEmployees.toSet(),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  initialCameraPosition: CameraPosition(
                    target: _center!,
                    zoom: 15,
                  ),
                  onMapCreated: onMapCreated,
                ),
                Positioned(
                  top: 30,
                  left: 10,
                  child: ElevatedButton(
                    style: buttonStyle(),
                    onPressed: onClickMenuPage,
                    child: const Icon(Icons.settings),
                  ),
                ),
                Positioned(
                  top: 90,
                  left: 10,
                  child: ElevatedButton(
                    style: buttonStyle(),
                    onPressed: onClickSosScreen,
                    child: const Icon(Icons.sos),
                  ),
                ),
                Positioned(
                  top: 150,
                  left: 10,
                  child: ElevatedButton(
                    style: buttonStyle(),
                    onPressed: onClickFriendsList,
                    child: const Icon(Icons.group),
                  ),
                ),
                Positioned(
                  top: 210, // ปรับตำแหน่งตามต้องการ
                  left: 10,
                  child: ElevatedButton(
                    style: buttonStyle(),
                    onPressed: onClickUpdateStatus,
                    child: const Icon(Icons.edit), // เปลี่ยนไอคอนตามต้องการ
                  ),
                ),
                Positioned(
                  top: 676,
                  right: 10,
                  child: ElevatedButton(
                    style: buttonStyle(),
                    onPressed: moveToMyLocation,
                    child: const Icon(Icons.my_location),
                  ),
                ),
                Positioned(
                  bottom: 100,
                  right: 10,
                  child: ElevatedButton(
                    style: buttonStyle(),
                    onPressed: zoomIn,
                    child: const Icon(Icons.zoom_in),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  right: 10,
                  child: ElevatedButton(
                    style: buttonStyle(),
                    onPressed: zoomOut,
                    child: const Icon(Icons.zoom_out),
                  ),
                ),
              ],
            ),
    );
  }
}
