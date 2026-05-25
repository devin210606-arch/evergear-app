import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/category_chip.dart';
import '../home/main_shell.dart';
import '../home/product_detail_screen.dart';
import '../../services/api_service.dart';
import 'list_part_screen.dart';

class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  int _selectedCategory = -1;
  String _username = 'User';
  List<Map<String, dynamic>> _myListings = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _selectedCategory = -1);
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final profileResult = await ApiService.getProfile();
    if (profileResult['success']) {
      setState(() => _username = profileResult['data']['name'] ?? 'User');
    }
    final listingsResult = await ApiService.getMyListings();
    if (listingsResult['success']) {
      setState(() {
        _myListings = List<Map<String, dynamic>>.from(listingsResult['data']);
      });
    }
    setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> get _filteredListings {
    if (_selectedCategory == -1) return _myListings;
    final cats = ['LCD', 'Battery', 'Camera', 'Back Cover'];
    return _myListings
        .where((l) => l['category'] == cats[_selectedCategory])
        .toList();
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'LCD': return Icons.phone_android;
      case 'Battery': return Icons.battery_full;
      case 'Camera': return Icons.camera_alt_outlined;
      case 'Back Cover': return Icons.smartphone;
      default: return Icons.devices;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'sold': return AppTheme.success;
      case 'in_progress': return AppTheme.warning;
      default: return AppTheme.primary;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'sold': return 'Sold';
      case 'in_progress': return 'In Progress';
      default: return 'Available';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Search bar
                            TextField(
                              decoration: InputDecoration(
                                hintText: 'search anything',
                                prefixIcon: const Icon(Icons.search,
                                    color: AppTheme.textSecondary),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFE5E7EB)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFE5E7EB)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                            ),
                            const SizedBox(height: 20),

                            Text('Your Inventory',
                                style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary)),
                            const SizedBox(height: 12),

                            // Categories
                            Row(
                              children: [
                                ('LCD', Icons.phone_android),
                                ('Battery', Icons.battery_full),
                                ('Camera', Icons.camera_alt_outlined),
                                ('Back Cover', Icons.smartphone),
                              ].asMap().entries.map((e) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: GestureDetector(
                                    onTap: () => setState(() =>
                                        _selectedCategory =
                                            _selectedCategory == e.key
                                                ? -1
                                                : e.key),
                                    child: CategoryChip(
                                      icon: e.value.$2,
                                      label: e.value.$1,
                                      isSelected: _selectedCategory == e.key,
                                    ),
                                  ),
                                ),
                              )).toList(),
                            ),
                            const SizedBox(height: 16),

                            // Inventory items
                            if (_filteredListings.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(40),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.inventory_2_outlined,
                                          size: 48,
                                          color: AppTheme.textSecondary),
                                      const SizedBox(height: 12),
                                      Text('No listings yet',
                                          style: GoogleFonts.poppins(
                                              color: AppTheme.textSecondary,
                                              fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 6),
                                      Text('Tap the button below to list a part!',
                                          style: GoogleFonts.poppins(
                                              color: AppTheme.textSecondary,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ..._filteredListings.map((listing) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _InventoryItem(
                                  name: listing['title'] ?? '',
                                  price: ApiService.formatPrice(listing['price']),
                                  status: listing['status'] ?? 'available',
                                  statusColor: _statusColor(listing['status'] ?? 'available'),
                                  statusLabel: _statusLabel(listing['status'] ?? 'available'),
                                  icon: _categoryIcon(listing['category'] ?? ''),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailScreen(
                                        isMine: true,
                                        listingId: listing['id'],
                                        productName: listing['title'],
                                        price: ApiService.formatPrice(listing['price']),
                                        priceAmount: listing['price'],
                                        sellerName: _username,
                                        category: listing['category'] ?? '',
                                        condition: listing['condition'] ?? '',
                                        description: listing['description'],
                                      ),
                                    ),
                                  ).then((_) => _loadData()),
                                ),
                              )),
                            const SizedBox(height: 20),

                            ElevatedButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ListPartScreen()),
                              ).then((_) => _loadData()),
                              icon: const Icon(Icons.add),
                              label: Text('List a New Part',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => MainShell.of(context)?.switchTab(3),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E7FF),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.person, color: AppTheme.primary, size: 26),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text('Hello, $_username',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppTheme.textPrimary)),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/wallet'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.walletBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined,
                      size: 16, color: AppTheme.primary),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Wallet Balance',
                          style: GoogleFonts.poppins(
                              fontSize: 9, color: AppTheme.textSecondary)),
                      Text('Rp. 888.888',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryItem extends StatelessWidget {
  final String name;
  final String price;
  final String status;
  final Color statusColor;
  final String statusLabel;
  final IconData icon;
  final VoidCallback onTap;

  const _InventoryItem({
    required this.name,
    required this.price,
    required this.status,
    required this.statusColor,
    required this.statusLabel,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusLabel,
                          style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: statusColor,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(name,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  Text(price,
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary)),
                ],
              ),
            ),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 32, color: AppTheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}