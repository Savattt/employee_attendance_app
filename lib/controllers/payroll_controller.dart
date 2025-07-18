import 'package:get/get.dart';
import '../models/payroll_model.dart';
import '../services/payroll_service.dart';
import 'auth_controller.dart';

class PayrollController extends GetxController {
  var payrollList = <PayrollModel>[].obs;
  var isLoading = false.obs;
  final PayrollService _payrollService = PayrollService();

  @override
  void onInit() {
    super.onInit();
    fetchPayrolls();
  }

  Future<void> fetchPayrolls() async {
    isLoading.value = true;
    final user = AuthController.to.user.value;
    if (user != null) {
      payrollList.value = await _payrollService.getPayrollsForUser(user.uid);
    }
    isLoading.value = false;
  }

  Future<void> fetchAllPayrolls() async {
    isLoading.value = true;
    payrollList.value = await _payrollService.getAllPayrolls();
    isLoading.value = false;
  }
}
