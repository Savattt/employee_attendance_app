import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leave_model.dart';

class AdminController extends GetxController {
  var leaveList = <LeaveModelWithEmployee>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllLeaves();
  }

  Future<void> fetchAllLeaves() async {
    isLoading.value = true;
    final leavesSnapshot = await FirebaseFirestore.instance
        .collection('leaves')
        .orderBy('createdAt', descending: true)
        .get();
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .get();
    final userMap = {
      for (var doc in usersSnapshot.docs) doc.id: doc.data()['email'],
    };
    leaveList.value = leavesSnapshot.docs.map((doc) {
      final leave = LeaveModel.fromMap(doc.data(), doc.id);
      return LeaveModelWithEmployee(
        leave: leave,
        employeeEmail: userMap[doc.data()['userId']] ?? 'Unknown',
      );
    }).toList();
    isLoading.value = false;
  }

  Future<void> updateLeaveStatus(
    LeaveModelWithEmployee leaveWithEmp,
    String status,
  ) async {
    await FirebaseFirestore.instance
        .collection('leaves')
        .doc(leaveWithEmp.leave.id)
        .update({'status': status});
    await fetchAllLeaves();
  }
}

class LeaveModelWithEmployee {
  final LeaveModel leave;
  final String employeeEmail;
  LeaveModelWithEmployee({required this.leave, required this.employeeEmail});

  String get type => leave.type;
  DateTime get startDate => leave.startDate;
  DateTime get endDate => leave.endDate;
  String get reason => leave.reason;
  String get status => leave.status;
  String get id => leave.id;
}
