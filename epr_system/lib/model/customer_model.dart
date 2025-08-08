import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String? company;
  final String? taxId;
  final double creditLimit;
  final double balance;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final String? notes;

  CustomerModel({
    this.id = '',
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.company,
    this.taxId,
    this.creditLimit = 0,
    this.balance = 0,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.notes,
  });

  factory CustomerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CustomerModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      company: data['company'],
      taxId: data['taxId'],
      creditLimit: (data['creditLimit'] ?? 0).toDouble(),
      balance: (data['balance'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt']?.toDate(),
      isActive: data['isActive'] ?? true,
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'company': company,
      'taxId': taxId,
      'creditLimit': creditLimit,
      'balance': balance,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isActive': isActive,
      'notes': notes,
      'searchKeywords': _generateSearchKeywords(),
    };
  }

  List<String> _generateSearchKeywords() {
    final keywords = <String>[];
    // Name variations
    for (var i = 1; i <= name.length; i++) {
      keywords.add(name.substring(0, i).toLowerCase());
    }
    // Email variations
    for (var i = 1; i <= email.length; i++) {
      keywords.add(email.substring(0, i).toLowerCase());
    }
    // Phone variations
    for (var i = 1; i <= phone.length; i++) {
      keywords.add(phone.substring(0, i));
    }
    // Company if exists
    if (company != null) {
      for (var i = 1; i <= company!.length; i++) {
        keywords.add(company!.substring(0, i).toLowerCase());
      }
    }
    return keywords;
  }

  CustomerModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? company,
    String? taxId,
    double? creditLimit,
    double? balance,
    bool? isActive,
    String? notes,
  }) {
    return CustomerModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      company: company ?? this.company,
      taxId: taxId ?? this.taxId,
      creditLimit: creditLimit ?? this.creditLimit,
      balance: balance ?? this.balance,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
    );
  }
}
