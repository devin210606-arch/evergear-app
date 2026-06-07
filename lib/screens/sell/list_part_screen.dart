import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/api_service.dart';

class ListPartScreen extends StatefulWidget {
  const ListPartScreen({super.key});

  @override
  State<ListPartScreen> createState() => _ListPartScreenState();
}

class _ListPartScreenState extends State<ListPartScreen> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  int _selectedCategory = -1;
  String _selectedCondition = 'Refurbished';
  bool _isLoading = false;

  // NEW: Added state variable for storing selected photos
  final List<File> _photos = [];

  final List<Map<String, dynamic>> _categories = [
    {'label': 'LCD', 'icon': Icons.phone_android},
    {'label': 'Battery', 'icon': Icons.battery_full},
    {'label': 'Camera', 'icon': Icons.camera_alt_outlined},
    {'label': 'Back Cover', 'icon': Icons.smartphone},
  ];

  final List<String> _conditions = ['Refurbished', 'Broken', 'Like New', 'Used'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_nameCtrl.text.isEmpty) { _showError('Please enter a part name'); return; }
    if (_priceCtrl.text.isEmpty) { _showError('Please enter a price'); return; }
    if (_selectedCategory == -1) { _showError('Please select a category'); return; }

    setState(() => _isLoading = true);

    final cats = ['LCD', 'Battery', 'Camera', 'Back Cover'];
    final result = await ApiService.createListing(
      title: _nameCtrl.text.trim(),
      price: int.tryParse(_priceCtrl.text.trim()) ?? 0,
      category: cats[_selectedCategory],
      condition: _selectedCondition,
      description: _descCtrl.text.trim(),
      imageFile: _photos.isNotEmpty ? _photos.first : null,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Listing created successfully!',
            style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ));
      if (mounted) Navigator.pop(context);
    } else {
      _showError(result['message']);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.poppins(fontSize: 13)),
      backgroundColor: const Color(0xFFEF4444),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('List a New Part',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // NEW: Replaced the static photo upload area with the interactive horizontal ListView
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Add photo button
                  GestureDetector(
                    onTap: () async {
                      if (_photos.length >= 5) {
                        _showError('Maximum 5 photos allowed');
                        return;
                      }
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(source: ImageSource.gallery);
                      if (picked != null) {
                        setState(() => _photos.add(File(picked.path)));
                      }
                    },
                    child: Container(
                      width: 90,
                      height: 90,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppTheme.primary.withOpacity(0.3)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_photo_alternate_outlined,
                              size: 28, color: AppTheme.primary),
                          Text('Add Photo',
                              style: GoogleFonts.poppins(
                                  fontSize: 10, color: AppTheme.primary)),
                          Text('${_photos.length}/5',
                              style: GoogleFonts.poppins(
                                  fontSize: 10, color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                  // Preview selected photos
                  ..._photos.asMap().entries.map((e) => Stack(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(e.value, fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 12,
                        child: GestureDetector(
                          onTap: () => setState(() => _photos.removeAt(e.key)),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: AppTheme.error,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 12),
                          ),
                        ),
                      ),
                    ],
                  )),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Form card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Part name
                  Text('Part Name',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 6),
                  // NEW: Added maxLength: 60
                  TextField(
                    controller: _nameCtrl,
                    maxLength: 60,
                    decoration: const InputDecoration(
                        hintText: 'e.g. iPhone 14 Camera Module'),
                  ),
                  const SizedBox(height: 16),

                  // Price
                  Text('Price (Rp.)',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 6),
                  // NEW: Added inputFormatters for digits only
                  TextField(
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                        hintText: 'e.g. 120000',
                        prefixText: 'Rp. '),
                  ),
                  const SizedBox(height: 16),

                  // Category
                  Text('Category',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(_categories.length, (i) {
                      final cat = _categories[i];
                      final isSelected = _selectedCategory == i;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedCategory = i),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primary
                                    : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Icon(cat['icon'],
                                      size: 22,
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.textSecondary),
                                  const SizedBox(height: 4),
                                  Text(cat['label'],
                                      style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          color: isSelected
                                              ? Colors.white
                                              : AppTheme.textSecondary,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // Condition
                  Text('Condition',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _conditions.map((c) {
                      final isSelected = _selectedCondition == c;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCondition = c),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primary
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(c,
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.textSecondary,
                                  fontWeight: FontWeight.w500)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text('Description',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 6),
                  // NEW: Added maxLength: 300
                  TextField(
                    controller: _descCtrl,
                    maxLines: 4,
                    maxLength: 300,
                    decoration: const InputDecoration(
                        hintText: 'Describe the condition, compatibility, etc.'),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text('Submit Listing',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}