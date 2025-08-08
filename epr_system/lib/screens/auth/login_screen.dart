import 'package:epr_system/screens/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Please enter a valid email';
      default:
        return 'Login failed. Please try again';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock, size: 48, color: Colors.blue),
                      const SizedBox(height: 24),
                      const Text(
                        'ERP System Login',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signIn,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text('Sign In'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(24),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(32),
//                       child: Form(
//                         key: _formKey,
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           crossAxisAlignment: CrossAxisAlignment.stretch,
//                           children: [
//                             Container(
//                               width: 60,
//                               height: 60,
//                               decoration: BoxDecoration(
//                                 gradient: const LinearGradient(
//                                   colors: [
//                                     Color(0xFF6366F1),
//                                     Color(0xFF8B5CF6),
//                                   ],
//                                 ),
//                                 borderRadius: BorderRadius.circular(16),
//                               ),
//                               child: const Icon(
//                                 Icons.business,
//                                 color: Colors.white,
//                                 size: 28,
//                               ),
//                             ),
//                             const SizedBox(height: 24),
//                             Text(
//                               'Welcome Back',
//                               style: Theme.of(context).textTheme.headlineMedium
//                                   ?.copyWith(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.grey.shade800,
//                                   ),
//                             ),
//                             Text(
//                               'Sign in to your ERP account',
//                               style: TextStyle(
//                                 color: Colors.grey.shade600,
//                                 fontSize: 16,
//                               ),
//                             ),
//                             const SizedBox(height: 32),
//                             _buildTextField(
//                               controller: _emailController,
//                               label: 'Email',
//                               icon: Icons.email_outlined,
//                               keyboardType: TextInputType.emailAddress,
//                             ),
//                             const SizedBox(height: 16),
//                             _buildTextField(
//                               controller: _passwordController,
//                               label: 'Password',
//                               icon: Icons.lock_outline,
//                               isPassword: true,
//                             ),
//                             const SizedBox(height: 24),
//                             ElevatedButton(
//                               onPressed: _isLoading ? null : _signIn,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: const Color(0xFF6366F1),
//                                 foregroundColor: Colors.white,
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 16,
//                                 ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                               ),
//                               child: _isLoading
//                                   ? const SizedBox(
//                                       height: 20,
//                                       width: 20,
//                                       child: CircularProgressIndicator(
//                                         strokeWidth: 2,
//                                         color: Colors.white,
//                                       ),
//                                     )
//                                   : const Text(
//                                       'Sign In',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                             ),
//                             const SizedBox(height: 16),
//                             TextButton(
//                               onPressed: _isLoading ? null : _createDemoAccount,
//                               child: Text(
//                                 'Create Demo Account',
//                                 style: TextStyle(
//                                   color: Colors.grey.shade600,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     bool isPassword = false,
//     TextInputType? keyboardType,
//   }) {
//     return TextFormField(
//       controller: controller,
//       obscureText: isPassword ? _obscurePassword : false,
//       keyboardType: keyboardType,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, color: Colors.grey.shade600),
//         suffixIcon: isPassword
//             ? IconButton(
//                 icon: Icon(
//                   _obscurePassword ? Icons.visibility : Icons.visibility_off,
//                   color: Colors.grey.shade600,
//                 ),
//                 onPressed: () {
//                   setState(() {
//                     _obscurePassword = !_obscurePassword;
//                   });
//                 },
//               )
//             : null,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//         fillColor: Colors.grey.shade50,
//         filled: true,
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 16,
//         ),
//       ),
//       validator: (value) {
//         if (value?.isEmpty ?? true) {
//           return 'This field is required';
//         }
//         if (!isPassword && !value!.contains('@')) {
//           return 'Please enter a valid email';
//         }
//         return null;
//       },
//     );
//   }

//   Future<void> _signIn() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     try {
//       await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text,
//       );
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Login failed: ${e.toString()}'),
//             backgroundColor: Colors.red,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   Future<void> _createDemoAccount() async {
//     setState(() => _isLoading = true);

//     try {
//       final timestamp = DateTime.now().millisecondsSinceEpoch;
//       final demoEmail = 'demo$timestamp@erpsuite.com';

//       final credential = await FirebaseAuth.instance
//           .createUserWithEmailAndPassword(
//             email: demoEmail,
//             password: 'demo123456',
//           );

//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(credential.user!.uid)
//           .set({
//             'name': 'Demo User',
//             'email': demoEmail,
//             'role': 'admin',
//             'createdAt': FieldValue.serverTimestamp(),
//           });

//       if (mounted) {
//         Navigator.of(
//           context,
//         ).pushReplacement(MaterialPageRoute(builder: (_) => DashboardScreen()));
//       }
//     } catch (e) {
//       print('Demo account creation failed: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Demo account creation failed: ${e.toString()}'),
//             backgroundColor: Colors.red,
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
// }

// class DashboardScreen extends StatefulWidget {
//   @override
//   _DashboardScreenState createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   int _selectedIndex = 0;

//   final List<Widget> _screens = [
//     DashboardContent(),
//     InventoryScreen(),
//     SalesScreen(),
//     CustomersScreen(),
//     ReportsScreen(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Row(
//         children: [
//           NavigationRail(
//             extended: MediaQuery.of(context).size.width > 800,
//             backgroundColor: Colors.grey.shade50,
//             selectedIndex: _selectedIndex,
//             onDestinationSelected: (index) {
//               setState(() => _selectedIndex = index);
//             },
//             leading: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Container(
//                 width: 48,
//                 height: 48,
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
//                   ),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(
//                   Icons.business,
//                   color: Colors.white,
//                   size: 24,
//                 ),
//               ),
//             ),
//             trailing: IconButton(
//               icon: const Icon(Icons.logout),
//               onPressed: () async {
//                 try {
//                   // Check if Firebase is initialized
//                   Firebase.app();
//                   await FirebaseAuth.instance.signOut();
//                 } catch (e) {
//                   // Firebase not available, just navigate back
//                   Navigator.of(context).pushReplacement(
//                     MaterialPageRoute(builder: (_) => DemoModeScreen()),
//                   );
//                 }
//               },
//             ),
//             destinations: const [
//               NavigationRailDestination(
//                 icon: Icon(Icons.dashboard_outlined),
//                 selectedIcon: Icon(Icons.dashboard),
//                 label: Text('Dashboard'),
//               ),
//               NavigationRailDestination(
//                 icon: Icon(Icons.inventory_outlined),
//                 selectedIcon: Icon(Icons.inventory),
//                 label: Text('Inventory'),
//               ),
//               NavigationRailDestination(
//                 icon: Icon(Icons.point_of_sale_outlined),
//                 selectedIcon: Icon(Icons.point_of_sale),
//                 label: Text('Sales'),
//               ),
//               NavigationRailDestination(
//                 icon: Icon(Icons.people_outline),
//                 selectedIcon: Icon(Icons.people),
//                 label: Text('Customers'),
//               ),
//               NavigationRailDestination(
//                 icon: Icon(Icons.analytics_outlined),
//                 selectedIcon: Icon(Icons.analytics),
//                 label: Text('Reports'),
//               ),
//             ],
//           ),
//           const VerticalDivider(thickness: 1, width: 1),
//           Expanded(child: _screens[_selectedIndex]),
//         ],
//       ),
//     );
//   }
// }

// // // class DashboardContent extends StatelessWidget {
// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     backgroundColor: Colors.grey.shade50,
//     appBar: AppBar(
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       title: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Good morning! 👋',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey.shade600,
//               fontWeight: FontWeight.normal,
//             ),
//           ),
//           const Text(
//             'Dashboard Overview',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//             ),
//           ),
//         ],
//       ),
//       automaticallyImplyLeading: false,
//     ),
//     body: SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           LayoutBuilder(
//             builder: (context, constraints) {
//               int crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;
//               return GridView.count(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 crossAxisCount: crossAxisCount,
//                 crossAxisSpacing: 16,
//                 mainAxisSpacing: 16,
//                 childAspectRatio: 1.2,
//                 children: [
//                   _buildStatsCard(
//                     'Total Revenue',
//                     '\$124,350',
//                     '+12.5%',
//                     Icons.trending_up,
//                     const Color(0xFF10B981),
//                   ),
//                   _buildStatsCard(
//                     'Orders',
//                     '1,247',
//                     '+8.2%',
//                     Icons.shopping_bag,
//                     const Color(0xFF3B82F6),
//                   ),
//                   _buildStatsCard(
//                     'Products',
//                     '856',
//                     '+3.1%',
//                     Icons.inventory_2,
//                     const Color(0xFF8B5CF6),
//                   ),
//                   _buildStatsCard(
//                     'Customers',
//                     '2,834',
//                     '+15.3%',
//                     Icons.people,
//                     const Color(0xFFF59E0B),
//                   ),
//                 ],
//               );
//             },
//           ),
//           const SizedBox(height: 32),
//           LayoutBuilder(
//             builder: (context, constraints) {
//               if (constraints.maxWidth > 800) {
//                 return Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(flex: 2, child: _buildRevenueChart()),
//                     const SizedBox(width: 16),
//                     Expanded(child: _buildTopProducts()),
//                   ],
//                 );
//               } else {
//                 return Column(
//                   children: [
//                     _buildRevenueChart(),
//                     const SizedBox(height: 16),
//                     _buildTopProducts(),
//                   ],
//                 );
//               }
//             },
//           ),
//         ],
//       ),
//     ),
//   );
// }

// Widget _buildStatsCard(
//   String title,
//   String value,
//   String change,
//   IconData icon,
//   Color color,
// ) {
//   return Card(
//     child: Padding(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(icon, color: color, size: 20),
//               ),
//               const Spacer(),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: Colors.green.shade50,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   change,
//                   style: TextStyle(
//                     color: Colors.green.shade600,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Text(
//             value,
//             style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//           ),
//           Text(
//             title,
//             style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
//           ),
//         ],
//       ),
//     ),
//   );
// }

// Widget _buildRevenueChart() {
//   return Card(
//     child: Padding(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Revenue Trend',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 20),
//           SizedBox(
//             height: 200,
//             child: LineChart(
//               LineChartData(
//                 gridData: FlGridData(show: false),
//                 titlesData: FlTitlesData(show: false),
//                 borderData: FlBorderData(show: false),
//                 lineBarsData: [
//                   LineChartBarData(
//                     spots: [
//                       const FlSpot(0, 3),
//                       const FlSpot(1, 4),
//                       const FlSpot(2, 3.5),
//                       const FlSpot(3, 5),
//                       const FlSpot(4, 4),
//                       const FlSpot(5, 6),
//                     ],
//                     isCurved: true,
//                     gradient: const LinearGradient(
//                       colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
//                     ),
//                     barWidth: 3,
//                     dotData: FlDotData(show: false),
//                     belowBarData: BarAreaData(
//                       show: true,
//                       gradient: LinearGradient(
//                         colors: [
//                           const Color(0xFF6366F1).withOpacity(0.3),
//                           const Color(0xFF8B5CF6).withOpacity(0.1),
//                         ],
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }

// //   Widget _buildTopProducts() {
// //     return Card(
// //       child: Padding(
// //         padding: const EdgeInsets.all(20),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             const Text(
// //               'Top Products',
// //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //             ),
// //             const SizedBox(height: 16),
//             ...List.generate(5, (index) {
//               final products = [
//                 'iPhone 14',
//                 'MacBook Pro',
//                 'AirPods',
//                 'iPad Air',
//                 'Apple Watch',
//               ];
//               final values = [120, 95, 87, 76, 64];
//               return Padding(
//                 padding: const EdgeInsets.only(bottom: 12),
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 8,
//                       height: 8,
//                       decoration: BoxDecoration(
//                         color: Color.lerp(
//                           const Color(0xFF6366F1),
//                           const Color(0xFFEC4899),
//                           index / 4,
//                         ),
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(child: Text(products[index])),
//                     Text(
//                       '${values[index]}',
//                       style: const TextStyle(fontWeight: FontWeight.w600),
//                     ),
//                   ],
//                 ),
//               );
//             }),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // // Placeholder screens for other modules
// // class InventoryScreen extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.grey.shade50,
// //       appBar: AppBar(
// //         backgroundColor: Colors.transparent,
// //         elevation: 0,
// //         title: const Text(
// //           'Inventory Management',
// //           style: TextStyle(color: Colors.black),
// //         ),
// //         automaticallyImplyLeading: false,
// //       ),
// //       body: const Center(child: Text('Inventory Screen - Coming Soon')),
// //     );
// //   }
// // }

// // // class SalesScreen extends StatelessWidget {
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       backgroundColor: Colors.grey.shade50,
// // //       appBar: AppBar(
// // //         backgroundColor: Colors.transparent,
// // //         elevation: 0,
// // //         title: const Text(
// // //           'Sales Management',
// // //           style: TextStyle(color: Colors.black),
// // //         ),
// // //         automaticallyImplyLeading: false,
// // //       ),
// // //       body: const Center(child: Text('Sales Screen - Coming Soon')),
// // //     );
// // //   }
// // // }

// // // class CustomersScreen extends StatelessWidget {
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       backgroundColor: Colors.grey.shade50,
// // //       appBar: AppBar(
// // //         backgroundColor: Colors.transparent,
// //         elevation: 0,
// //         title: const Text(
// //           'Customer Management',
// //           style: TextStyle(color: Colors.black),
// //         ),
// //         automaticallyImplyLeading: false,
// //       ),
// //       body: const Center(child: Text('Customers Screen - Coming Soon')),
// //     );
// //   }
// // }

// class ReportsScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: const Text(
//           'Reports & Analytics',
//           style: TextStyle(color: Colors.black),
//         ),
//         automaticallyImplyLeading: false,
//       ),
//       body: const Center(child: Text('Reports Screen - Coming Soon')),
//     );
//   }
// }
