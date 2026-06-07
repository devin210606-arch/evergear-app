import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String ecoValue;
  final IconData icon;
  final String? imageUrl; // 🟢 1. Tambahkan wadah untuk menampung link gambar
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.ecoValue,
    required this.icon,
    this.imageUrl, // 🟢 2. Masukkan ke constructor (tidak wajib/bisa null)
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                ),
                // 🟢 3. Logika Pintar: Tampilkan Foto atau Ikon
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                        child: Image.network(
                          imageUrl!,
                          width: double.infinity,
                          fit: BoxFit.cover, // Gambar akan dipotong rapi memenuhi kotak
                          errorBuilder: (context, error, stackTrace) {
                            // Kalau link gambarnya rusak, kembali tampilkan ikon
                            return Icon(icon, size: 56, color: AppTheme.primary);
                          },
                        ),
                      )
                    : Icon(icon, size: 56, color: AppTheme.primary),
              ),
            ),

            // Info area
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Teks harga yang sudah anti-overflow
                      Expanded(
                        child: FittedBox(
                          alignment: Alignment.centerLeft,
                          fit: BoxFit.scaleDown,
                          child: Text(
                            price,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      
                      // Bagian Icon Daun & CO2
                      Row(
                        children: [
                          const Icon(Icons.eco, size: 14, color: AppTheme.success),
                          const SizedBox(width: 2),
                          Text(
                            ecoValue,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}