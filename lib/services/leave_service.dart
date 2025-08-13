import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leave_model.dart';

class LeaveService {
  final _leavesRef = FirebaseFirestore.instance.collection('leaves');

  Future<List<LeaveModel>> getLeavesForUser(String userId) async {
    final query = await _leavesRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return query.docs
        .map((doc) => LeaveModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<String> submitLeaveRequest(String userId, LeaveModel leave) async {
    // Get employee information
    String? employeeName;
    String? employeeEmail;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        employeeName =
            userData['displayName'] ?? userData['email'] ?? 'Unknown Employee';
        employeeEmail = userData['email'] ?? '';
      }
    } catch (e) {
      print('Error fetching employee info for leave request: $e');
      employeeName = 'Unknown Employee';
      employeeEmail = '';
    }

    final leaveData = {
      ...leave.toMap(),
      'userId': userId,
      'status': 'Pending', // Explicitly set status to Pending
      'employeeName': employeeName,
      'employeeEmail': employeeEmail,
    };
    final docRef = await _leavesRef.add(leaveData);
    return docRef.id;
  }

  Future<List<LeaveModel>> getAllLeaves() async {
    final query = await _leavesRef.orderBy('createdAt', descending: true).get();
    final leaves = <LeaveModel>[];

    for (final doc in query.docs) {
      final leaveData = doc.data();
      final userId = leaveData['userId'] as String?;

      // Fetch employee information if userId exists
      String? employeeName;
      String? employeeEmail;

      if (userId != null && userId.isNotEmpty) {
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

          if (userDoc.exists) {
            final userData = userDoc.data()!;
            employeeName = userData['displayName'] ??
                userData['email'] ??
                'Unknown Employee';
            employeeEmail = userData['email'] ?? '';
          }
        } catch (e) {
          print('Error fetching employee info for user $userId: $e');
          employeeName = 'Unknown Employee';
          employeeEmail = '';
        }
      }

      // Create leave model with employee information
      final leave = LeaveModel(
        id: doc.id,
        type: leaveData['type'] ?? '',
        startDate: (leaveData['startDate'] as Timestamp).toDate(),
        endDate: (leaveData['endDate'] as Timestamp).toDate(),
        reason: leaveData['reason'] ?? '',
        status: leaveData['status'] ?? 'Pending',
        createdAt: (leaveData['createdAt'] as Timestamp).toDate(),
        userId: userId ?? '',
        employeeName: employeeName,
        employeeEmail: employeeEmail,
      );

      leaves.add(leave);
    }

    return leaves;
  }

  Future<void> updateLeaveStatus(String leaveId, String status) async {
    await _leavesRef.doc(leaveId).update({'status': status});
  }
}
