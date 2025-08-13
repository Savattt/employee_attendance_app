import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'controllers/auth_controller.dart';
import 'controllers/attendance_controller.dart';
import 'services/notification_service.dart';
import 'controllers/notification_controller.dart';
import 'services/api_client.dart';
import 'views/employee/main_scaffold.dart';
import 'views/admin/main_scaffold.dart';
import 'views/auth/login_screen.dart';
import 'routes/app_routes.dart';
import 'firebase_options.dart';

void main() async {
  print('=== MAIN FUNCTION START ===');
  WidgetsFlutterBinding.ensureInitialized();
  print('=== WidgetsFlutterBinding initialized ===');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('=== Firebase initialized ===');

  // Initialize API client
  Get.put(ApiClient());
  print('=== ApiClient initialized ===');

  // Initialize controllers in correct order
  final authController = Get.put(AuthController());
  print('=== AuthController put ===');

  // Wait a bit for the AuthController to initialize
  await Future.delayed(const Duration(milliseconds: 100));
  print('=== Delay completed ===');

  Get.put(NotificationService());
  Get.put(NotificationController());
  Get.put(AttendanceController());
  print('=== All controllers initialized ===');

  print('=== About to run MyApp ===');
  runApp(const MyApp());
  print('=== MyApp run completed ===');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('=== MyApp build called ===');
    return GetMaterialApp(
      title: 'Employee Attendance App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Responsive theme settings
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        // Responsive text themes
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontWeight: FontWeight.w600),
          titleMedium: TextStyle(fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(),
          bodyMedium: TextStyle(),
        ),
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
      getPages: AppRoutes.routes,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    print('=== AuthWrapper build called ===');
    return Obx(() {
      final controller = Get.find<AuthController>();
      print('=== Obx callback triggered ===');
      print(
          'AuthWrapper: isLoading=${controller.isLoading.value}, user=${controller.user.value?.email}, userModel=${controller.userModel.value?.role}');

      // Show loading while auth state is being determined
      if (controller.isLoading.value) {
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading...'),
              ],
            ),
          ),
        );
      }

      // If not logged in, show login screen
      if (controller.user.value == null) {
        return LoginScreen();
      }

      // If user is logged in but userModel is not loaded yet, show loading
      if (controller.userModel.value == null) {
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading user data...'),
              ],
            ),
          ),
        );
      }

      // UserModel is loaded, navigate based on user role
      print(
          'AuthWrapper: userModel role = ${controller.userModel.value?.role}');
      if (controller.userModel.value?.role == 'admin') {
        print('AuthWrapper: returning AdminMainScaffold');
        return AdminMainScaffold(userModel: controller.userModel.value!);
      } else {
        print('AuthWrapper: returning MainScaffold');
        return const MainScaffold();
      }
    });
  }
}
