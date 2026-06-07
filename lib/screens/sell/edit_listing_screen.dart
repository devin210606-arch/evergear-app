import 'package:evergear/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../theme/app_theme.dart';

class EditListingScreen extends StatefulWidget {
  final int listingId;
  final String title;
  final int price;
  final String category;
  final String condition;
  final String description;

  const EditListingScreen({
    super.key,
    required this.listingId,
    required this.title,
    required this.price,
    required this.category,
    required this.condition,
    required this.description,
  });

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _descCtrl;
  late int _selectedCategory;
  late String _selectedCondition;
  final List<File> _photos = [];

  final List<Map<String, dynamic>> _categories = [
    {'label': 'LCD', 'icon': Icons.phone_android},
    {'label': 'Battery', 'icon': Icons.battery_full},
    {'label': 'Camera', 'icon': Icons.camera_alt_outlined},
    {'label': 'Back Cover', 'icon': Icons.smartphone},
  ];

  final List<String> _conditions = ['Refurbished', 'Broken', 'Like New', 'Used'];

  @override
  void initState() {
    super.initState();
    // Mengisi kolom teks dengan data asli dari database
    _nameCtrl = TextEditingController(text: widget.title);
    _priceCtrl = TextEditingController(text: widget.price.toString());
    _descCtrl = TextEditingController(text: widget.description);
    _selectedCondition = widget.condition;
    
    // Mencari kategori yang sesuai
    final cats = ['LCD', 'Battery', 'Camera', 'Back Cover'];
    _selectedCategory = cats.indexOf(widget.category);
    if (_selectedCategory == -1) _selectedCategory = 0; 
  }

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
    
    File? selectedImage = _photos.isNotEmpty ? _photos.first : null;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Updating listing...'), duration: Duration(seconds: 1)),
    );

    final result = await ApiService.updateListing(
      listingId: widget.listingId, // Menggunakan ID dinamis
      title: _nameCtrl.text,
      price: int.parse(_priceCtrl.text),
      category: _categories[_selectedCategory]['label'],
      condition: _selectedCondition,
      description: _descCtrl.text,
      imageFile: selectedImage, 
    );

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Listing updated successfully', style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ));
      Navigator.pop(context); 
    } else {
      _showError(result['message'] ?? 'Failed to update listing');
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
        title: Text('Edit Listing',
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

            // Photo picker
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  GestureDetector(
                    onTap: () async {
                      if (_photos.length >= 5) {
                        _showError('Maximum 5 photos');
                        return;
                      }
                      final picked = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
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
                          Text('${_photos.length}/5',
                              style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                  ..._photos.asMap().entries.map((e) => Stack(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        margin: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(e.value, fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 12,
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _photos.removeAt(e.key)),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: AppTheme.error,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 12),
                          ),
                        ),
                      ),
                    ],
                  )),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Form
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Part Name',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nameCtrl,
                    maxLength: 60,
                    decoration: const InputDecoration(
                        hintText: 'e.g. iPhone 14 Camera Module'),
                  ),
                  const SizedBox(height: 16),

                  Text('Price (Rp.)',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                        hintText: 'e.g. 120000', prefixText: 'Rp. '),
                  ),
                  const SizedBox(height: 16),

                  Text('Category',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(_categories.length, (i) {
                      final isSelected = _selectedCategory == i;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedCategory = i),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primary
                                    : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Icon(_categories[i]['icon'],
                                      size: 22,
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.textSecondary),
                                  const SizedBox(height: 4),
                                  Text(_categories[i]['label'],
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

                  Text('Condition',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _conditions.map((c) {
                      final isSelected = _selectedCondition == c;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCondition = c),
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

                  Text('Description',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _descCtrl,
                    maxLines: 4,
                    maxLength: 300,
                    decoration: const InputDecoration(
                        hintText: 'Describe condition, compatibility, etc.'),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _submit,
                    child: Text('Save Changes',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700)),
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