import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final double cost;
  final int stock;
  final int sold;
  final String? barcode;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  ProductModel({
    this.id = '',
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.cost,
    required this.stock,
    this.sold = 0,
    this.barcode,
    this.imageUrl,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'uncategorized',
      price: (data['price'] ?? 0).toDouble(),
      cost: (data['cost'] ?? 0).toDouble(),
      stock: data['stock'] ?? 0,
      sold: data['sold'] ?? 0,
      barcode: data['barcode'],
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt']?.toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'cost': cost,
      'stock': stock,
      'sold': sold,
      'barcode': barcode,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isActive': isActive,
      'searchKeywords': _generateSearchKeywords(),
    };
  }

  List<String> _generateSearchKeywords() {
    final keywords = <String>[];
    // Add name variations
    for (var i = 1; i <= name.length; i++) {
      keywords.add(name.substring(0, i).toLowerCase());
    }
    // Add category variations
    for (var i = 1; i <= category.length; i++) {
      keywords.add(category.substring(0, i).toLowerCase());
    }
    // Add barcode if exists
    if (barcode != null) {
      keywords.add(barcode!);
    }
    return keywords;
  }

  ProductModel copyWith({
    String? name,
    String? description,
    String? category,
    double? price,
    double? cost,
    int? stock,
    int? sold,
    String? barcode,
    String? imageUrl,
    bool? isActive,
  }) {
    return ProductModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      stock: stock ?? this.stock,
      sold: sold ?? this.sold,
      barcode: barcode ?? this.barcode,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isActive: isActive ?? this.isActive,
    );
  }
}
