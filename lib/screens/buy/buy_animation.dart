import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';

class BuyAnimationScreen extends StatefulWidget {
  // 🟢 1. UBAH TIPE DATA JADI double
  final double co2Reduced; 

  const BuyAnimationScreen({
    super.key, 
    this.co2Reduced = 2.0, // Default value disesuaikan jadi desimal
  });

  @override
  State<BuyAnimationScreen> createState() => _BuyAnimationScreenState();
}

class _BuyAnimationScreenState extends State<BuyAnimationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showButton = false; 

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/recycle_and_grow.json', 
                controller: _controller,
                onLoaded: (composition) {
                  _controller.duration = composition.duration;
                  _controller.forward().then((_) {
                    if (mounted) {
                      setState(() {
                        _showButton = true;
                      });
                    }
                  });
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Order Successful!',
                style: GoogleFonts.poppins(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),
              // 🟢 2. FORMAT ANGKA DESIMALNYA DI SINI
              Text(
                'You helped reduce ${widget.co2Reduced.toStringAsFixed(1)}% CO2!',
                style: GoogleFonts.poppins(
                  fontSize: 16, 
                  color: const Color(0xFF10B981), 
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Thank you for being an EverGear Hero!',
                style: GoogleFonts.poppins(
                  fontSize: 14, 
                  color: const Color(0xFF6B7280),
                ),
              ),
              
              const SizedBox(height: 40),
              AnimatedOpacity(
                opacity: _showButton ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 600),
                child: ElevatedButton(
                  onPressed: _showButton ? () => Navigator.pop(context, true) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Back to Home',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}