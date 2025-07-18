import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'controllers/auth_controller.dart';
import 'routes/app_routes.dart';
import 'views/auth/login_screen.dart';
import 'views/employee/employee_dashboard.dart';
import 'views/admin/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize AuthController
    Get.put(AuthController());
    return GetMaterialApp(
      title: 'Employee Attendance & Payroll',
      debugShowCheckedModeBanner: false,
      getPages: AppRoutes.routes,
      home: Obx(() {
        final user = AuthController.to.user.value;
        final userModel = AuthController.to.userModel.value;
        print('Obx rebuilt: user = ${user?.email}, role = ${userModel?.role}');
        if (user == null || userModel == null) {
          return LoginScreen();
        } else if (userModel.role == 'admin' || userModel.role == 'hr') {
          return AdminDashboard(userModel: userModel);
        } else {
          return EmployeeDashboard(
            userName: user.displayName ?? 'Employee',
            email: user.email,
            isCheckedIn: false, // TODO: Replace with real check-in status
            attendanceStatus: 'Present', // TODO: Replace with real status
          );
        }
      }),
    );
  }
}
