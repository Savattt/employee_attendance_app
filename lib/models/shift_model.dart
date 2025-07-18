import 'package:cloud_firestore/cloud_firestore.dart';

class ShiftModel {
  final String id;
  final String userId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String shiftType; // e.g., Morning, Evening, Night
  final String status; // e.g., Scheduled, Completed, Cancelled
  final DateTime createdAt;

  ShiftModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.shiftType,
    required this.status,
    required this.createdAt,
  });

  factory ShiftModel.fromMap(Map<String, dynamic> map, String id) {
    return ShiftModel(
      id: id,
      userId: map['userId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      shiftType: map['shiftType'] ?? '',
      status: map['status'] ?? 'Scheduled',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'shiftType': shiftType,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
