import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
// NEW: Added the two imports here at the top
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl = TextEditingController(text: 'Buyer 1');
  final _emailCtrl = TextEditingController(text: 'Buyerland@gmail.com');
  final _phoneCtrl = TextEditingController(text: '');
  
  // NEW: Added the image variable here, with your other state variables
  File? _profileImage;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Edit Profile',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            
            // NEW: This entire Center block replaced the old avatar code
            Center(
              child: GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    setState(() => _profileImage = File(picked.path));
                  }
                },
                child: Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1C1C2E),
                        shape: BoxShape.circle,
                      ),
                      child: _profileImage != null
                          ? ClipOval(
                              child: Image.file(_profileImage!,
                                  width: 90, height: 90, fit: BoxFit.cover))
                          : const Icon(Icons.person, color: Colors.white, size: 52),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // END OF NEW AVATAR CODE

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Full Name',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(controller: _nameCtrl,
                      decoration: const InputDecoration(hintText: 'Full Name')),
                  const SizedBox(height: 16),

                  Text('Email',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(hintText: 'Email')),
                  const SizedBox(height: 16),

                  Text('Phone Number',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(hintText: 'Phone Number')),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () {
                      // TODO: call backend update profile API
                      Navigator.pop(context);
                    },
                    child: Text('Save Changes',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}