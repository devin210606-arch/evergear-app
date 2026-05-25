import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';
import '../../widgets/social_button.dart';
import '../../services/api_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _register() async {
  final name = _nameCtrl.text.trim();
  final email = _emailCtrl.text.trim();
  final password = _passCtrl.text.trim();
  final confirm = _confirmPassCtrl.text.trim();

  if (name.isEmpty) { _showError('Please enter your name'); return; }
  if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
    _showError('Please enter a valid email'); return;
  }
  if (password.length < 6) { _showError('Password must be at least 6 characters'); return; }
  if (password != confirm) { _showError('Passwords do not match'); return; }

  setState(() => _isLoading = true);

  final result = await ApiService.register(
    name: name,
    email: email,
    password: password,
  );

  setState(() => _isLoading = false);

  if (result['success']) {
    // Auto login after register
    final loginResult = await ApiService.login(email: email, password: password);
    if (loginResult['success']) {
      Navigator.pushReplacementNamed(context, '/main');
    }
  } else {
    _showError(result['message']);
  }
}

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B4B),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0D1B4B), Color(0xFF0A0A1A)],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Logo
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.settings, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text('EverGear',
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 32),

                  // White card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Create Account',
                            style: GoogleFonts.poppins(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Fill in the details to get started',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: AppTheme.textSecondary)),
                        const SizedBox(height: 20),

                        // Full name
                        TextField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(hintText: 'Full Name'),
                        ),
                        const SizedBox(height: 12),

                        // Email
                        TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(hintText: 'Email'),
                        ),
                        const SizedBox(height: 12),

                        // Password
                        TextField(
                          controller: _passCtrl,
                          obscureText: _obscurePass,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: AppTheme.textSecondary, size: 20,
                              ),
                              onPressed: () => setState(() => _obscurePass = !_obscurePass),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Confirm password
                        TextField(
                          controller: _confirmPassCtrl,
                          obscureText: _obscureConfirm,
                          decoration: InputDecoration(
                            hintText: 'Confirm Password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: AppTheme.textSecondary, size: 20,
                              ),
                              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Register button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : Text('REGISTER',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                        ),
                        const SizedBox(height: 20),

                        // OR divider
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text('OR',
                                  style: GoogleFonts.poppins(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Social buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SocialButton(
                              icon: FontAwesomeIcons.xTwitter,  
                              color: const Color(0xFF000000),  
                              onTap: () {},
                            ),
                            const SizedBox(width: 16),
                            SocialButton(
                              icon: FontAwesomeIcons.facebook,  
                              color: const Color(0xFF1877F2),  
                              onTap: () {},
                            ),
                            const SizedBox(width: 16),
                            SocialButton(
                              icon: FontAwesomeIcons.google,  
                              color: const Color(0xFFDB4437),  
                              onTap: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Already have account
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.poppins(
                                    color: AppTheme.textSecondary, fontSize: 13),
                                children: [
                                  const TextSpan(text: 'Already have an account? '),
                                  TextSpan(
                                    text: 'Login',
                                    style: GoogleFonts.poppins(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}