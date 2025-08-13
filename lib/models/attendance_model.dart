import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String id;
  final String userId;
  final String employeeName;
  final String employeeEmail;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String location;
  final String qrCodeId;
  final String status; // 'checked-in', 'checked-out'
  final Map<String, dynamic>? metadata;

  AttendanceModel({
    required this.id,
    required this.userId,
    required this.employeeName,
    required this.employeeEmail,
    required this.checkInTime,
    this.checkOutTime,
    required this.location,
    required this.qrCodeId,
    required this.status,
    this.metadata,
  });

  factory AttendanceModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return AttendanceModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      employeeName: data['employeeName'] ?? '',
      employeeEmail: data['employeeEmail'] ?? '',
      checkInTime: (data['checkInTime'] as Timestamp).toDate(),
      checkOutTime: data['checkOutTime'] != null 
          ? (data['checkOutTime'] as Timestamp).toDate() 
          : null,
      location: data['location'] ?? '',
      qrCodeId: data['qrCodeId'] ?? '',
      status: data['status'] ?? 'checked-in',
      metadata: data['metadata'],
    );
  }

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id'] ?? json['userId'] ?? '',
      employeeName: json['employee_name'] ?? json['employeeName'] ?? '',
      employeeEmail: json['employee_email'] ?? json['employeeEmail'] ?? '',
      checkInTime: DateTime.parse(json['check_in_time'] ?? json['checkInTime'] ?? DateTime.now().toIso8601String()),
      checkOutTime: json['check_out_time'] != null || json['checkOutTime'] != null
          ? DateTime.parse(json['check_out_time'] ?? json['checkOutTime'] ?? DateTime.now().toIso8601String())
          : null,
      location: json['location'] ?? '',
      qrCodeId: json['qr_code_id'] ?? json['qrCodeId'] ?? '',
      status: json['status'] ?? 'checked-in',
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'employeeName': employeeName,
      'employeeEmail': employeeEmail,
      'checkInTime': Timestamp.fromDate(checkInTime),
      'checkOutTime': checkOutTime != null ? Timestamp.fromDate(checkOutTime!) : null,
      'location': location,
      'qrCodeId': qrCodeId,
      'status': status,
      'metadata': metadata,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'employee_name': employeeName,
      'employee_email': employeeEmail,
      'check_in_time': checkInTime.toIso8601String(),
      'check_out_time': checkOutTime?.toIso8601String(),
      'location': location,
      'qr_code_id': qrCodeId,
      'status': status,
      'metadata': metadata,
    };
  }

  AttendanceModel copyWith({
    String? id,
    String? userId,
    String? employeeName,
    String? employeeEmail,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    String? location,
    String? qrCodeId,
    String? status,
    Map<String, dynamic>? metadata,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      employeeName: employeeName ?? this.employeeName,
      employeeEmail: employeeEmail ?? this.employeeEmail,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      location: location ?? this.location,
      qrCodeId: qrCodeId ?? this.qrCodeId,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
    );
  }
} 