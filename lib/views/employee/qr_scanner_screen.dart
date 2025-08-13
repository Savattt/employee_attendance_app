import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../controllers/attendance_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/attendance_model.dart';
import '../../utils/responsive_utils.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final AttendanceController _attendanceController =
      Get.find<AttendanceController>();
  final AuthController _authController = Get.find<AuthController>();
  MobileScannerController? _scannerController;
  bool _isScanning = false;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _hasPermission = status.isGranted;
    });
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null && !_isScanning) {
        _processQRCode(barcode.rawValue!);
        break; // Process only the first barcode
      }
    }
  }

  Future<void> _processQRCode(String qrData) async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
    });

    try {
      // Get current user
      final user = _authController.user.value;
      if (user == null) {
        Get.snackbar('Error', 'User not authenticated');
        return;
      }

      // Load today's attendance to check status
      await _attendanceController.loadTodayAttendance(user.uid);
      final todayAttendance = _attendanceController.todayAttendance.value;

      // Determine current status
      String currentStatus = 'not-checked-in';
      if (todayAttendance != null) {
        if (todayAttendance.checkOutTime != null) {
          currentStatus = 'checked-out';
        } else
          currentStatus = 'checked-in';
      }

      if (currentStatus == 'not-checked-in') {
        // Check in
        final success = await _attendanceController.checkIn(
          userId: user.uid,
          employeeName: user.displayName ?? 'Unknown',
          employeeEmail: user.email ?? '',
          qrCodeId: qrData,
          location: 'Office',
        );

        if (success) {
          _showSuccessDialog(
              'Check-in Successful!', 'You have been checked in successfully.');
        }
      } else if (currentStatus == 'checked-in') {
        // Check out
        final success = await _attendanceController.checkOut(
          userId: user.uid,
          employeeName: user.displayName ?? 'Unknown',
          employeeEmail: user.email ?? '',
        );

        if (success) {
          _showSuccessDialog('Check-out Successful!',
              'You have been checked out successfully.');
        }
      } else {
        Get.snackbar(
          'Already Checked Out',
          'You have already checked out for today',
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade900,
        );
      }
    } catch (e) {
      print('Error processing QR code: $e');
      Get.snackbar('Error', 'Failed to process QR code');
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Get.back(); // Go back to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          'QR Code Scanner',
          style: TextStyle(
            fontSize: ResponsiveUtils.getTitleFontSize(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ResponsiveBuilder(
        builder: (context, isMobile, isTablet, isDesktop) {
          return Column(
            children: [
              // Today's Status Card
              Container(
                margin: EdgeInsets.all(ResponsiveUtils.getSpacing(context)),
                padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.today,
                      color: theme.primaryColor,
                      size: ResponsiveUtils.getIconSize(context),
                    ),
                    SizedBox(width: ResponsiveUtils.getSmallSpacing(context)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Today\'s Status',
                            style: TextStyle(
                              fontSize:
                                  ResponsiveUtils.getBodyFontSize(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Obx(() {
                            final todayAttendance =
                                _attendanceController.todayAttendance.value;
                            String status = 'Not Checked In';
                            Color statusColor = Colors.grey;

                            if (todayAttendance != null) {
                              if (todayAttendance.checkOutTime != null) {
                                status = 'Checked Out';
                                statusColor = Colors.orange;
                              } else
                                status = 'Checked In';
                              statusColor = Colors.green;
                            }

                            return Text(
                              status,
                              style: TextStyle(
                                fontSize:
                                    ResponsiveUtils.getBodyFontSize(context),
                                color: statusColor,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Scanner Section
              Expanded(
                child: _hasPermission
                    ? Stack(
                        children: [
                          MobileScanner(
                            controller: _scannerController,
                            onDetect: _onDetect,
                          ),
                          // Custom overlay
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                              ),
                              child: Center(
                                child: Container(
                                  width: 250,
                                  height: 250,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.deepPurple,
                                      width: 3,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Instructions
                          Positioned(
                            bottom: 50,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal:
                                      ResponsiveUtils.getSpacing(context),
                                ),
                                padding: EdgeInsets.all(
                                    ResponsiveUtils.getSpacing(context)),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Position QR code within the frame to scan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ResponsiveUtils.getBodyFontSize(
                                        context),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            SizedBox(
                                height: ResponsiveUtils.getSpacing(context)),
                            Text(
                              'Camera permission required',
                              style: TextStyle(
                                fontSize:
                                    ResponsiveUtils.getTitleFontSize(context),
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(
                                height:
                                    ResponsiveUtils.getSmallSpacing(context)),
                            ElevatedButton(
                              onPressed: _checkPermission,
                              child: const Text('Grant Permission'),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
