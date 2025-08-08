import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:epr_system/model/customer_model.dart';
import 'package:epr_system/model/order_model.dart';
import 'package:epr_system/model/product_model.dart';
import 'package:epr_system/model/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Users Collection
  Future<void> createUser(String uid, Map<String, dynamic> userData) async {
    await _firestore.collection('users').doc(uid).set(userData);
  }

  // Future<DocumentSnapshot> getUser(String uid) async {
  //   return await _firestore.collection('users').doc(uid).get();
  // }

  // Products Collection
  // Future<QuerySnapshot> getProducts() async {
  //   return await _firestore.collection('products').get();
  // }

  // Future<void> addProduct(Map<String, dynamic> productData) async {
  //   await _firestore.collection('products').add(productData);
  // }

  // Orders Collection
  Future<QuerySnapshot> fetchOrders() async {
    return await _firestore.collection('orders').get();
  }

  Stream<QuerySnapshot> getOrdersSnapshot() {
    return _firestore.collection('orders').snapshots();
  }

  Stream<QuerySnapshot> getProductsSnapshot() {
    return _firestore.collection('products').snapshots();
  }

  Stream<QuerySnapshot> getCustomersSnapshot() {
    return _firestore.collection('customers').snapshots();
  }

  // For other screens that need model objects
  Stream<List<OrderModel>> getOrders() {
    return getOrdersSnapshot().map(
      (snapshot) =>
          snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList(),
    );
  }

  Stream<List<ProductModel>> getProducts() {
    return getProductsSnapshot().map(
      (snapshot) =>
          snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList(),
    );
  }

  Stream<List<CustomerModel>> getCustomers() {
    return getCustomersSnapshot().map(
      (snapshot) =>
          snapshot.docs.map((doc) => CustomerModel.fromFirestore(doc)).toList(),
    );
  }

  // Future<void> addOrder(Map<String, dynamic> orderData) async {
  //   await _firestore.collection('orders').add(orderData);
  // }

  // // Customers Collection
  // Future<QuerySnapshot> getCustomers() async {
  //   return await _firestore.collection('customers').get();
  // }

  // Future<void> addCustomer(Map<String, dynamic> customerData) async {
  //   await _firestore.collection('customers').add(customerData);
  // }

  // Future<void> saveUser(UserModel user) async {
  //   await _firestore.collection('users').doc(user.uid).set(user.toFirestore());
  // }

  Stream<UserModel> getUser(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => UserModel.fromFirestore(doc, uid));
  }

  // Stream<QuerySnapshot> getOrdersSnapshot() {
  //   return _firestore.collection('orders').snapshots();
  // }

  // // Keep this method for when you need List<OrderModel>
  // Stream<List<OrderModel>> getOrders() {
  //   return _firestore
  //       .collection('orders')
  //       .snapshots()
  //       .map(
  //         (snapshot) => snapshot.docs
  //             .map((doc) => OrderModel.fromFirestore(doc))
  //             .toList(),
  //       );
  // }

  // Product Operations
  Future<void> addProduct(ProductModel product) async {
    await _firestore.collection('products').add(product.toFirestore());
  }

  // Stream<List<ProductModel>> getProducts() {
  //   return _firestore
  //       .collection('products')
  //       .snapshots()
  //       .map(
  //         (snapshot) => snapshot.docs
  //             .map((doc) => ProductModel.fromFirestore(doc))
  //             .toList(),
  //       );
  // }

  // // Customer Operations
  // Future<void> addCustomer(CustomerModel customer) async {
  //   await _firestore.collection('customers').add(customer.toFirestore());
  // }

  // Stream<List<CustomerModel>> getCustomers() {
  //   return _firestore
  //       .collection('customers')
  //       .snapshots()
  //       .map(
  //         (snapshot) => snapshot.docs
  //             .map((doc) => CustomerModel.fromFirestore(doc))
  //             .toList(),
  //       );
  // }

  // Order Operations
  Future<void> addOrder(OrderModel order) async {
    await _firestore.collection('orders').add(order.toFirestore());
  }

  // Stream<List<OrderModel>> getOrders() {
  //   return _firestore
  //       .collection('orders')
  //       .snapshots()
  //       .map(
  //         (snapshot) => snapshot.docs
  //             .map((doc) => OrderModel.fromFirestore(doc))
  //             .toList(),
  //       );

  // User Operations
  Future<void> saveUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toFirestore());
  }

  // Stream<UserModel> getUser(String uid) {
  //   return _firestore.collection('users').doc(uid).snapshots().map(
  //         (doc) => UserModel.fromFirestore(doc),
  //       );
  // }

  // Product Operations
  // Future<void> addProduct(ProductModel product) async {
  //   await _firestore.collection('products').add(product.toFirestore());
  // }

  // Stream<List<ProductModel>> getProducts() {
  //   return _firestore.collection('products').snapshots().map(
  //         (snapshot) => snapshot.docs
  //             .map((doc) => ProductModel.fromFirestore(doc))
  //             .toList(),
  //       );
  // }

  //
}
