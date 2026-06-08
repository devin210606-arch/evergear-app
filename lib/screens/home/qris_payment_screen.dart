import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';

class QrisPaymentScreen extends StatefulWidget {
  final int listingId;
  final int grandTotal;
  final String productName;

  const QrisPaymentScreen({
    super.key,
    required this.listingId,
    required this.grandTotal,
    required this.productName,
  });

  @override
  State<QrisPaymentScreen> createState() => _QrisPaymentScreenState();
}

class _QrisPaymentScreenState extends State<QrisPaymentScreen> {
  bool _isProcessing = false;

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);
    
    // Panggil API untuk membuat order
    final result = await ApiService.createOrder(
      listingId: widget.listingId,
      paymentMethod: 'QRIS',
    );

    setState(() => _isProcessing = false);

    if (!mounted) return;

    if (result['success']) {
      // Tampilkan pesan sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment Successful!'),
          backgroundColor: AppTheme.success,
        ),
      );
      
      // Tutup halaman QRIS dan kembali ke halaman Home/Detail dengan sinyal 'true'
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Payment Failed'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('QRIS Payment', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text('Scan to Pay', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
              Text(widget.productName, style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textSecondary)),
              const SizedBox(height: 30),
              
              // Kotak Barcode Dummy
              Container(
                width: 250,
                height: 250,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 2),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: const Icon(Icons.qr_code_2, size: 200, color: AppTheme.textPrimary),
              ),
              
              const SizedBox(height: 30),
              Text('Total Amount', style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textSecondary)),
              Text(ApiService.formatPrice(widget.grandTotal), 
                  style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.primary)),
              
              const Spacer(),
              
              // Tombol Konfirmasi Dummy
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isProcessing
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('I Have Paid (Simulate)', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}