import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leave_model.dart';
import '../services/leave_api_service.dart';
import '../config/api_config.dart';
import 'package:dio/dio.dart' as dio;

class LeaveController extends GetxController {
  final LeaveApiService _leaveApiService = Get.put(LeaveApiService());

  final RxBool isLoading = false.obs;
  final RxList<LeaveModel> leaveList = <LeaveModel>[].obs;
  final RxList<LeaveModel> allLeaves = <LeaveModel>[].obs;

  Future<void> fetchLeaves() async {
    isLoading.value = true;
    try {
      // Check if we should use Firebase or Laravel API
      if (ApiConfig.useFirebase) {
        print('=== Using Firebase for leaves ===');
        await _fetchLeavesFromFirebase();
      } else {
        print('=== Using Laravel API for leaves ===');
        await _fetchLeavesFromApi();
      }
    } catch (e) {
      print('=== Error fetching leaves: $e ===');
      Get.snackbar('Error', 'Failed to fetch leaves: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchLeavesFromFirebase() async {
    try {
      // Use Firebase Firestore directly
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('=== No user logged in ===');
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('leaves')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      final leaves = snapshot.docs
          .map((doc) => LeaveModel.fromMap(doc.data(), doc.id))
          .toList();

      leaveList.value = leaves;
      print('=== Firebase leaves loaded: ${leaves.length} items ===');
    } catch (e) {
      print('=== Firebase error: $e ===');
      rethrow;
    }
  }

  Future<void> _fetchLeavesFromApi() async {
    print('=== Fetching leaves from API ===');
    print('=== API Base URL: ${_leaveApiService.client.baseUrl} ===');

    final response = await _leaveApiService.listLeaves();
    print('=== API Response Status: ${response.statusCode} ===');
    print('=== API Response Data: ${response.data} ===');

    if (response.statusCode == 200) {
      final List<dynamic> data =
          response.data['data']['data'] ?? response.data['data'] ?? [];
      print('=== Parsed data length: ${data.length} ===');
      leaveList.value = data.map((json) => LeaveModel.fromJson(json)).toList();
      print('=== Leave list updated: ${leaveList.length} items ===');
    } else {
      print('=== API returned non-200 status: ${response.statusCode} ===');
      Get.snackbar('Error', 'API returned status ${response.statusCode}');
    }
  }

  Future<bool> requestLeave({
    required String type,
    required String startDate,
    required String endDate,
    String? reason,
  }) async {
    isLoading.value = true;
    try {
      if (ApiConfig.useFirebase) {
        print('=== Creating leave request in Firebase ===');
        return await _createLeaveInFirebase(
          type: type,
          startDate: startDate,
          endDate: endDate,
          reason: reason,
        );
      } else {
        print('=== Creating leave request via API ===');
        return await _createLeaveViaApi(
          type: type,
          startDate: startDate,
          endDate: endDate,
          reason: reason,
        );
      }
    } catch (e) {
      print('Error requesting leave: $e');
      Get.snackbar('Error', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _createLeaveInFirebase({
    required String type,
    required String startDate,
    required String endDate,
    String? reason,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'User not logged in');
        return false;
      }

      final leaveData = {
        'type': type,
        'startDate': startDate,
        'endDate': endDate,
        'reason': reason ?? '',
        'status': 'Pending',
        'userId': user.uid,
        'employeeName': user.displayName ?? 'Unknown',
        'employeeEmail': user.email ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('leaves').add(leaveData);

      await fetchLeaves();
      Get.snackbar('Success', 'Leave request submitted successfully');
      return true;
    } catch (e) {
      print('=== Firebase create leave error: $e ===');
      rethrow;
    }
  }

  Future<bool> _createLeaveViaApi({
    required String type,
    required String startDate,
    required String endDate,
    String? reason,
  }) async {
    final response = await _leaveApiService.createLeave(
      type: type,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      await fetchLeaves();
      Get.snackbar('Success', 'Leave request submitted successfully');
      return true;
    } else {
      Get.snackbar('Error', 'Failed to submit leave request');
      return false;
    }
  }

  Future<void> fetchAllLeaves() async {
    isLoading.value = true;
    try {
      final response = await _leaveApiService.listLeaves();
      if (response.statusCode == 200) {
        final List<dynamic> data =
            response.data['data']['data'] ?? response.data['data'] ?? [];
        allLeaves.value =
            data.map((json) => LeaveModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error fetching all leaves: $e');
      Get.snackbar('Error', 'Failed to fetch all leaves');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateLeaveStatus(String leaveId, String status) async {
    isLoading.value = true;
    try {
      final response = await _leaveApiService.updateStatus(leaveId, status);

      if (response.statusCode == 200) {
        await fetchAllLeaves();
        Get.snackbar('Success', 'Leave status updated successfully');
        return true;
      } else {
        Get.snackbar('Error', 'Failed to update leave status');
        return false;
      }
    } catch (e) {
      print('Error updating leave status: $e');
      Get.snackbar('Error', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
