import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../home/home_screen.dart';
import '../buy/buy_screen.dart'; // Ensure this file contains the BuyScreen class
import '../sell/sell_screen.dart';
import '../account/account_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  static _MainShellState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MainShellState>();

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  int _buyCategory = -1;
  
  // 🟢 The Walkie-Talkie Keys!
  // Every time we change these keys, the specific screen is forced to completely refresh.
  Key _homeKey = UniqueKey();
  Key _buyKey = UniqueKey();
  Key _sellKey = UniqueKey();

  void switchTab(int index, {int? category}) {
    setState(() {
      _currentIndex = index;
      if (category != null) _buyCategory = category;
      if (category == null && index == 1) _buyCategory = -1;
      
      // 🟢 Force the tapped screen to refresh instantly
      if (index == 0) _homeKey = UniqueKey();
      if (index == 1) _buyKey = UniqueKey();
      if (index == 2) _sellKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(key: _homeKey), // 🟢 Pass the key here
          BuyScreen(key: _buyKey, initialCategory: _buyCategory), // 🟢 And here
          SellScreen(key: _sellKey), // 🟢 And here
          const AccountScreen(),
        ],
      ),
      bottomNavigationBar: _EverGearNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => switchTab(i),
      ),
    );
  }
}

class _EverGearNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _EverGearNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
      _NavItem(icon: Icons.shopping_cart_outlined, activeIcon: Icons.shopping_cart, label: 'Buy'),
      _NavItem(icon: Icons.sell_outlined, activeIcon: Icons.sell, label: 'Sell'),
      _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'My Account'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isActive = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 32,
                        decoration: isActive
                            ? BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              )
                            : null,
                        child: Icon(
                          isActive ? item.activeIcon : item.icon,
                          color: isActive
                              ? AppTheme.primary
                              : const Color(0xFF9CA3AF),
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w400,
                          color: isActive
                              ? AppTheme.primary
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(
      {required this.icon, required this.activeIcon, required this.label});
}