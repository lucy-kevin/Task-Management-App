import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:epr_system/services/firebase_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TopProductsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firestore = Provider.of<FirestoreService>(context);

    return StreamBuilder<QuerySnapshot>(
      stream: firestore.getProductsSnapshot(), // Use the snapshot method
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No products available'));
        }

        final products = snapshot.data!.docs;
        // Sort products by sold quantity (descending)
        products.sort((a, b) {
          final aSold = (a.data() as Map<String, dynamic>)['sold'] ?? 0;
          final bSold = (b.data() as Map<String, dynamic>)['sold'] ?? 0;
          return bSold.compareTo(aSold);
        });

        // Take top 5 products
        final topProducts = products.take(5).toList();

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Top Selling Products',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        // Optional: Add refresh functionality
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...topProducts.map((productDoc) {
                  final product = productDoc.data() as Map<String, dynamic>;
                  final index = topProducts.indexOf(productDoc);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        // Colored indicator
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Color.lerp(
                              const Color(0xFF6366F1),
                              const Color(0xFFEC4899),
                              index / 4,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                        // Product name
                        Expanded(
                          child: Text(
                            product['name'] ?? 'Unnamed Product',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        // Sold count
                        Chip(
                          label: Text(
                            '${product['sold'] ?? 0} sold',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: Colors.grey.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
}
