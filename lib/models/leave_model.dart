class LeaveModel {
  final String id;
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String status; // e.g., Pending, Approved, Rejected
  final DateTime createdAt;
  final String userId; // Employee ID
  final String? employeeName; // Employee name
  final String? employeeEmail; // Employee email

  LeaveModel({
    required this.id,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.createdAt,
    required this.userId,
    this.employeeName,
    this.employeeEmail,
  });

  factory LeaveModel.fromMap(Map<String, dynamic> map, String id) {
    return LeaveModel(
      id: id,
      type: map['type'] ?? '',
      startDate: DateTime.parse(map['start_date'] ??
          map['startDate'] ??
          DateTime.now().toIso8601String()),
      endDate: DateTime.parse(map['end_date'] ??
          map['endDate'] ??
          DateTime.now().toIso8601String()),
      reason: map['reason'] ?? '',
      status: map['status'] ?? 'Pending',
      createdAt: DateTime.parse(map['created_at'] ??
          map['createdAt'] ??
          DateTime.now().toIso8601String()),
      userId: map['user_id'] ?? map['userId'] ?? '',
      employeeName: map['employee_name'] ?? map['employeeName'],
      employeeEmail: map['employee_email'] ?? map['employeeEmail'],
    );
  }

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? '',
      startDate: DateTime.parse(json['start_date'] ??
          json['startDate'] ??
          DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['end_date'] ??
          json['endDate'] ??
          DateTime.now().toIso8601String()),
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'Pending',
      createdAt: DateTime.parse(json['created_at'] ??
          json['createdAt'] ??
          DateTime.now().toIso8601String()),
      userId: json['user_id'] ?? json['userId'] ?? '',
      employeeName: json['employee_name'] ?? json['employeeName'],
      employeeEmail: json['employee_email'] ?? json['employeeEmail'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'reason': reason,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
      'employee_name': employeeName,
      'employee_email': employeeEmail,
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }
}
