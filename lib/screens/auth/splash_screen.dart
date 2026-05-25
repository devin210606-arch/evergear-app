import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  
  late AnimationController _textController;
  late Animation<double> _textSlide;
  late Animation<double> _textFade;
  
  late AnimationController _progressController;
  late AnimationController _ringController;
  late AnimationController _pulseController;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _logoScale = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut));
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)));

    _textController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _textSlide = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut));
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    _progressController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));
    _ringController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat();

    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _logoController.forward().then((_) {
      _textController.forward();
      _progressController.forward();
    });
  Future.delayed(const Duration(milliseconds: 3800), () async {
    if (mounted) {
      final token = await ApiService.getToken();
      if (token != null && token.isNotEmpty) {
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    _ringController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF050510), Color(0xFF0D1B4B), Color(0xFF07101F)],
        ),
      ),
      child: Stack(
        children: [
          // Center: logo + text
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo with rotating rings + pulse glow
                AnimatedBuilder(
                  animation: Listenable.merge([_logoController, _ringController, _pulseController]),
                  builder: (context, _) {
                    return SizedBox(
                      width: 180,
                      height: 180,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Pulse glow halo
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withOpacity(0.35 * _pulse.value),
                                  blurRadius: 48 * _pulse.value,
                                  spreadRadius: 12 * _pulse.value,
                                ),
                              ],
                            ),
                          ),
                          // Outer ring clockwise
                          Transform.rotate(
                            angle: _ringController.value * 2 * math.pi,
                            child: CustomPaint(
                              size: const Size(150, 150),
                              painter: _DashedRingPainter(color: AppTheme.primary.withOpacity(0.7), dashCount: 10),
                            ),
                          ),
                          // Inner ring counter-clockwise
                          Transform.rotate(
                            angle: -_ringController.value * 2 * math.pi * 0.6,
                            child: CustomPaint(
                              size: const Size(118, 118),
                              painter: _DashedRingPainter(color: AppTheme.accent.withOpacity(0.5), dashCount: 6),
                            ),
                          ),
                          // Logo box bounces in
                          FadeTransition(
                            opacity: _logoFade,
                            child: ScaleTransition(
                              scale: _logoScale,
                              child: Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primary.withOpacity(0.7),
                                      blurRadius: 28,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.settings, color: Colors.white, size: 48),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // EverGear text slides up
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, _) => Opacity(
                    opacity: _textFade.value,
                    child: Transform.translate(
                      offset: Offset(0, _textSlide.value),
                      child: Text(
                        'EverGear',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, _) => Opacity(
                    opacity: _textFade.value,
                    child: Transform.translate(
                      offset: Offset(0, _textSlide.value * 1.3),
                      child: Text(
                        'Refurbished Parts Marketplace',
                        style: GoogleFonts.poppins(color: Colors.white38, fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom: tip + progress bar
          Positioned(
            bottom: 56,
            left: 40,
            right: 40,
            child: AnimatedBuilder(
              animation: _textController,
              builder: (context, _) => Opacity(
                opacity: _textFade.value,
                child: Column(
                  children: [
                    Text(
                      '"Tip: Refurbished components often perform\nbetter than cheap new ones."',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.45), fontSize: 12, height: 1.6),
                    ),
                    const SizedBox(height: 20),
                    AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, _) => ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: _progressController.value,
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('Loading...', style: GoogleFonts.poppins(color: Colors.white30, fontSize: 11)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}

class _DashedRingPainter extends CustomPainter {
  final Color color;
  final int dashCount;

  const _DashedRingPainter({required this.color, this.dashCount = 10});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final dashAngle = (2 * math.pi) / dashCount;
    const gapFraction = 0.38;

    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * dashAngle,
        dashAngle * (1 - gapFraction),
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}