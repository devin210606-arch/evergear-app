import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class WalletHeader extends StatefulWidget {
  final String username;
  final VoidCallback? onAvatarTap;

  const WalletHeader({
    super.key,
    required this.username,
    this.onAvatarTap,
  });

  @override
  State<WalletHeader> createState() => _WalletHeaderState();
}

class _WalletHeaderState extends State<WalletHeader> {
  int _balance = 0;

  @override
  void initState() {
    super.initState();
    ApiService.getWalletBalance();
  }

  Future<void> _loadBalance() async {
    final result = await ApiService.getWalletBalance();
    if (result['success'] && mounted) {
      setState(() => _balance = result['data']['balance'] ?? 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onAvatarTap,
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
            child: Text('Hello, ${widget.username}',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppTheme.textPrimary)),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/wallet')
                .then((_) => _loadBalance()),
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
                              
                      ValueListenableBuilder<int>(
                        valueListenable: ApiService.currentWalletBalance,
                        builder: (context, balance, child) {
                          return Text(
                            ApiService.formatPrice(balance),
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary),
                          );
                        },
                      ),
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
}