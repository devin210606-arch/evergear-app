import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/product_card.dart';
import '../../services/api_service.dart';
import '../home/product_detail_screen.dart';
import '../../widgets/wallet_header.dart';
import 'main_shell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategory = -1;
  List<Map<String, dynamic>> _popularProducts = [];
  bool _isLoadingProducts = false;
  int _partsSold = 0;
  int _partsBought = 0;
  double _co2Reduced = 0.0;
  int _savedFromLandfill = 0;
  String _username = 'User';
  Key _walletKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _walletKey = UniqueKey(); // Refresh wallet UI too
    });
    await Future.wait([
      _loadUsername(),
      _loadPopularProducts(),
      _loadEcoStats(),
    ]);
  }

  Future<void> _loadEcoStats() async {
    final result = await ApiService.getEcoStats();
    if (result['success']) {
      setState(() {
        _partsSold = result['data']['parts_sold'] ?? 0;
        _partsBought = result['data']['parts_bought'] ?? 0;
        _co2Reduced = (result['data']['co2_reduced_percent'] ?? 0).toDouble();
        _savedFromLandfill = result['data']['parts_saved_from_landfill'] ?? 0;
      });
    }
  }

  Future<void> _loadPopularProducts() async {
    setState(() => _isLoadingProducts = true);
    final result = await ApiService.getListings();
    if (result['success']) {
      setState(() {
        _popularProducts = List<Map<String, dynamic>>.from(result['data']);
      });
    }
    setState(() => _isLoadingProducts = false);
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

  Future<void> _loadUsername() async {
    final result = await ApiService.getProfile();
    if (result['success']) {
      setState(() => _username = result['data']['name'] ?? 'User');
    }
  }

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
        // 🟢 RefreshIndicator untuk Pull-to-Refresh
        child: RefreshIndicator(
          onRefresh: _loadAllData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return WalletHeader(
      key: _walletKey,
      username: _username,
      onAvatarTap: () => MainShell.of(context)?.switchTab(3),
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
              Text("You've saved $_savedFromLandfill parts from landfill",
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
             _EcoStat(label: 'Parts Sold', value: '$_partsSold'),
             _EcoStat(label: 'Parts bought', value: '$_partsBought'),
             _EcoStat(label: 'CO2 Reduced', value: '${_co2Reduced.toStringAsFixed(1)}%', valueColor: AppTheme.success),
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
    if (_isLoadingProducts) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_popularProducts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('No products yet',
              style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.75,
      children: _popularProducts.take(6).map((p) => ProductCard(
        name: p['title'] ?? '',
        price: ApiService.formatPrice(p['price']),
        ecoValue: '${(((p['price'] ?? 0) / 100000) * 0.2).clamp(0.1, 25.0).toStringAsFixed(1)}% CO2',
        icon: _categoryIcon(p['category'] ?? ''),
        imageUrl: p['photo'],
        onTap: () async {
          // 🟢 Tangkap sinyal penghapusan barang
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(
                listingId: p['id'],
                productName: p['title'],
                price: ApiService.formatPrice(p['price']),
                priceAmount: p['price'],
                sellerName: p['seller_name'] ?? '',
                sellerRating: (p['seller_rating'] ?? 0.0).toDouble(),
                category: p['category'] ?? '',
                condition: p['condition'] ?? '',
                description: p['description'],
                imageUrl: p['photo']
              ),
            ),
          );

          // Kalau hasil 'true' (dihapus/berubah), refresh data otomatis
          if (result == true) {
            setState(() {
              _popularProducts.removeWhere((item) => item['id'] == p['id']);
            });
            // Update skor CO2 di background secara diam-diam
            _loadEcoStats(); 
          }
        },
      )).toList(),
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