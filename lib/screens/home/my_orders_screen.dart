import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // Emptied the placeholders since the API will load the real parts data
  List<Map<String, dynamic>> _buyerOrders = [];
  List<Map<String, dynamic>> _sellerOrders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    
    // Load Buyer Orders
    final buyerResult = await ApiService.getMyOrders();
    if (buyerResult['success']) {
      setState(() {
        _buyerOrders = (buyerResult['data'] as List).map((o) => {
          'id': o['id'],
          'product': o['product'],
          'price': ApiService.formatPrice(o['price']),
          'status': o['status'],
          'date': 'Recent',
          'icon': Icons.devices,
        }).toList();
      });
    }
    
    // Load Seller Orders
    final sellerResult = await ApiService.getMySellingOrders();
    if (sellerResult['success']) {
      setState(() {
        _sellerOrders = (sellerResult['data'] as List).map((o) => {
          'id': o['id'],
          'product': o['product'],
          'price': ApiService.formatPrice(o['price']),
          'status': o['status'],
          'date': 'Recent',
          'icon': Icons.devices,
          'buyer': o['buyer_name'],
        }).toList();
      });
    }
    
    setState(() => _isLoading = false);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed': return AppTheme.success;
      case 'in_progress': return AppTheme.warning;
      case 'shipped': return AppTheme.primary;
      case 'cancelled': return AppTheme.error;
      default: return AppTheme.textSecondary;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'completed': return 'Completed';
      case 'in_progress': return 'In Progress';
      case 'shipped': return 'Shipped';
      case 'cancelled': return 'Cancelled';
      default: return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('My Orders',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13),
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
          tabs: const [
            Tab(text: 'My Purchases'),
            Tab(text: 'My Sales'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersList(_buyerOrders, isBuyer: true),
                _buildSellerOrders(),
              ],
            ),
    );
  }

  Widget _buildSellerOrders() {
    return _buildOrdersList(_sellerOrders, isBuyer: false);
  }

  Widget _buildOrdersList(List<Map<String, dynamic>> orders,
      {required bool isBuyer}) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isBuyer ? Icons.shopping_bag_outlined : Icons.sell_outlined,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              isBuyer ? 'No purchases yet' : 'No sales yet',
              style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              isBuyer ? 'Start buying parts!' : 'List a part to start selling!',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final order = orders[i];
        final statusColor = _statusColor(order['status'] as String);
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Order #${order['id']}',
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: AppTheme.textSecondary)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _statusLabel(order['status'] as String),
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: statusColor,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Product info
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(order['icon'] as IconData,
                        color: AppTheme.primary, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order['product'] as String,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        // Inject the buyer name dynamically if it's the seller view
                        if (!isBuyer && order['buyer'] != null)
                          Text('Buyer: ${order['buyer']}',
                              style: GoogleFonts.poppins(
                                  fontSize: 11, color: AppTheme.textSecondary)),
                        Text(order['date'] as String,
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                  Text(order['price'] as String,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppTheme.primary)),
                ],
              ),
              
              // Action buttons consolidated for both Buyers and Sellers
              if (isBuyer) ...[
                if (order['status'] == 'shipped') ...[
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await ApiService.confirmReceived(order['id']);
                      if (result['success']) {
                        setState(() => order['status'] = 'completed');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 40),
                    ),
                    child: Text('Confirm Received',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),
                ],
              ] else ...[
                if (order['status'] == 'pending') ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final result = await ApiService.updateOrderStatus(
                                orderId: order['id'], status: 'cancelled');
                            if (result['success']) {
                              setState(() => order['status'] = 'cancelled');
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.error,
                            side: const BorderSide(color: AppTheme.error),
                            minimumSize: const Size(0, 40),
                          ),
                          child: Text('Decline',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final result = await ApiService.updateOrderStatus(
                                orderId: order['id'], status: 'in_progress');
                            if (result['success']) {
                              setState(() => order['status'] = 'in_progress');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 40),
                          ),
                          child: Text('Accept',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ],
                if (order['status'] == 'in_progress') ...[
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await ApiService.updateOrderStatus(
                          orderId: order['id'], status: 'shipped');
                      if (result['success']) {
                        setState(() => order['status'] = 'shipped');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 40),
                    ),
                    child: Text('Mark as Shipped',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}