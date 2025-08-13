import 'package:cloud_firestore/cloud_firestore.dart';

class QRCodeModel {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isActive;
  final String createdBy;
  final String location;
  final Map<String, dynamic>? metadata;

  QRCodeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.expiresAt,
    required this.isActive,
    required this.createdBy,
    required this.location,
    this.metadata,
  });

  factory QRCodeModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return QRCodeModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      createdBy: data['createdBy'] ?? '',
      location: data['location'] ?? '',
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'isActive': isActive,
      'createdBy': createdBy,
      'location': location,
      'metadata': metadata,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Generate QR code data string
  String get qrData {
    try {
      // Ensure all values are valid strings
      final safeId = id.replaceAll(RegExp(r'[^\w\-]'), '');
      final safeLocation = location.replaceAll(RegExp(r'[^\w\s\-]'), '');
      final timestamp = expiresAt.millisecondsSinceEpoch.toString();

      return 'ATTENDANCE_QR:$safeId:$safeLocation:$timestamp';
    } catch (e) {
      print('Error generating QR data: $e');
      // Fallback to a simple format
      return 'QR:$id:${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  // Check if QR code is still valid
  bool get isValid {
    return isActive && DateTime.now().isBefore(expiresAt);
  }

  // Get remaining time in minutes
  int get remainingMinutes {
    if (!isValid) return 0;
    return expiresAt.difference(DateTime.now()).inMinutes;
  }

  QRCodeModel copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isActive,
    String? createdBy,
    String? location,
    Map<String, dynamic>? metadata,
  }) {
    return QRCodeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      location: location ?? this.location,
      metadata: metadata ?? this.metadata,
    );
  }
}
