import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/product_card.dart';
import '../home/main_shell.dart';
import '../home/product_detail_screen.dart';
import '../../services/api_service.dart';
import '../../widgets/wallet_header.dart';

class BuyScreen extends StatefulWidget {
  final int initialCategory;
  const BuyScreen({super.key, this.initialCategory = -1});

  @override
  State<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen> {
  final _searchCtrl = TextEditingController();
  String _username = 'User';
  int _selectedCategory = -1;

  IconData _categoryIcon(String category) {
  switch (category) {
    case 'LCD': return Icons.phone_android;
    case 'Battery': return Icons.battery_full;
    case 'Camera': return Icons.camera_alt_outlined;
    case 'Back Cover': return Icons.smartphone;
    default: return Icons.devices;
  }
}

  List<Map<String, dynamic>> _allProducts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _loadListings();
    _loadUsername();
  }

  Future<void> _loadListings() async {
    setState(() => _isLoading = true);
    final cats = ['LCD', 'Battery', 'Camera', 'Back Cover'];
    final category = _selectedCategory == -1 ? null : cats[_selectedCategory];
    final result = await ApiService.getListings(
      category: category,
      search: _searchCtrl.text.isEmpty ? null : _searchCtrl.text,
    );
    if (result['success']) {
      setState(() {
        _allProducts = List<Map<String, dynamic>>.from(result['data']);
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadUsername() async {
    final result = await ApiService.getProfile();
    if (result['success']) {
      setState(() => _username = result['data']['name'] ?? 'User');
    }
  }

  @override
  void didUpdateWidget(BuyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCategory != widget.initialCategory) {
      setState(() => _selectedCategory = widget.initialCategory);
      _loadListings();
    }
  }

  List<Map<String, dynamic>> get _filteredProducts => _allProducts;

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
                      onChanged: (_) => _loadListings(),
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

                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _filteredProducts.isEmpty
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
                                            name: p['title'] ?? '',
                                            price: ApiService.formatPrice(p['price']),
                                            rating: 4.0,
                                            icon: _categoryIcon(p['category'] ?? ''),
                                            onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) => ProductDetailScreen(
                                                          listingId: p['id'],
                                                          productName: p['title'],
                                                          price: ApiService.formatPrice(p['price']),
                                                          priceAmount: p['price'],
                                                          sellerName: p['seller_name'],
                                                          category: p['category'],
                                                          condition: p['condition'],
                                                          description: p['description'],
                                                        ))),
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
    return WalletHeader(
      username: _username,
      onAvatarTap: () => MainShell.of(context)?.switchTab(3),
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
              onTap: () {
                setState(() => _selectedCategory = _selectedCategory == i ? -1 : i);
                _loadListings();
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
} 