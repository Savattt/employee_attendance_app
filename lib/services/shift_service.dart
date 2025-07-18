import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shift_model.dart';

class ShiftService {
  final _shiftsRef = FirebaseFirestore.instance.collection('shifts');

  Future<List<ShiftModel>> getShiftsForUser(String userId) async {
    final query = await _shiftsRef
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: false)
        .get();
    return query.docs
        .map((doc) => ShiftModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> addShift(ShiftModel shift) async {
    await _shiftsRef.add(shift.toMap());
  }

  Future<void> updateShift(String id, Map<String, dynamic> data) async {
    await _shiftsRef.doc(id).update(data);
  }

  Future<List<ShiftModel>> getAllShifts() async {
    final query = await _shiftsRef.orderBy('date', descending: false).get();
    return query.docs
        .map((doc) => ShiftModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}
