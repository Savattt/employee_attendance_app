import 'package:get/get.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/auth/reset_password_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const resetPassword = '/reset-password';

  static final routes = [
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: register, page: () => RegisterScreen()),
    GetPage(name: resetPassword, page: () => ResetPasswordScreen()),
  ];
}
