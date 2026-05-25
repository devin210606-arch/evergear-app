import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../chat/chat_screen.dart';
import 'payment_screen.dart';
import '../sell/edit_listing_screen.dart';
import '../../models/favorites_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final bool isMine;
  final int listingId;
  final String productName;
  final String price;
  final int priceAmount;
  final String sellerName;
  final String category;
  final String condition;
  final String? description;

  const ProductDetailScreen({
    super.key,
    this.isMine = false,
    this.listingId = 0,
    this.productName = 'Product',
    this.price = 'Rp. 0',
    this.priceAmount = 0,
    this.sellerName = 'Seller',
    this.category = '',
    this.condition = '',
    this.description,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isFavorited = false;

  @override
  void initState() {
    super.initState();
    _isFavorited = FavoritesModel.isFavorited(widget.productName);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Product Detail',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!widget.isMine)
            IconButton(
              icon: Icon(
                _isFavorited ? Icons.favorite : Icons.favorite_border,
                color: _isFavorited ? Colors.red : null,
              ),
              onPressed: () {
                setState(() => _isFavorited = !_isFavorited);
                if (_isFavorited) {
                  FavoritesModel.add({
                    'name': widget.productName,
                    'price': widget.price,
                    'rating': 4.0,
                    'icon': _categoryIcon(widget.category),
                  });
                } else {
                  FavoritesModel.remove(widget.productName);
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Container(
              width: double.infinity,
              height: 280,
              color: Colors.white,
              child: Icon(
                _categoryIcon(widget.category),
                size: 100,
                color: AppTheme.primary,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(widget.productName,
                            style: GoogleFonts.poppins(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      Text(widget.price,
                          style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary)),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Rating + condition
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      Text(' 4.0  •  ',
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: AppTheme.textSecondary)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(widget.condition,
                            style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text('Description',
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(
                    widget.description ?? 'No description provided.',
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.6),
                  ),
                  const SizedBox(height: 16),

                  // Seller info — only show when NOT mine
                  if (!widget.isMine) ...[
                    Text('Seller',
                        style: GoogleFonts.poppins(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0E7FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.person,
                                color: AppTheme.primary, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.sellerName,
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                                Text('Jakarta, Indonesia',
                                    style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: AppTheme.textSecondary)),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ChatScreen())),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              minimumSize: Size.zero,
                            ),
                            child: Text('Chat',
                                style: GoogleFonts.poppins(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // My listing stats — only show when it IS mine
                  if (widget.isMine) ...[
                    Text('Listing Stats',
                        style: GoogleFonts.poppins(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatBox(label: 'Views', value: '124'),
                          _StatBox(label: 'Interested', value: '8'),
                          _StatBox(label: 'Chats', value: '3'),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom bar changes based on isMine
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Color(0x14000000),
                blurRadius: 12,
                offset: Offset(0, -4))
          ],
        ),
        child: widget.isMine
            ? Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showDeleteConfirm(context),
                      icon: const Icon(Icons.delete_outline,
                          color: AppTheme.error, size: 18),
                      label: Text('Delete',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.error)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.error),
                        minimumSize: const Size(0, 48),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const EditListingScreen())),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: Text('Edit Listing',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              )
            : ElevatedButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => PaymentScreen(
                              listingId: widget.listingId,
                              productName: widget.productName,
                              price: widget.price,
                              priceAmount: widget.priceAmount,
                            ))),
                child: Text('Buy Now',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2)),
              ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Listing',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete this listing?',
            style: GoogleFonts.poppins(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: Text('Delete',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary)),
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }
}