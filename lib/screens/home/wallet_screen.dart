import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int _balance = 0;
  bool _isLoading = false;
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    setState(() => _isLoading = true);
    final balanceResult = await ApiService.getWalletBalance();
    if (balanceResult['success']) {
      setState(() => _balance = balanceResult['data']['balance'] ?? 0);
    }
    final txResult = await ApiService.getTransactions();
    if (txResult['success']) {
      setState(() {
        _transactions = List<Map<String, dynamic>>.from(txResult['data']);
      });
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('My Wallet',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWallet,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadWallet,
              child: Column(
                children: [
                  // Balance card
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primary, Color(0xFF4A9FFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Wallet Balance',
                              style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13)),
                          const SizedBox(height: 8),
                          Text(ApiService.formatPrice(_balance),
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _WalletAction(
                                  icon: Icons.add,
                                  label: 'Top Up',
                                  onTap: () => _showTopUpSheet(context),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _WalletAction(
                                  icon: Icons.arrow_upward,
                                  label: 'Withdraw',
                                  onTap: () => _showWithdrawSheet(context),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Transaction history
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Transaction History',
                          style: GoogleFonts.poppins(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: _transactions.isEmpty
                        ? Center(
                            child: Text('No transactions yet',
                                style: GoogleFonts.poppins(
                                    color: AppTheme.textSecondary)),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _transactions.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, i) {
                              final t = _transactions[i];
                              final isPositive = t['amount']
                                  .toString()
                                  .startsWith('+');
                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: (isPositive
                                                ? AppTheme.success
                                                : AppTheme.error)
                                            .withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isPositive
                                            ? Icons.add_circle_outline
                                            : Icons.remove_circle_outline,
                                        color: isPositive
                                            ? AppTheme.success
                                            : AppTheme.error,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(t['type'] ?? '',
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13)),
                                          Text(t['date'] ?? '',
                                              style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  color:
                                                      AppTheme.textSecondary)),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      t['amount'] ?? '',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: isPositive
                                              ? AppTheme.success
                                              : AppTheme.error),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  void _showTopUpSheet(BuildContext context) {
    final amountCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              16, 20, 16, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Top Up',
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text('Amount',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: AppTheme.textSecondary)),
              const SizedBox(height: 6),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    hintText: 'Enter amount', prefixText: 'Rp. '),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ['50000', '100000', '200000', '500000']
                    .map((a) => GestureDetector(
                          onTap: () => amountCtrl.text = a,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                                'Rp. ${ApiService.formatPrice(int.parse(a)).replaceAll('Rp. ', '')}',
                                style: GoogleFonts.poppins(fontSize: 12)),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final amount = int.tryParse(amountCtrl.text.trim()) ?? 0;
                  if (amount <= 0) return;
                  Navigator.pop(context);
                  final result = await ApiService.topUpWallet(amount);
                  if (result['success']) {
                    _loadWallet();
                  }
                },
                child: Text('Confirm Top Up',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWithdrawSheet(BuildContext context) {
    final amountCtrl = TextEditingController();
    final bankCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 20, 16, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Withdraw',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Bank Account Number',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 6),
            TextField(
              controller: bankCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  hintText: 'Enter bank account number'),
            ),
            const SizedBox(height: 12),
            Text('Amount',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 6),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  hintText: 'Enter amount', prefixText: 'Rp. '),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final amount = int.tryParse(amountCtrl.text.trim()) ?? 0;
                if (amount <= 0 || bankCtrl.text.isEmpty) return;
                Navigator.pop(context);
                final result = await ApiService.withdrawWallet(
                  amount: amount,
                  bankAccount: bankCtrl.text.trim(),
                );
                if (result['success']) {
                  _loadWallet();
                }
              },
              child: Text('Confirm Withdraw',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _WalletAction(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 4),
            Text(label,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}