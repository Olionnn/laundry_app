import 'package:flutter/material.dart';
import 'package:laundry_app/models/pesanan.dart';
import 'package:laundry_app/screens/auth/login_screen.dart';
import 'package:laundry_app/screens/auth/register_screen.dart';
import 'package:laundry_app/screens/error_screen.dart';
import 'package:laundry_app/screens/pencari_layanan/detail_layanan_screen.dart';
import 'package:laundry_app/screens/pencari_layanan/gmaps_layanan_screen.dart';
import 'package:laundry_app/screens/pencari_layanan/home_layanan_screen.dart';
import 'package:laundry_app/screens/pencari_layanan/components/quisioner_layanan_screen.dart';
import 'package:laundry_app/screens/penyedia_layanan/req_penyedia_layanan_screen.dart';
import 'package:laundry_app/screens/penyedia_layanan/profile_layanan_screen.dart';
import 'package:laundry_app/screens/penyedia_layanan/request_layanan_detail_screen.dart';
import 'package:laundry_app/screens/splash_screen.dart';
import 'package:laundry_app/screens/pencari_layanan/main_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String main = '/main';
  static const String login = '/login';
  static const String register = '/register';
  static const String requestLayanan = '/request_layanan';
  static const String profileLayanan = '/profile_layanan';
  static const String detailRequestLayanan = '/detail_request_layanan';
  static const String detailLayanan = '/detail_layanan';
  static const String quisionerLayanan = '/quisioner_layanan';

  /// Route generator function
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case main:
        return MaterialPageRoute(builder: (_) => const MainScreen());

      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => RegisterScreen());

      case requestLayanan:
        return MaterialPageRoute(
            builder: (_) => const HalamanPenyediaLayanan());

      case profileLayanan:
        return MaterialPageRoute(builder: (_) => const ProfileLayananScreen());

      case detailRequestLayanan:
        final id = settings.arguments as Map<String, dynamic>?;
        if (id == null) {
          return _errorRoute('ID tidak ditemukan untuk detail request layanan');
        }
        return MaterialPageRoute(
          builder: (_) => DetailRequestLayananScreen(pesanan: id),
        );

      case detailLayanan:
        final id = settings.arguments as int?;
        if (id == null) {
          return _errorRoute('ID tidak ditemukan untuk detail layanan');
        }
        return MaterialPageRoute(
          builder: (_) => DetailLayananScreen(
            layananId: id,
            isFromGMaps: false,
          ),
        );

      case quisionerLayanan:
        return MaterialPageRoute(
            builder: (_) => QuisionerLayananScreen(
                  phoneNumber: '+6281234567890',
                ));

      default:
        return _errorRoute('Halaman tidak ditemukan: ${settings.name}');
    }
  }

  /// Error route for undefined routes or missing arguments
  static MaterialPageRoute<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => ErrorScreen(message: message),
    );
  }
}
