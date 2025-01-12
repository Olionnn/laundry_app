import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:laundry_app/models/penyedia_layanan.dart';
import 'package:laundry_app/screens/pencari_layanan/detail_layanan_screen.dart';
import 'package:laundry_app/services/penyedia_layanan_services.dart';

class HomeLayananScreen extends StatefulWidget {
  const HomeLayananScreen({super.key});

  @override
  _HomeLayananScreenState createState() => _HomeLayananScreenState();
}

class _HomeLayananScreenState extends State<HomeLayananScreen> {
  bool _isLoading = true;
  bool _isFetchingMore = false;
  List<PenyediaLayananList> _datalist = [];
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _hasMoreData = true;
  String _searchQuery = '';
  double? userLat;
  double? userLng;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserLocation();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Fetch user's location
  void _fetchUserLocation() async {
    setState(() => _isLoading = true);
    try {
      final location = await Location().getLocation();
      setState(() {
        userLat = location.latitude;
        userLng = location.longitude;
      });
      _fetchPenyediaLayanan();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching location: $e')),
      );
    }
  }

  /// Fetch data from API
  Future<void> _fetchPenyediaLayanan({bool isLoadMore = false}) async {
    if (isLoadMore) {
      setState(() => _isFetchingMore = true);
    } else {
      setState(() => _isLoading = true);
    }

    try {
      final result = await PenyediaLayananService.getPenyediaLayanan(
        page: _currentPage,
        limit: _pageSize,
        search: _searchQuery,
        userLat: userLat,
        userLng: userLng,
      );

      final List<PenyediaLayananList> newData = result['data']
          .map<PenyediaLayananList>(
              (item) => PenyediaLayananList.fromJson(item))
          .toList();

      setState(() {
        if (newData.length < _pageSize) {
          _hasMoreData = false; // No more data available
        }
        _datalist.addAll(newData);
        _isLoading = false;
        _isFetchingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isFetchingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
  }

  /// Handle infinite scrolling
  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isFetchingMore &&
        _hasMoreData) {
      _currentPage++;
      _fetchPenyediaLayanan(isLoadMore: true);
    }
  }

  /// Handle search
  void _onSearch() {
    setState(() {
      _currentPage = 1;
      _hasMoreData = true;
      _datalist.clear();
    });
    _fetchPenyediaLayanan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Cari layanan...',
            hintStyle: const TextStyle(color: Colors.white70),
            prefixIcon: const Icon(Icons.search, color: Colors.white),
            filled: true,
            fillColor: Colors.white12,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (value) {
            _searchQuery = value;
            _onSearch();
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _datalist.clear();
                  _currentPage = 1;
                  _hasMoreData = true;
                });
                await _fetchPenyediaLayanan();
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _datalist.length + (_isFetchingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < _datalist.length) {
                    final layanan = _datalist[index];
                    return _buildServiceCard(
                      context,
                      title: layanan.namaToko,
                      description: layanan.deskripsi,
                      layananId: layanan.id,
                      distance: layanan.distance ?? 0.0, // Distance from API
                    );
                  } else {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
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
    required double distance,
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
            "Description: $description\nDistance: ${distance.toStringAsFixed(1)} km",
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        trailing: const Icon(Icons.arrow_forward, color: Colors.deepPurple),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailLayananScreen(
                layananId: layananId,
                isFromGMaps: false,
              ),
            ),
          );
        },
      ),
    );
  }
}
