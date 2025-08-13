import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'api_client.dart';

class AttendanceApiService {
  final ApiClient client = Get.put(ApiClient());

  Future<dio.Response> checkIn(
      {required String qrCodeId, String? location}) async {
    return client.dio.post('/attendance/check-in', data: {
      'qr_code_id': qrCodeId,
      'location': location,
    });
  }

  Future<dio.Response> checkOut() async {
    return client.dio.post('/attendance/check-out');
  }

  Future<dio.Response> today() async {
    return client.dio.get('/attendance/today');
  }

  Future<dio.Response> history({String? from, String? to}) async {
    return client.dio.get('/attendance/history', queryParameters: {
      if (from != null) 'from': from,
      if (to != null) 'to': to,
    });
  }
}
