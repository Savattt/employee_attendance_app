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

  Future<void> submitLeaveRequest(String userId, LeaveModel leave) async {
    await _leavesRef.add({...leave.toMap(), 'userId': userId});
  }
}
