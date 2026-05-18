import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/product_card.dart';

class BuyScreen extends StatefulWidget {
  const BuyScreen({super.key});

  @override
  State<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen> {
  final _searchCtrl = TextEditingController();

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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search bar
                    TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'search anything',
                        prefixIcon: const Icon(Icons.search,
                            color: AppTheme.textSecondary),
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
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Popular Categories
                    Text(
                      'Popular Categories',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildCategories(),
                    const SizedBox(height: 20),

                    // Product grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.75,
                      children: const [
                        ProductCard(
                          name: 'Iphone 17 Camera',
                          price: 'Rp. 200.000',
                          rating: 3.9,
                          icon: Icons.camera_alt,
                        ),
                        ProductCard(
                          name: 'Google Pixel 7 Camera',
                          price: 'Rp. 120.000',
                          rating: 5.0,
                          icon: Icons.camera,
                        ),
                        ProductCard(
                          name: 'Samsung LCD A54',
                          price: 'Rp. 95.000',
                          rating: 4.2,
                          icon: Icons.phone_android,
                        ),
                        ProductCard(
                          name: 'Xiaomi Battery 5000',
                          price: 'Rp. 55.000',
                          rating: 3.5,
                          icon: Icons.battery_full,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E7FF),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.person, color: AppTheme.primary, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Hello, Buyer 1',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Container(
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
      children: cats
          .map((c) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CategoryChip(icon: c.$2, label: c.$1),
                ),
              ))
          .toList(),
    );
  }
}
