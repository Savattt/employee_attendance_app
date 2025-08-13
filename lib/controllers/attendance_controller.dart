import 'package:get/get.dart';
import '../models/attendance_model.dart';
import '../services/attendance_api_service.dart';
import 'package:dio/dio.dart' as dio;

class AttendanceController extends GetxController {
  final AttendanceApiService _attendanceApiService =
      Get.put(AttendanceApiService());

  final RxBool isLoading = false.obs;
  final RxList<AttendanceModel> attendanceList = <AttendanceModel>[].obs;
  final Rxn<AttendanceModel> todayAttendance = Rxn<AttendanceModel>();

  @override
  void onInit() {
    super.onInit();
  }

  Future<bool> checkIn({
    required String userId,
    required String employeeName,
    required String employeeEmail,
    required String qrCodeId,
    required String location,
  }) async {
    try {
      isLoading.value = true;
      final response = await _attendanceApiService.checkIn(
        qrCodeId: qrCodeId,
        location: location,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        await loadTodayAttendance(userId);
        Get.snackbar('Success', 'Check-in successful!');
        return true;
      } else {
        Get.snackbar('Error', 'Check-in failed');
        return false;
      }
    } catch (e) {
      print('Error checking in: $e');
      Get.snackbar('Error', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> checkOut({
    required String userId,
    required String employeeName,
    required String employeeEmail,
  }) async {
    try {
      isLoading.value = true;
      final response = await _attendanceApiService.checkOut();

      if (response.statusCode == 200) {
        await loadTodayAttendance(userId);
        Get.snackbar('Success', 'Check-out successful!');
        return true;
      } else {
        Get.snackbar('Error', 'Check-out failed');
        return false;
      }
    } catch (e) {
      print('Error checking out: $e');
      Get.snackbar('Error', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadTodayAttendance(String userId) async {
    try {
      isLoading.value = true;
      final response = await _attendanceApiService.today();

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data != null) {
          todayAttendance.value = AttendanceModel(
            id: 'today',
            userId: userId,
            employeeName: 'Test User',
            employeeEmail: 'test@example.com',
            checkInTime: data['check_in'] != null
                ? DateTime.parse(data['check_in'])
                : DateTime.now(),
            checkOutTime: data['check_out'] != null
                ? DateTime.parse(data['check_out'])
                : null,
            location: 'Office',
            qrCodeId: 'QR123',
            status: data['check_in'] != null ? 'checked-in' : 'not-checked-in',
          );
        }
      }
    } catch (e) {
      print('Error loading today attendance: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAttendanceHistory(String userId,
      {String? from, String? to}) async {
    try {
      isLoading.value = true;
      final response = await _attendanceApiService.history(from: from, to: to);

      if (response.statusCode == 200) {
        final data = response.data['data']['data'] ?? [];
        attendanceList.value =
            data.map((json) => AttendanceModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error loading attendance history: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAllAttendance({String? from, String? to}) async {
    try {
      isLoading.value = true;
      final response = await _attendanceApiService.history(from: from, to: to);

      if (response.statusCode == 200) {
        final data = response.data['data']['data'] ?? [];
        attendanceList.value =
            data.map((json) => AttendanceModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error loading all attendance: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
