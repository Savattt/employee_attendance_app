import 'package:get/get.dart';
import '../models/leave_model.dart';
import '../services/leave_service.dart';
import 'auth_controller.dart';

class LeaveController extends GetxController {
  var leaveList = <LeaveModel>[].obs;
  var isLoading = false.obs;
  final LeaveService _leaveService = LeaveService();

  @override
  void onInit() {
    super.onInit();
    fetchLeaves();
  }

  Future<void> fetchLeaves() async {
    isLoading.value = true;
    final user = AuthController.to.user.value;
    if (user != null) {
      leaveList.value = await _leaveService.getLeavesForUser(user.uid);
    }
    isLoading.value = false;
  }

  Future<void> requestLeave(LeaveModel leave) async {
    final user = AuthController.to.user.value;
    if (user != null) {
      await _leaveService.submitLeaveRequest(user.uid, leave);
      await fetchLeaves();
    }
  }
}
