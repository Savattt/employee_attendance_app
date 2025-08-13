import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/api_config.dart';

class ApiClient {
  final Dio dio;
  final String baseUrl;

  ApiClient({String? baseUrl})
      : baseUrl = baseUrl ?? ApiConfig.baseUrl,
        dio = Dio(BaseOptions(baseUrl: baseUrl ?? ApiConfig.baseUrl)) {
    dio.interceptors.add(
      InterceptorsWrapper(onRequest: (options, handler) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          try {
            final token = await user.getIdToken();
            options.headers['Authorization'] = 'Bearer $token';
          } catch (e) {
            // For local development, use x-dev-uid header
            options.headers['x-dev-uid'] = user.uid;
          }
        } else {
          // For local development without user, use test-user
          options.headers['x-dev-uid'] = 'test-user';
        }
        handler.next(options);
      }),
    );
  }
}
