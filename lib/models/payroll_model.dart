import 'package:cloud_firestore/cloud_firestore.dart';

class PayrollModel {
  final String id;
  final String userId;
  final int month;
  final int year;
  final double basic;
  final double allowances;
  final double deductions;
  final double netPay;
  final String status; // e.g., Paid, Pending
  final DateTime createdAt;

  PayrollModel({
    required this.id,
    required this.userId,
    required this.month,
    required this.year,
    required this.basic,
    required this.allowances,
    required this.deductions,
    required this.netPay,
    required this.status,
    required this.createdAt,
  });

  factory PayrollModel.fromMap(Map<String, dynamic> map, String id) {
    return PayrollModel(
      id: id,
      userId: map['userId'] ?? '',
      month: map['month'] ?? 1,
      year: map['year'] ?? 2000,
      basic: (map['basic'] as num).toDouble(),
      allowances: (map['allowances'] as num).toDouble(),
      deductions: (map['deductions'] as num).toDouble(),
      netPay: (map['netPay'] as num).toDouble(),
      status: map['status'] ?? 'Paid',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'month': month,
      'year': year,
      'basic': basic,
      'allowances': allowances,
      'deductions': deductions,
      'netPay': netPay,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
