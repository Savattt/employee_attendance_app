import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'api_client.dart';

class LeaveApiService {
  final ApiClient client = Get.put(ApiClient());

  Future<dio.Response> createLeave({
    required String type,
    required String startDate,
    required String endDate,
    String? reason,
  }) async {
    return client.dio.post('/leaves', data: {
      'type': type,
      'start_date': startDate,
      'end_date': endDate,
      'reason': reason,
    });
  }

  Future<dio.Response> listLeaves() async {
    try {
      return await client.dio.get('/leaves').timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );
    } catch (e) {
      print('=== LeaveApiService error: $e ===');
      rethrow;
    }
  }

  Future<dio.Response> updateStatus(String id, String status) =>
      client.dio.patch('/leaves/$id/status', data: {'status': status});
}
