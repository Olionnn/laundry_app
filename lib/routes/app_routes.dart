import 'package:flutter/material.dart';
import 'package:laundry_app/screens/auth/login_screen.dart';
import 'package:laundry_app/screens/auth/register_screen.dart';
import 'package:laundry_app/screens/error_screen.dart';
import 'package:laundry_app/screens/pencari_layanan/detail_layanan_screen.dart';
import 'package:laundry_app/screens/pencari_layanan/gmaps_layanan_screen.dart';
import 'package:laundry_app/screens/pencari_layanan/home_layanan_screen.dart';
import 'package:laundry_app/screens/pencari_layanan/quisioner_layanan_screen.dart';
import 'package:laundry_app/screens/penyedia_layanan/req_penyedia_layanan_screen.dart';
import 'package:laundry_app/screens/penyedia_layanan/profile_layanan_screen.dart';
import 'package:laundry_app/screens/penyedia_layanan/request_layanan_detail_screen.dart';
import 'package:laundry_app/screens/splash_screen.dart';

class AppRoutes {
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String requestLayanan = '/request_layanan';
  static const String profileLayanan = '/profile_layanan';
  static const String detailRequestLayanan = '/detail_request_layanan';
  static const String gmapsLayanan = '/gmaps_layanan';
  static const String quisionerLayanan = '/quisioner_layanan';
  // static const String pencariLayanan = '/pencari_layanan';
  static const String detailLayanan = '/detail_layanan';

  static const String splash = '/';

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
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
        final id = settings.arguments as int?;
        if (id == null) {
          return MaterialPageRoute(
            builder: (_) => const ErrorScreen(message: 'ID tidak ditemukan'),
          );
        }
        return MaterialPageRoute(
          builder: (_) => DetailRequestLayananScreen(requestId: id),
        );
      case gmapsLayanan:
        return MaterialPageRoute(builder: (_) => const GMapsLayananScreen());
      case quisionerLayanan:
        return MaterialPageRoute(
            builder: (_) => const QuisionerLayananScreen());
      case AppRoutes.detailLayanan:
        final id = settings.arguments as int?;
        if (id == null) {
          return MaterialPageRoute(
            builder: (_) => const ErrorScreen(message: 'ID tidak ditemukan'),
          );
        }
        return MaterialPageRoute(
          builder: (_) =>
              DetailLayananScreen(layananId: id), // Perbaikan di sini
        );
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeLayananScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const ErrorScreen(message: 'Halaman tidak ditemukan'),
        );
    }
  }
}
