import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/product_card.dart';
import 'main_shell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategory = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedCategory = -1;
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
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildActionBanners(context),
                    const SizedBox(height: 16),
                    _buildEcoBanner(),
                    const SizedBox(height: 20),
                    Text('Popular Categories',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary)),
                    const SizedBox(height: 12),
                    _buildCategories(context),
                    const SizedBox(height: 20),
                    Text('Popular Products',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary)),
                    const SizedBox(height: 12),
                    _buildProductGrid(context),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          // Avatar — taps to My Account
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
          // Wallet — taps to wallet page
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

  Widget _buildActionBanners(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionBanner(
            title: 'Sell\nBroken\nParts',
            color: const Color(0xFF3B82F6),
            icon: Icons.build_outlined,
            onTap: () => MainShell.of(context)?.switchTab(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionBanner(
            title: 'Buy\nRefurbished\nParts',
            color: const Color(0xFF60A5FA),
            icon: Icons.shopping_bag_outlined,
            onTap: () => MainShell.of(context)?.switchTab(1),
          ),
        ),
      ],
    );
  }

  Widget _buildEcoBanner() {
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
          Row(
            children: [
              const Icon(Icons.eco_outlined, color: AppTheme.success, size: 18),
              const SizedBox(width: 6),
              Text("You've saved 120 parts from landfill",
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _EcoStat(label: 'Parts Sold', value: '113'),
              _EcoStat(label: 'Parts bought', value: '7'),
              _EcoStat(label: 'CO2 Reduced', value: '7%', valueColor: AppTheme.success),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
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
              onTap: () {
                setState(() => _selectedCategory = _selectedCategory == i ? -1 : i);
                MainShell.of(context)?.switchTab(1);
              },
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

  Widget _buildProductGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.75,
      children: [
        ProductCard(
          name: 'Iphone 17 Camera',
          price: 'Rp. 200.000',
          rating: 3.9,
          icon: Icons.camera_alt_outlined,
          onTap: () => Navigator.pushNamed(context, '/product-detail'),
        ),
        ProductCard(
          name: 'Google Pixel 7 Camera',
          price: 'Rp. 120.000',
          rating: 5.0,
          icon: Icons.camera_alt_outlined,
          onTap: () => Navigator.pushNamed(context, '/product-detail'),
        ),
        ProductCard(
          name: 'G Pixel 7 Camera ++',
          price: 'Rp. 78.000',
          rating: 2.8,
          icon: Icons.camera_enhance,
          onTap: () => Navigator.pushNamed(context, '/product-detail'),
        ),
        ProductCard(
          name: 'Google P8 Battery',
          price: 'Rp. 420.000',
          rating: 4.0,
          icon: Icons.battery_charging_full,
          onTap: () => Navigator.pushNamed(context, '/product-detail'),
        ),
      ],
    );
  }
}

class _ActionBanner extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionBanner({
    required this.title,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(title,
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.3)),
            ),
            Icon(icon, color: Colors.white.withOpacity(0.8), size: 32),
          ],
        ),
      ),
    );
  }
}

class _EcoStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _EcoStat({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: GoogleFonts.poppins(fontSize: 10, color: AppTheme.textSecondary)),
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: valueColor ?? AppTheme.textPrimary)),
      ],
    );
  }
}