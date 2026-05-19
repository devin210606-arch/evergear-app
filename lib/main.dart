import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/check_email_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/wallet_screen.dart';
import 'screens/home/payment_screen.dart';
import 'screens/home/product_detail_screen.dart';
import 'screens/home/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const EverGearApp());
}

class EverGearApp extends StatelessWidget {
  const EverGearApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EverGear',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/check-email': (_) => const CheckEmailScreen(),
        '/otp': (_) => const OtpScreen(),
        '/signup': (_) => const SignUpScreen(),
        '/main': (_) => const MainShell(),
        '/wallet': (_) => const WalletScreen(),
        '/payment': (_) => const PaymentScreen(),
        '/product-detail': (_) => const ProductDetailScreen(),
       
      },
    );
  }
}
