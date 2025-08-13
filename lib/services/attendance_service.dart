import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/attendance_model.dart';
import '../models/qr_code_model.dart';

class AttendanceService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // QR Code Management
  static Future<String> createQRCode({
    required String name,
    required String description,
    required String location,
    required String createdBy,
    required int validMinutes,
  }) async {
    try {
      final now = DateTime.now();
      final expiresAt = now.add(Duration(minutes: validMinutes));

      final qrCodeData = {
        'name': name,
        'description': description,
        'location': location,
        'createdBy': createdBy,
        'createdAt': Timestamp.fromDate(now),
        'expiresAt': Timestamp.fromDate(expiresAt),
        'isActive': true,
        'metadata': {
          'validMinutes': validMinutes,
        },
      };

      final docRef = await _firestore.collection('qr_codes').add(qrCodeData);
      return docRef.id;
    } catch (e) {
      print('Error creating QR code: $e');
      rethrow;
    }
  }

  static Future<QRCodeModel?> getQRCode(String qrCodeId) async {
    try {
      final doc = await _firestore.collection('qr_codes').doc(qrCodeId).get();
      if (doc.exists) {
        return QRCodeModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting QR code: $e');
      return null;
    }
  }

  static Future<List<QRCodeModel>> getActiveQRCodes() async {
    try {
      final querySnapshot = await _firestore
          .collection('qr_codes')
          .where('isActive', isEqualTo: true)
          .get();

      final now = DateTime.now();
      final activeCodes = querySnapshot.docs
          .map((doc) => QRCodeModel.fromFirestore(doc))
          .where((qrCode) => qrCode.expiresAt.isAfter(now))
          .toList();

      // Sort by expiry date (most recent first)
      activeCodes.sort((a, b) => b.expiresAt.compareTo(a.expiresAt));

      return activeCodes;
    } catch (e) {
      print('Error getting active QR codes: $e');
      return [];
    }
  }

  static Future<void> deactivateQRCode(String qrCodeId) async {
    try {
      await _firestore.collection('qr_codes').doc(qrCodeId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error deactivating QR code: $e');
      rethrow;
    }
  }

  // QR Code Validation
  static Map<String, dynamic> validateQRCodeData(String qrData) {
    try {
      final parts = qrData.split(':');
      if (parts.length != 4 || parts[0] != 'ATTENDANCE_QR') {
        return {'valid': false, 'error': 'Invalid QR code format'};
      }

      final qrCodeId = parts[1];
      final location = parts[2];
      final expiryTimestamp = int.tryParse(parts[3]);

      if (expiryTimestamp == null) {
        return {'valid': false, 'error': 'Invalid expiry timestamp'};
      }

      final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
      if (DateTime.now().isAfter(expiryDate)) {
        return {'valid': false, 'error': 'QR code has expired'};
      }

      return {
        'valid': true,
        'qrCodeId': qrCodeId,
        'location': location,
        'expiryDate': expiryDate,
      };
    } catch (e) {
      return {'valid': false, 'error': 'Error parsing QR code data'};
    }
  }

  // Attendance Management
  static Future<String> checkIn({
    required String userId,
    required String employeeName,
    required String employeeEmail,
    required String qrCodeId,
    required String location,
  }) async {
    try {
      // Check if user already checked in today
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Get all attendance records for this user and filter locally
      final existingAttendance = await _firestore
          .collection('attendance')
          .where('userId', isEqualTo: userId)
          .get();

      // Filter for today's checked-in records
      final todayCheckedIn = existingAttendance.docs
          .map((doc) => AttendanceModel.fromFirestore(doc))
          .where((attendance) =>
              attendance.checkInTime.isAfter(startOfDay) &&
              attendance.checkInTime.isBefore(endOfDay) &&
              attendance.status == 'checked-in')
          .toList();

      if (todayCheckedIn.isNotEmpty) {
        throw Exception('Already checked in today');
      }

      // Get current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final attendanceData = {
        'userId': userId,
        'employeeName': employeeName,
        'employeeEmail': employeeEmail,
        'checkInTime': Timestamp.fromDate(DateTime.now()),
        'location': location,
        'qrCodeId': qrCodeId,
        'status': 'checked-in',
        'metadata': {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'accuracy': position.accuracy,
        },
      };

      final docRef =
          await _firestore.collection('attendance').add(attendanceData);
      return docRef.id;
    } catch (e) {
      print('Error checking in: $e');
      rethrow;
    }
  }

  static Future<void> checkOut({
    required String userId,
    required String qrCodeId,
    required String location,
  }) async {
    try {
      // Find today's check-in record
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Get all attendance records for this user and filter locally
      final attendanceQuery = await _firestore
          .collection('attendance')
          .where('userId', isEqualTo: userId)
          .get();

      // Filter for today's checked-in records
      final todayCheckedIn = attendanceQuery.docs
          .map((doc) => AttendanceModel.fromFirestore(doc))
          .where((attendance) =>
              attendance.checkInTime.isAfter(startOfDay) &&
              attendance.checkInTime.isBefore(endOfDay) &&
              attendance.status == 'checked-in')
          .toList();

      if (todayCheckedIn.isEmpty) {
        throw Exception('No check-in record found for today');
      }

      final attendanceDoc = attendanceQuery.docs.firstWhere(
        (doc) => doc.id == todayCheckedIn.first.id,
      );

      // Get current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await attendanceDoc.reference.update({
        'checkOutTime': Timestamp.fromDate(DateTime.now()),
        'status': 'checked-out',
        'metadata': {
          ...attendanceDoc.data()['metadata'] ?? {},
          'checkout_latitude': position.latitude,
          'checkout_longitude': position.longitude,
          'checkout_accuracy': position.accuracy,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error checking out: $e');
      rethrow;
    }
  }

  static Future<AttendanceModel?> getTodayAttendance(String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _firestore
          .collection('attendance')
          .where('userId', isEqualTo: userId)
          .get();

      // Filter locally for today's attendance
      final todayAttendance = querySnapshot.docs
          .map((doc) => AttendanceModel.fromFirestore(doc))
          .where((attendance) =>
              attendance.checkInTime.isAfter(startOfDay) &&
              attendance.checkInTime.isBefore(endOfDay))
          .toList();

      if (todayAttendance.isNotEmpty) {
        return todayAttendance.first;
      }
      return null;
    } catch (e) {
      print('Error getting today\'s attendance: $e');
      return null;
    }
  }

  static Future<List<AttendanceModel>> getAttendanceHistory({
    required String userId,
    int limit = 30,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('attendance')
          .where('userId', isEqualTo: userId)
          .orderBy('checkInTime', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => AttendanceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting attendance history: $e');
      return [];
    }
  }

  static Future<List<AttendanceModel>> getAllAttendance({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    try {
      Query query = _firestore.collection('attendance');

      if (startDate != null) {
        query = query.where('checkInTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('checkInTime',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final querySnapshot = await query
          .orderBy('checkInTime', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => AttendanceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting all attendance: $e');
      return [];
    }
  }
}
