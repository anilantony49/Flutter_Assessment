import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final DateTime? createdAt;
  final String themeMode; // 'light', 'dark', 'system'

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    this.createdAt,
    this.themeMode = 'system',
  });

  factory UserModel.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      return UserModel(
        uid: documentId,
        fullName: 'Unknown',
        email: 'Unknown',
      );
    }
    
    DateTime? parsedCreatedAt;
    if (data['createdAt'] != null) {
      if (data['createdAt'] is Timestamp) {
        parsedCreatedAt = (data['createdAt'] as Timestamp).toDate();
      } else if (data['createdAt'] is String) {
        parsedCreatedAt = DateTime.tryParse(data['createdAt']);
      }
    }

    return UserModel(
      uid: documentId,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      createdAt: parsedCreatedAt,
      themeMode: data['themeMode'] ?? 'system',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'themeMode': themeMode,
    };
  }
}
