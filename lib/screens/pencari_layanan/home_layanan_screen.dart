import 'package:flutter/material.dart';
import 'package:laundry_app/models/penyedia_layanan.dart';
import 'package:laundry_app/services/penyedia_layanan_services.dart';
import 'components/main_layout.dart';

class HomeLayananScreen extends StatefulWidget {
  const HomeLayananScreen({super.key});

  @override
  _HomeLayananScreenState createState() => _HomeLayananScreenState();
}

class _HomeLayananScreenState extends State<HomeLayananScreen> {
  bool _isLoading = true;
  List<PenyediaLayanan> _penyediaLayanan = [];
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _fetchPenyediaLayanan();
  }

  Future<void> _fetchPenyediaLayanan() async {
    try {
      final result = await PenyediaLayananService.getPenyediaLayanan(
        page: _currentPage,
        limit: 10,
      );
      setState(() {
        _penyediaLayanan = result['data'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Home Layanan',
      currentIndex: 0,
      onTabTapped: (index) {
        if (index == 1) {
          Navigator.pushNamed(context, '/gmaps_layanan');
        } else if (index == 2) {
          Navigator.pushNamed(context, '/login');
        }
      },
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchPenyediaLayanan,
              child: ListView.builder(
                itemCount: _penyediaLayanan.length,
                itemBuilder: (context, index) {
                  final layanan = _penyediaLayanan[index];
                  return _buildServiceCard(
                    context,
                    title: layanan.namaToko,
                    description: layanan.deskripsi,
                    layananId: layanan.id, // Pastikan ID dikirim dengan benar
                  );
                },
              ),
            ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required String title,
    required String description,
    required int layananId,
  }) {
    return Card(
      color: Colors.white12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        trailing: const Icon(Icons.arrow_forward, color: Colors.deepPurple),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/detail_layanan',
            arguments: layananId, // Kirim ID sebagai arguments
          );
        },
      ),
    );
  }
}
