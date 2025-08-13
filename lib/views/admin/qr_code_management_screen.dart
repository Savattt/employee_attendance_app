import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../../controllers/attendance_controller.dart';
import '../../models/qr_code_model.dart';

class QRCodeManagementScreen extends StatefulWidget {
  const QRCodeManagementScreen({super.key});

  @override
  State<QRCodeManagementScreen> createState() => _QRCodeManagementScreenState();
}

class _QRCodeManagementScreenState extends State<QRCodeManagementScreen> {
  final AttendanceController _attendanceController =
      Get.find<AttendanceController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Management'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'QR Code Management',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'QR code management will be available\nin the next update',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Get.snackbar(
                  'Coming Soon',
                  'QR code management features will be available soon!',
                  backgroundColor: Colors.blue.shade100,
                  colorText: Colors.blue.shade900,
                );
              },
              child: const Text('Learn More'),
            ),
          ],
        ),
      ),
    );
  }
}
