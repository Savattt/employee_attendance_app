import 'package:get/get.dart';
import '../models/shift_model.dart';
import '../services/shift_service.dart';
import 'auth_controller.dart';

class ShiftController extends GetxController {
  var shiftList = <ShiftModel>[].obs;
  var isLoading = false.obs;
  final ShiftService _shiftService = ShiftService();

  @override
  void onInit() {
    super.onInit();
    fetchShifts();
  }

  Future<void> fetchShifts() async {
    isLoading.value = true;
    final user = AuthController.to.user.value;
    if (user != null) {
      shiftList.value = await _shiftService.getShiftsForUser(user.uid);
    }
    isLoading.value = false;
  }

  Future<void> fetchAllShifts() async {
    isLoading.value = true;
    shiftList.value = await _shiftService.getAllShifts();
    isLoading.value = false;
  }
}
