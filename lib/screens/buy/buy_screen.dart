import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/product_card.dart';
import '../home/main_shell.dart';
import '../home/product_detail_screen.dart';

class BuyScreen extends StatefulWidget {
  final int initialCategory;
  const BuyScreen({super.key, this.initialCategory = -1});

  @override
  State<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen> {
  final _searchCtrl = TextEditingController();
  int _selectedCategory = -1;

  final List<Map<String, dynamic>> _allProducts = [
    {'name': 'Iphone 17 Camera', 'price': 'Rp. 200.000', 'rating': 3.9, 'icon': Icons.camera_alt, 'category': 2},
    {'name': 'Google Pixel 7 Camera', 'price': 'Rp. 120.000', 'rating': 5.0, 'icon': Icons.camera, 'category': 2},
    {'name': 'Samsung LCD A54', 'price': 'Rp. 95.000', 'rating': 4.2, 'icon': Icons.phone_android, 'category': 0},
    {'name': 'Xiaomi Battery 5000', 'price': 'Rp. 55.000', 'rating': 3.5, 'icon': Icons.battery_full, 'category': 1},
    {'name': 'iPhone Back Cover', 'price': 'Rp. 45.000', 'rating': 4.0, 'icon': Icons.smartphone, 'category': 3},
    {'name': 'Oppo LCD Screen', 'price': 'Rp. 110.000', 'rating': 3.8, 'icon': Icons.phone_android, 'category': 0},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  void didUpdateWidget(BuyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCategory != widget.initialCategory) {
      setState(() => _selectedCategory = widget.initialCategory);
    }
  }

  List<Map<String, dynamic>> get _filteredProducts {
    return _allProducts.where((p) {
      final matchCategory = _selectedCategory == -1 || p['category'] == _selectedCategory;
      final matchSearch = _searchCtrl.text.isEmpty ||
          p['name'].toString().toLowerCase().contains(_searchCtrl.text.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchCtrl,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'search anything',
                        prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text('Popular Categories',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary)),
                    const SizedBox(height: 12),
                    _buildCategories(),
                    const SizedBox(height: 20),

                    Text('Products',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary)),
                    const SizedBox(height: 12),

                    _filteredProducts.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40),
                              child: Text('No products found',
                                  style: GoogleFonts.poppins(
                                      color: AppTheme.textSecondary)),
                            ),
                          )
                        : GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.75,
                            children: _filteredProducts
                                .map((p) => ProductCard(
                                      name: p['name'],
                                      price: p['price'],
                                      rating: p['rating'],
                                      icon: p['icon'],
                                      onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const ProductDetailScreen())),
                                    ))
                                .toList(),
                          ),
                    const SizedBox(height: 20),
                  ],
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
            child: Text('Hello, Buyer 1',
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

  Widget _buildCategories() {
    final cats = [
      ('LCD', Icons.phone_android),
      ('Battery', Icons.battery_full),
      ('Camera', Icons.camera_alt_outlined),
      ('Back Cover', Icons.smartphone),
    ];

    return Row(
      children: List.generate(
        cats.length,
        (i) => Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(
                  () => _selectedCategory = _selectedCategory == i ? -1 : i),
              child: CategoryChip(
                icon: cats[i].$2,
                label: cats[i].$1,
                isSelected: _selectedCategory == i,
              ),
            ),
          ),
        ),
      ),
    );
  }
}