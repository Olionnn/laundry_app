import 'package:flutter/material.dart';
import 'package:laundry_app/screens/penyedia_layanan/components/main_layout.dart';
import 'package:laundry_app/services/penyedia_layanan_services.dart';
import 'package:laundry_app/services/pesanan_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HalamanPenyediaLayanan extends StatefulWidget {
  const HalamanPenyediaLayanan({super.key});

  @override
  State<HalamanPenyediaLayanan> createState() => _HalamanPenyediaLayananState();
}

class _HalamanPenyediaLayananState extends State<HalamanPenyediaLayanan> {
  final PesananServices _pesananService = PesananServices();
  final PenyediaLayananService _penyediaLayananService =
      PenyediaLayananService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  int? layananId;

  List<Map<String, dynamic>> allData = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _initializeLayananId(); // Ensure layananId is initialized before fetching data.

    // Add listener for scroll to trigger pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          hasMoreData &&
          !isLoading) {
        _fetchPesanan();
      }
    });
  }

  Future<void> _initializeLayananId() async {
    try {
      await _getLayananId();
      if (layananId != null) {
        _fetchPesanan(); // Fetch data after layananId is set.
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _getLayananId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId == null) {
      throw Exception('User ID not found');
    }

    final penyediaLayanan =
        await PenyediaLayananService.getPenyediaLayananProfile(userId);

    if (penyediaLayanan == null) {
      throw Exception('Penyedia layanan not found');
    }

    setState(() {
      layananId = penyediaLayanan.id;
    });
  }

  Future<void> _fetchPesanan({bool isSearch = false}) async {
    if (isLoading || layananId == null) return; // Ensure layananId is set.

    setState(() => isLoading = true);

    try {
      final response = await _pesananService.getPesanan(
        layananId: layananId!,
        page: currentPage,
        search: isSearch ? _searchController.text.trim() : null,
      );

      if (response.isNotEmpty) {
        setState(() {
          allData.addAll(response
              .map((pesanan) => pesanan.toJson())
              .toList()); // Append new data to the list
          currentPage++; // Increment page number
        });
      } else {
        setState(() => hasMoreData = false); // No more data to load
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _refreshPage() {
    setState(() {
      allData.clear();
      currentPage = 1;
      hasMoreData = true;
    });
    if (layananId != null) {
      _fetchPesanan(isSearch: true); // Trigger search on refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Pesanan List',
      currentIndex: 0,
      onTabTapped: (index) {
        if (index == 1) {
          Navigator.pushNamed(context, '/profile_layanan');
        } else if (index == 2) {
          Navigator.pushNamed(context, '/');
        }
      },
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onSubmitted: (value) {
                _refreshPage(); // Trigger a search
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () => _refreshPage(),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: allData.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == allData.length) {
                  return const Center(child: CircularProgressIndicator());
                }

                final pesanan = allData[index];
                return Card(
                  color: Colors.white12,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(
                      pesanan['p_nama'] ?? 'Unknown',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      pesanan['p_alamat'] ?? 'No address available',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing:
                        const Icon(Icons.chevron_right, color: Colors.white),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/detail_request_layanan',
                        arguments: pesanan, // Pass the selected pesanan map
                      ).then((_) {
                        _refreshPage(); // Refresh state when returning from the detail screen
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
