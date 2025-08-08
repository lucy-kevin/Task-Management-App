import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ModernReportsScreen extends StatefulWidget {
  const ModernReportsScreen({super.key});

  @override
  State<ModernReportsScreen> createState() => _ModernReportsScreenState();
}

class _ModernReportsScreenState extends State<ModernReportsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutQuart),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> getAllFirebaseData() async {
    try {
      // Fetch all collections in parallel
      final results = await Future.wait([
        FirebaseFirestore.instance.collection('customers').get(),
        FirebaseFirestore.instance.collection('dashboard_stats').get(),
        FirebaseFirestore.instance.collection('orders').get(),
        FirebaseFirestore.instance.collection('products').get(),
        FirebaseFirestore.instance.collection('users').get(),
      ]);

      final customersSnapshot = results[0];
      final dashboardStatsSnapshot = results[1];
      final ordersSnapshot = results[2];
      final productsSnapshot = results[3];
      final usersSnapshot = results[4];

      // Process customers data
      final customers = customersSnapshot.docs
          .map((doc) => doc.data())
          .toList();
      int totalCustomers = customers.length;
      int activeCustomers = customers
          .where((c) => c['status'] == 'active')
          .length;
      int inactiveCustomers = totalCustomers - activeCustomers;
      double customerRevenue = customers.fold(
        0.0,
        (sum, c) => sum + (c['totalSpent'] ?? 0.0),
      );

      // Process orders data
      final orders = ordersSnapshot.docs.map((doc) => doc.data()).toList();
      int totalOrders = orders.length;
      double ordersRevenue = orders.fold(
        0.0,
        (sum, o) => sum + (o['total'] ?? o['amount'] ?? 0.0),
      );

      // Get recent orders (last 30 days)
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      int recentOrders = orders.where((order) {
        final orderDate =
            (order['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        return orderDate.isAfter(thirtyDaysAgo);
      }).length;

      // Process products data
      final products = productsSnapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
      int totalProducts = products.length;
      int lowStockProducts = products
          .where((p) => (p['stock'] ?? 0) <= (p['reorderLevel'] ?? 5))
          .length;

      double totalProductValue = products.fold(
        0.0,
        (sum, p) => sum + ((p['price'] ?? 0.0) * (p['stock'] ?? 0)),
      );

      // Calculate total sales from products
      double productsSalesRevenue = products.fold(
        0.0,
        (sum, p) => sum + ((p['price'] ?? 0.0) * (p['sales'] ?? 0)),
      );

      // Get top selling products
      final topProducts = List<Map<String, dynamic>>.from(products)
        ..sort((a, b) => (b['sales'] ?? 0).compareTo(a['sales'] ?? 0))
        ..take(5).toList();

      // Get products by category
      Map<String, int> productsByCategory = {};
      for (var product in products) {
        String category = product['category'] ?? 'Other';
        productsByCategory[category] = (productsByCategory[category] ?? 0) + 1;
      }

      // Process users data
      final users = usersSnapshot.docs.map((doc) => doc.data()).toList();
      int totalUsers = users.length;

      // Process dashboard stats if available
      Map<String, dynamic> dashboardStats = {};
      if (dashboardStatsSnapshot.docs.isNotEmpty) {
        dashboardStats = dashboardStatsSnapshot.docs.first.data();
      }

      // Calculate total revenue (prioritize orders, fallback to products, then customers)
      double totalRevenue = ordersRevenue > 0
          ? ordersRevenue
          : (productsSalesRevenue > 0 ? productsSalesRevenue : customerRevenue);

      double avgOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0.0;
      double avgCustomerSpend = totalCustomers > 0
          ? totalRevenue / totalCustomers
          : 0.0;

      return {
        // Customer metrics
        'totalCustomers': totalCustomers,
        'activeCustomers': activeCustomers,
        'inactiveCustomers': inactiveCustomers,
        'avgCustomerSpend': avgCustomerSpend,

        // Order metrics
        'totalOrders': totalOrders,
        'recentOrders': recentOrders,
        'avgOrderValue': avgOrderValue,

        // Product metrics
        'totalProducts': totalProducts,
        'lowStockProducts': lowStockProducts,
        'totalProductValue': totalProductValue,
        'topProducts': topProducts,
        'productsByCategory': productsByCategory,

        // Financial metrics
        'totalRevenue': totalRevenue,
        'ordersRevenue': ordersRevenue,
        'productsSalesRevenue': productsSalesRevenue,

        // User metrics
        'totalUsers': totalUsers,

        // Raw data for detailed views
        'customers': customers,
        'orders': orders,
        'products': products,
        'users': users,
        'dashboardStats': dashboardStats,
      };
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0D1117)
          : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context, isDark),
          SliverToBoxAdapter(
            child: FutureBuilder<Map<String, dynamic>>(
              future: getAllFirebaseData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }
                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }

                final data = snapshot.data!;
                _animationController.forward();

                return AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildReportsContent(data, isDark),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
      foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Business Analytics',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.5),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF161B22), const Color(0xFF21262D)]
                  : [Colors.white, const Color(0xFFF1F5F9)],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF30363D).withOpacity(0.5)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.refresh_rounded,
              size: 20,
              color: isDark ? Colors.white70 : const Color(0xFF475569),
            ),
          ),
          onPressed: () {
            setState(() {
              _animationController.reset();
            });
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 400,
      margin: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading comprehensive analytics...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fetching data from all collections',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      height: 300,
      margin: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Unable to load analytics data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.length > 100 ? '${error.substring(0, 100)}...' : error,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsContent(Map<String, dynamic> data, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          _buildHeaderSection(isDark),

          // Main Financial Metrics
          _buildFinancialMetrics(data, isDark),

          const SizedBox(height: 24),

          // Business Overview Grid
          _buildBusinessOverview(data, isDark),

          const SizedBox(height: 24),

          // Product Analytics
          _buildProductAnalytics(data, isDark),

          const SizedBox(height: 24),

          // Top Performing Products
          _buildTopProducts(data, isDark),

          const SizedBox(height: 24),

          // Insights and Recommendations
          _buildInsightsSection(data, isDark),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Complete Business Dashboard',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Real-time insights across all your business data',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white60 : const Color(0xFF64748B),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialMetrics(Map<String, dynamic> data, bool isDark) {
    return Column(
      children: [
        // Primary Revenue Card
        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF10B981), Color(0xFF059669), Color(0xFF047857)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Total Revenue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '\$${data['totalRevenue'].toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'From ${data['totalOrders']} orders across all channels',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Secondary Financial Metrics
        Row(
          children: [
            Expanded(
              child: _buildFinancialCard(
                'Avg Order Value',
                '\$${data['avgOrderValue'].toStringAsFixed(2)}',
                Icons.shopping_cart_rounded,
                const Color(0xFF6366F1),
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFinancialCard(
                'Customer LTV',
                '\$${data['avgCustomerSpend'].toStringAsFixed(2)}',
                Icons.person_rounded,
                const Color(0xFF8B5CF6),
                isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinancialCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF21262D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDark
            ? Border.all(color: const Color(0xFF30363D), width: 1)
            : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF0F172A).withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white60 : const Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessOverview(Map<String, dynamic> data, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Business Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 16),

        // First Row
        Row(
          children: [
            Expanded(
              child: _buildOverviewCard(
                'Total Customers',
                data['totalCustomers'].toString(),
                Icons.people_rounded,
                const Color(0xFF6366F1),
                '${data['activeCustomers']} active',
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOverviewCard(
                'Total Orders',
                data['totalOrders'].toString(),
                Icons.receipt_long_rounded,
                const Color(0xFF10B981),
                '${data['recentOrders']} this month',
                isDark,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Second Row
        Row(
          children: [
            Expanded(
              child: _buildOverviewCard(
                'Products',
                data['totalProducts'].toString(),
                Icons.inventory_2_rounded,
                const Color(0xFFF59E0B),
                '${data['lowStockProducts']} low stock',
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOverviewCard(
                'System Users',
                data['totalUsers'].toString(),
                Icons.admin_panel_settings_rounded,
                const Color(0xFF8B5CF6),
                'Total registered',
                isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
    bool isDark,
  ) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF21262D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDark
            ? Border.all(color: const Color(0xFF30363D), width: 1)
            : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF0F172A).withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white70 : const Color(0xFF475569),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: isDark ? Colors.white70 : const Color(0xFF64748B),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductAnalytics(Map<String, dynamic> data, bool isDark) {
    final categories = data['productsByCategory'] as Map<String, int>;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF21262D) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDark
            ? Border.all(color: const Color(0xFF30363D), width: 1)
            : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF0F172A).withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Product Categories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Inventory: \$${data['totalProductValue'].toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (categories.isNotEmpty)
            ...categories.entries
                .map(
                  (entry) => _buildCategoryItem(
                    entry.key,
                    entry.value,
                    categories.values.reduce((a, b) => a + b),
                    isDark,
                  ),
                )
                .toList()
          else
            Text(
              'No product categories found',
              style: TextStyle(
                color: isDark ? Colors.white60 : const Color(0xFF64748B),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    String category,
    int count,
    int total,
    bool isDark,
  ) {
    final percentage = (count / total * 100).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '$count ($percentage%)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? Colors.white60
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: count / total,
                  backgroundColor: isDark
                      ? const Color(0xFF30363D)
                      : const Color(0xFFF1F5F9),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getCategoryColor(category),
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
      const Color(0xFF06B6D4),
    ];
    return colors[category.hashCode % colors.length];
  }

  Widget _buildTopProducts(Map<String, dynamic> data, bool isDark) {
    final topProducts = data['topProducts'] as List<Map<String, dynamic>>;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF21262D) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDark
            ? Border.all(color: const Color(0xFF30363D), width: 1)
            : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF0F172A).withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Performing Products',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),

          if (topProducts.isNotEmpty)
            ...topProducts.asMap().entries.map((entry) {
              final index = entry.key;
              final product = entry.value;
              return _buildProductItem(product, index + 1, isDark);
            }).toList()
          else
            Text(
              'No product sales data available',
              style: TextStyle(
                color: isDark ? Colors.white60 : const Color(0xFF64748B),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductItem(
    Map<String, dynamic> product,
    int rank,
    bool isDark,
  ) {
    final revenue = (product['price'] ?? 0.0) * (product['sales'] ?? 0);
    final stockStatus =
        (product['stock'] ?? 0) <= (product['reorderLevel'] ?? 5)
        ? 'Low Stock'
        : 'In Stock';
    final isLowStock =
        (product['stock'] ?? 0) <= (product['reorderLevel'] ?? 5);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: rank <= 3
                    ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                    : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? 'Unknown Product',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '${product['sales'] ?? 0} sold',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white60
                            : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isLowStock
                            ? Colors.red.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        stockStatus,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isLowStock ? Colors.red : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\${revenue.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              Text(
                '${(product['price'] ?? 0.0).toStringAsFixed(2)} each',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection(Map<String, dynamic> data, bool isDark) {
    final activeRate = data['totalCustomers'] > 0
        ? (data['activeCustomers'] / data['totalCustomers'] * 100)
        : 0.0;

    final lowStockRate = data['totalProducts'] > 0
        ? (data['lowStockProducts'] / data['totalProducts'] * 100)
        : 0.0;

    final conversionRate = data['totalCustomers'] > 0
        ? (data['totalOrders'] / data['totalCustomers'] * 100)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF21262D), const Color(0xFF161B22)]
              : [Colors.white, const Color(0xFFF8FAFC)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: isDark
            ? Border.all(color: const Color(0xFF30363D), width: 1)
            : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF0F172A).withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Business Insights & Recommendations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Customer Engagement Insight
          _buildInsightItem(
            'Customer Engagement',
            '${activeRate.toStringAsFixed(1)}% of customers are active',
            _getInsightRecommendation('customer', activeRate),
            Icons.people_rounded,
            activeRate >= 70
                ? const Color(0xFF10B981)
                : activeRate >= 50
                ? const Color(0xFFF59E0B)
                : const Color(0xFFEF4444),
            isDark,
          ),

          const SizedBox(height: 16),

          // Inventory Management Insight
          _buildInsightItem(
            'Inventory Management',
            '${lowStockRate.toStringAsFixed(1)}% of products are low in stock',
            _getInsightRecommendation('inventory', lowStockRate),
            Icons.inventory_rounded,
            lowStockRate <= 10
                ? const Color(0xFF10B981)
                : lowStockRate <= 20
                ? const Color(0xFFF59E0B)
                : const Color(0xFFEF4444),
            isDark,
          ),

          const SizedBox(height: 16),

          // Sales Performance Insight
          _buildInsightItem(
            'Sales Conversion',
            '${conversionRate.toStringAsFixed(1)}% customer-to-order conversion rate',
            _getInsightRecommendation('conversion', conversionRate),
            Icons.trending_up_rounded,
            conversionRate >= 30
                ? const Color(0xFF10B981)
                : conversionRate >= 15
                ? const Color(0xFFF59E0B)
                : const Color(0xFFEF4444),
            isDark,
          ),

          const SizedBox(height: 16),

          // Revenue Insight
          _buildInsightItem(
            'Revenue Performance',
            data['totalRevenue'] > 50000
                ? 'Strong revenue performance across all channels'
                : data['totalRevenue'] > 10000
                ? 'Moderate revenue with growth opportunities'
                : 'Focus needed on revenue generation strategies',
            data['totalRevenue'] > 50000
                ? 'Consider expanding into new markets or product lines'
                : data['totalRevenue'] > 10000
                ? 'Optimize pricing strategy and focus on high-value customers'
                : 'Implement aggressive marketing and customer acquisition campaigns',
            Icons.account_balance_wallet_rounded,
            data['totalRevenue'] > 50000
                ? const Color(0xFF10B981)
                : data['totalRevenue'] > 10000
                ? const Color(0xFFF59E0B)
                : const Color(0xFFEF4444),
            isDark,
          ),
        ],
      ),
    );
  }

  String _getInsightRecommendation(String type, double value) {
    switch (type) {
      case 'customer':
        if (value >= 70)
          return 'Excellent engagement! Focus on retention strategies';
        if (value >= 50)
          return 'Good engagement. Consider re-engagement campaigns for inactive users';
        return 'Low engagement. Implement targeted activation campaigns';

      case 'inventory':
        if (value <= 10) return 'Well-managed inventory levels';
        if (value <= 20)
          return 'Monitor stock levels closely and consider restocking';
        return 'Critical: Immediate restocking required for multiple products';

      case 'conversion':
        if (value >= 30)
          return 'Excellent conversion rate! Maintain current strategies';
        if (value >= 15)
          return 'Good conversion. Optimize checkout process and customer journey';
        return 'Low conversion. Review pricing, UX, and customer acquisition funnel';

      default:
        return 'Continue monitoring this metric';
    }
  }

  Widget _buildInsightItem(
    String title,
    String description,
    String recommendation,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    recommendation,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Dashboard statistics model (keeping the existing one)
class DashboardStats {
  final double totalRevenue;
  final int totalOrders;
  final int totalProducts;
  final int totalCustomers;
  final double revenueChange;
  final double ordersChange;
  final double productsChange;
  final double customersChange;
  final int lowStockProducts;

  DashboardStats({
    this.totalRevenue = 0.0,
    this.totalOrders = 0,
    this.totalProducts = 0,
    this.totalCustomers = 0,
    this.revenueChange = 0.0,
    this.ordersChange = 0.0,
    this.productsChange = 0.0,
    this.customersChange = 0.0,
    this.lowStockProducts = 0,
  });
}

// Firebase Service class placeholder (use your existing DashboardFirebaseService)
class DashboardFirebaseService {
  static Future<void> initializeDemoData() async {
    // Your existing implementation
  }

  static Future<void> clearAllData() async {
    // Your existing implementation
  }

  static Future<Map<String, dynamic>> exportData() async {
    // Your existing implementation
    return {};
  }
}
