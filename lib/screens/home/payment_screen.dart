import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';

class PaymentScreen extends StatefulWidget {
  final int listingId;
  final String productName;
  final String price;
  final int priceAmount;

  const PaymentScreen({
    super.key,
    this.listingId = 0,
    this.productName = 'Iphone 17 Camera',
    this.price = 'Rp. 200.000',
    this.priceAmount = 200000,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedMethod = 0;
  bool _isLoading = false;
  
  // VARIABLE FOR REAL WALLET BALANCE
  String _walletBalance = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadWalletBalance();
  }

  // FETCH REAL BALANCE FROM BACKEND
  Future<void> _loadWalletBalance() async {
    final result = await ApiService.getWalletBalance();
    if (result['success']) {
      setState(() {
        final balanceAmount = result['data']['balance'] ?? 0; 
        _walletBalance = ApiService.formatPrice(balanceAmount);
      });
    } else {
      setState(() => _walletBalance = "Rp. 0");
    }
  }

  Future<void> _pay() async {
    setState(() => _isLoading = true);

    // Send the correct method string to the API
    final List<Map<String, dynamic>> methodsForApi = [
      {'value': 'wallet'},
      {'value': 'bank_transfer'},
      {'value': 'card'},
    ];

    final result = await ApiService.createOrder(
      listingId: widget.listingId,
      paymentMethod: methodsForApi[_selectedMethod]['value'],
    );

    setState(() => _isLoading = false);

    if (result['success'] || widget.listingId == 0) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'], style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    // TAX AND FEE MATH LOGIC
    final platformFee = (widget.priceAmount * 0.01).round();
    final taxAmount = (widget.priceAmount * 0.10).round(); // 10% Tax matching your backend!
    final total = widget.priceAmount + platformFee + taxAmount;

    // PAYMENT METHODS LIST (Inside build so it updates the balance string)
    final List<Map<String, dynamic>> _methods = [
      {
        'label': 'EverGear Wallet',
        'subtitle': 'Balance: $_walletBalance', // Reads the real balance!
        'icon': Icons.account_balance_wallet_outlined,
        'value': 'wallet',
      },
      {
        'label': 'Bank Transfer',
        'subtitle': 'BCA, Mandiri, BNI, BRI',
        'icon': Icons.account_balance_outlined,
        'value': 'bank_transfer',
      },
      {
        'label': 'Credit / Debit Card',
        'subtitle': 'Visa, Mastercard',
        'icon': Icons.credit_card_outlined,
        'value': 'card',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Payment', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order summary
                  Text('Order Summary',
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.camera_alt, color: AppTheme.primary, size: 30),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.productName,
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                              Text('Refurbished',
                                  style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textSecondary)),
                            ],
                          ),
                        ),
                        Text(widget.price,
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.primary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Payment method
                  Text('Payment Method',
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  ...List.generate(_methods.length, (i) {
                    final m = _methods[i];
                    final isSelected = _selectedMethod == i;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMethod = i),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppTheme.primary : const Color(0xFFE5E7EB),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primary.withOpacity(0.1)
                                    : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(m['icon'] as IconData,
                                  color: isSelected ? AppTheme.primary : AppTheme.textSecondary, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(m['label'],
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                                  Text(m['subtitle'],
                                      style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textSecondary)),
                                ],
                              ),
                            ),
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),

                  // Price breakdown
                  Text('Price Details',
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _PriceRow(label: 'Item Price', value: widget.price),
                        const SizedBox(height: 8),
                        _PriceRow(label: 'Platform Fee (1%)', value: 'Rp. ${ApiService.formatPrice(platformFee).replaceAll('Rp. ', '')}'),
                        const SizedBox(height: 8),
                        
                        // NEW TAX ROW ADDED HERE
                        _PriceRow(label: 'Tax (10%)', value: 'Rp. ${ApiService.formatPrice(taxAmount).replaceAll('Rp. ', '')}'),
                        
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        _PriceRow(
                          label: 'Total',
                          value: 'Rp. ${ApiService.formatPrice(total).replaceAll('Rp. ', '')}',
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Pay button
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, -4))
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : () => _showConfirmationDialog(context),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text('Pay Now',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w700, letterSpacing: 1.2)),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Confirm Payment',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to proceed with the payment for ${widget.productName}?',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx), 
              child: Text(
                'Cancel', 
                style: GoogleFonts.poppins(color: AppTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx); 
                _pay();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
              ),
              child: Text(
                'Confirm', 
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(color: AppTheme.success, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              Text('Payment Successful!',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Your order has been placed successfully.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textSecondary)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // The ripple effect fix to make the item vanish
                  Navigator.pop(context); 
                  Navigator.pop(context, true); 
                },
                child: Text('Back to Home', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _PriceRow({required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 13,
                color: isBold ? AppTheme.textPrimary : AppTheme.textSecondary,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w400)),
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: isBold ? AppTheme.primary : AppTheme.textPrimary)),
      ],
    );
  }
}