import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../home/home_screen.dart';
import '../buy/buy_screen.dart';
import '../sell/sell_screen.dart';
import '../account/account_screen.dart';
import 'package:evergear/screens/chat/chats_list_screen.dart';


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
  int _unreadMessages = 0; 
  
  Key _homeKey = UniqueKey();
  Key _buyKey = UniqueKey();
  Key _sellKey = UniqueKey();
  Key _chatKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _loadUnreadCount(); // 🟢 Sekarang aman untuk dipanggil!
  }

  // 🟢 Fungsi aslimu sudah bisa bekerja sekarang
  Future<void> _loadUnreadCount() async {
    final result = await ApiService.getUnreadMessagesCount(); 
    
    // 🟢 Pasang CCTV di sini!
    print("🕵️ CEK RESPON API UNREAD: $result"); 
    
    if (result['success']) {
      if (mounted) {
        setState(() {
          _unreadMessages = result['data']['count'] ?? 0;
        });
      }
    }
  }

  void switchTab(int index, {int? category}) {
    // 🟢 1. Tanya backend setiap kali user pindah tab!
    _loadUnreadCount(); 

    setState(() {
      _currentIndex = index;
      if (category != null) _buyCategory = category;
      if (category == null && index == 1) _buyCategory = -1;
      
      if (index == 0) _homeKey = UniqueKey();
      if (index == 1) _buyKey = UniqueKey();
      if (index == 2) _sellKey = UniqueKey();
      if (index == 3) _chatKey = UniqueKey(); 
      
      // 🟢 2. Baris "_unreadMessages = 0;" SUDAH DIHAPUS DARI SINI
      // Sekarang kita murni mengandalkan data dari API.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(key: _homeKey), 
          BuyScreen(key: _buyKey, initialCategory: _buyCategory), 
          SellScreen(key: _sellKey), 
          ChatsListScreen(key: _chatKey),
          const AccountScreen(),
        ],
      ),
      bottomNavigationBar: _EverGearNavBar(
        currentIndex: _currentIndex,
        unreadMessagesCount: _unreadMessages, // 🟢 Kirim datanya ke NavBar
        onTap: (i) => switchTab(i),
      ),
    );
  }
}

class _EverGearNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int unreadMessagesCount; // 🟢 Menerima data jumlah pesan

  const _EverGearNavBar({
    required this.currentIndex,
    required this.onTap,
    this.unreadMessagesCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    // 🟢 Kita tambahkan parameter badgeCount ke dalam List ini
    final items = [
      const _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
      const _NavItem(icon: Icons.shopping_cart_outlined, activeIcon: Icons.shopping_cart, label: 'Buy'),
      const _NavItem(icon: Icons.sell_outlined, activeIcon: Icons.sell, label: 'Sell'),
      _NavItem(
        icon: Icons.chat_bubble_outline, 
        activeIcon: Icons.chat_bubble, 
        label: 'Messages',
        badgeCount: unreadMessagesCount, // 🟢 Pasang angkanya di menu Messages
      ),
      const _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Account'),
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
              
              // 🟢 Susun Ikon Standar
              Widget iconWidget = Icon(
                isActive ? item.activeIcon : item.icon,
                color: isActive ? AppTheme.primary : const Color(0xFF9CA3AF),
                size: 22,
              );

              // 🟢 Jika badgeCount lebih dari 0, bungkus Ikon dengan Badge merah
              if (item.badgeCount > 0) {
                iconWidget = Badge(
                  label: Text(
                    item.badgeCount.toString(),
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                  backgroundColor: AppTheme.error, // Pakai warna merah dari thememu
                  child: iconWidget,
                );
              }

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
                        child: Center(child: iconWidget), // 🟢 Letakkan Ikon (atau Badge) di sini
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          color: isActive ? AppTheme.primary : const Color(0xFF9CA3AF),
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
  final int badgeCount; // 🟢 Parameter baru untuk badge

  const _NavItem({
    required this.icon, 
    required this.activeIcon, 
    required this.label,
    this.badgeCount = 0, // Defaultnya 0 (tidak ada notif)
  });
}