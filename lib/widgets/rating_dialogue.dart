import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class RatingDialog extends StatefulWidget {
  final int sellerId;
  final String sellerName;

  const RatingDialog({
    super.key,
    required this.sellerId,
    required this.sellerName,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _selectedRating = 0;
  bool _isSubmitting = false;

  Future<void> _submitRating() async {
    if (_selectedRating == 0) return; // Jangan kirim kalau belum pilih bintang

    setState(() => _isSubmitting = true);
    final result = await ApiService.rateSeller(
      sellerId: widget.sellerId,
      rating: _selectedRating.toDouble(),
    );
    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for rating!'), backgroundColor: AppTheme.success),
      );
      Navigator.pop(context, true); // Tutup dialog dan kirim sinyal sukses
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to submit')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Rate the Seller',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('How was your experience buying from ${widget.sellerName}?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 24),
            
            // Barisan Bintang
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _selectedRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedRating = index + 1;
                    });
                  },
                );
              }),
            ),
            
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_selectedRating > 0 && !_isSubmitting) ? _submitRating : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Submit Rating', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}