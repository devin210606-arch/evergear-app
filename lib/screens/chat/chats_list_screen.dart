import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'chat_screen.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  bool _isLoading = false;

  // Placeholder chats — replace with real API when backend ready
  final List<Map<String, dynamic>> _chats = [
    {
      'id': 1,
      'otherUser': 'Seller A',
      'product': 'Iphone 17 Camera',
      'lastMessage': 'Can you do Rp. 100.000?',
      'time': '10:30',
      'unread': 2,
      'icon': Icons.camera_alt,
    },
    {
      'id': 2,
      'otherUser': 'Buyer B',
      'product': 'Google P8 Battery',
      'lastMessage': 'Yes still available!',
      'time': 'Yesterday',
      'unread': 0,
      'icon': Icons.battery_full,
    },
    {
      'id': 3,
      'otherUser': 'Seller C',
      'product': 'Samsung LCD A54',
      'lastMessage': 'I can ship tomorrow',
      'time': 'Mon',
      'unread': 0,
      'icon': Icons.phone_android,
    },
  ];

  Future<void> _loadChats() async {
    setState(() => _isLoading = true);
    // TODO: replace with real API when backend ready
    // final result = await ApiService.getMyChats();
    // if (result['success']) { setState(() => _chats = result['data']); }
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Messages',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chats.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.chat_bubble_outline,
                          size: 64, color: AppTheme.textSecondary),
                      const SizedBox(height: 12),
                      Text('No messages yet',
                          style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary)),
                      const SizedBox(height: 6),
                      Text('Start a conversation from a product page',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppTheme.textSecondary)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _chats.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final chat = _chats[i];
                    final hasUnread = (chat['unread'] as int) > 0;
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ChatScreen()),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: hasUnread
                                  ? AppTheme.primary.withOpacity(0.3)
                                  : const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0E7FF),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Icon(Icons.person,
                                  color: AppTheme.primary, size: 28),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(chat['otherUser'],
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13)),
                                      Text(chat['time'],
                                          style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              color: hasUnread
                                                  ? AppTheme.primary
                                                  : AppTheme.textSecondary,
                                              fontWeight: hasUnread
                                                  ? FontWeight.w600
                                                  : FontWeight.w400)),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(chat['product'],
                                      style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: AppTheme.primary,
                                          fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 2),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          chat['lastMessage'],
                                          style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: hasUnread
                                                  ? AppTheme.textPrimary
                                                  : AppTheme.textSecondary,
                                              fontWeight: hasUnread
                                                  ? FontWeight.w500
                                                  : FontWeight.w400),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (hasUnread)
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: const BoxDecoration(
                                            color: AppTheme.primary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${chat['unread']}',
                                              style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight:
                                                      FontWeight.w700),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}