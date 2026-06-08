import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'payment_method_screen.dart';
import 'help_center_screen.dart';
import '../home/favorites_screen.dart'; 
import '../../services/api_service.dart';
import '../home/my_orders_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {

  String _username = 'User';
  String _email = '';
  
  // Added Eco Stat Variables
  int _partsSold = 0;
  int _partsBought = 0;
  double _co2Reduced = 0.0;
  int _savedFromLandfill = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadEcoStats(); // Call it here!
  }

  Future<void> _loadProfile() async {
    final result = await ApiService.getProfile();
    if (result['success']) {
      setState(() {
        _username = result['data']['name'] ?? 'User';
        _email = result['data']['email'] ?? '';
      });
    }
  }

  // Added _loadEcoStats method
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1C1C2E),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 48),
                    ),
                    const SizedBox(height: 12),
                    Text(_username,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: AppTheme.textPrimary)),
                    Text(_email,
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Menu
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    _MenuItem(
                      icon: Icons.edit_outlined,
                      label: 'Edit Profile',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _MenuItem(
                      icon: Icons.shopping_bag_outlined,
                      label: 'My Orders',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const MyOrdersScreen())),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _MenuItem(
                      icon: Icons.favorite_outline,
                      label: 'My Favorites',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const FavoritesScreen())),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _MenuItem(
                      icon: Icons.credit_card_outlined,
                      label: 'Payment Method',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const PaymentMethodScreen())),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _MenuItem(
                      icon: Icons.lock_outline,
                      label: 'Change Password',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _MenuItem(
                      icon: Icons.help_outline,
                      label: 'Help Center',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const HelpCenterScreen())),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Eco stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
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
                          const Icon(Icons.eco_outlined,
                              color: AppTheme.success, size: 18),
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
                ),
              ),
              const SizedBox(height: 16),

              // Logout
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ApiService.clearToken();
                    if (mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                  icon: const Icon(Icons.logout, size: 18),
                  label: Text('Logout',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.error,
                    side: const BorderSide(color: AppTheme.error),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.walletBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 20),
      ),
      title: Text(label,
          style:
              GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right,
          color: AppTheme.textSecondary, size: 20),
      onTap: onTap,
    );
  }
}

class _EcoStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _EcoStat(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 10, color: AppTheme.textSecondary)),
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: valueColor ?? AppTheme.textPrimary)),
      ],
    );
  }
}