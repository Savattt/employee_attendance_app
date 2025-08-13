import 'package:get/get.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/auth/reset_password_screen.dart';
import '../views/admin/admin_leave_approval_screen.dart';
import '../views/employee/leave_screen.dart';
import '../views/employee/payroll_screen.dart';
import '../views/employee/shift_screen.dart';
import '../views/employee/qr_scanner_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const resetPassword = '/reset-password';

  static final routes = [
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: register, page: () => RegisterScreen()),
    GetPage(name: resetPassword, page: () => ResetPasswordScreen()),
    GetPage(
        name: '/admin/leave-approval',
        page: () => const AdminLeaveApprovalScreen()),
    GetPage(name: '/employee/leave', page: () => const LeaveScreen()),
    GetPage(name: '/employee/payroll', page: () => PayrollScreen()),
    GetPage(name: '/employee/shift', page: () => ShiftScreen()),
    GetPage(name: '/qr-scanner', page: () => const QRScannerScreen()),
  ];
}
