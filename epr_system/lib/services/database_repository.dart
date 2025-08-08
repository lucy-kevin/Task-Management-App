import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:epr_system/model/customer_model.dart';
import 'package:epr_system/model/order_model.dart';
import 'package:epr_system/model/product_model.dart';
import 'package:epr_system/services/firebase_services.dart';

class DatabaseRepository {
  final FirestoreService _firestoreService;

  DatabaseRepository(this._firestoreService);

  // Get real-time updates for dashboard stats
  Stream<Map<String, dynamic>> getDashboardStats() {
    return FirebaseFirestore.instance
        .collection('dashboard_stats')
        .doc('summary')
        .snapshots()
        .map((snapshot) => snapshot.data() ?? {});
  }

  // Inventory methods
  Stream<List<ProductModel>> getInventoryItems() {
    return _firestoreService.getProducts();
  }

  // Sales methods
  Stream<List<OrderModel>> getRecentOrders() {
    return _firestoreService.getOrders();
  }

  // Customer methods
  Stream<List<CustomerModel>> getCustomers() {
    return _firestoreService.getCustomers();
  }
}
