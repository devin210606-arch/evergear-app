import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/favorites_model.dart';
import '../../widgets/product_card.dart';
import 'product_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    final items = FavoritesModel.items;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('My Favorites',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite_border,
                      size: 64, color: Color(0xFF9CA3AF)),
                  const SizedBox(height: 12),
                  Text('No favorites yet',
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 6),
                  Text('Tap the heart on any product to save it',
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: Color(0xFF6B7280))),
                ],
              ),
            )
          : GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
              children: items
                  .map((item) => ProductCard(
                        name: item['name'] ?? '',
                        price: item['price'] ?? '',
                        
                        // 🟢 Perbaikan logika matematika di sini
                        ecoValue: '${(((item['priceAmount'] ?? 0) / 100000) * 0.2).clamp(0.1, 25.0).toStringAsFixed(1)}% CO2',
                        
                        icon: item['icon'],
                        imageUrl: item['imageUrl'] ?? item['photo'], 
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(
                                listingId: item['id'] ?? 0,
                                productName: item['name'] ?? '',
                                price: item['price'] ?? '',
                                priceAmount: item['priceAmount'] ?? 0,
                                sellerName: item['sellerName'] ?? 'Seller',
                                category: item['category'] ?? '',
                                condition: item['condition'] ?? 'Used',
                                description: item['description'] ?? '',
                                imageUrl: item['imageUrl'] ?? item['photo'],
                              )),
                        ).then((_) => setState(() {})),
                      ))
                  .toList(),
            ),
    );
  }
}