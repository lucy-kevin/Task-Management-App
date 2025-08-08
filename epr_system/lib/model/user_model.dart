import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? name;
  final String role;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool isActive;
  final String? phone;
  final String? department;

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.role = 'user',
    required this.createdAt,
    this.lastLogin,
    this.isActive = true,
    this.phone,
    this.department,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc, String id) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'],
      role: data['role'] ?? 'user',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLogin: data['lastLogin']?.toDate(),
      isActive: data['isActive'] ?? true,
      phone: data['phone'],
      department: data['department'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'isActive': isActive,
      'phone': phone,
      'department': department,
      if (name != null) 'searchKeywords': _generateSearchKeywords(name!),
    };
  }

  List<String> _generateSearchKeywords(String name) {
    final keywords = <String>[];
    for (var i = 1; i <= name.length; i++) {
      keywords.add(name.substring(0, i).toLowerCase());
    }
    return keywords;
  }
}
