import 'package:flutter/material.dart';

class DrivingPage extends StatelessWidget {
  const DrivingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driving'),
      ),
      body: const Center(
        child: Text('Driving Page'),
      ),
    );
  }
}
