import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payroll_model.dart';

class PayrollService {
  final _payrollsRef = FirebaseFirestore.instance.collection('payrolls');

  Future<List<PayrollModel>> getPayrollsForUser(String userId) async {
    final query = await _payrollsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return query.docs
        .map((doc) => PayrollModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<PayrollModel>> getAllPayrolls() async {
    final query = await _payrollsRef
        .orderBy('createdAt', descending: true)
        .get();
    return query.docs
        .map((doc) => PayrollModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> addPayroll(PayrollModel payroll) async {
    await _payrollsRef.add(payroll.toMap());
  }

  Future<void> updatePayroll(String id, Map<String, dynamic> data) async {
    await _payrollsRef.doc(id).update(data);
  }
}
