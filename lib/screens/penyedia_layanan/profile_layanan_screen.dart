import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:laundry_app/screens/penyedia_layanan/components/google_maps_picker.dart';
import 'package:laundry_app/services/penyedia_layanan_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileLayananScreen extends StatefulWidget {
  const ProfileLayananScreen({super.key});

  @override
  State<ProfileLayananScreen> createState() => _ProfileLayananScreenState();
}

class _ProfileLayananScreenState extends State<ProfileLayananScreen> {
  bool _isLoading = true;
  bool _isEditing = false;
  Map<String, dynamic>? _profile;

  late Future<SharedPreferences> prefs;
  int? userId;

  @override
  void initState() {
    super.initState();
    prefs = SharedPreferences.getInstance();
    _initializeUserId(); // Ensure userId is initialized before fetching profile
  }

  Future<void> _initializeUserId() async {
    final SharedPreferences prefsInstance = await prefs;
    final userId = prefsInstance.getInt('user_id'); // Retrieve user_id
    if (userId != null) {
      setState(() {
        this.userId = userId;
      });
      print("User ID: $userId"); // Debugging line to check userId
      await _fetchProfile(); // Fetch the profile after userId is available
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found')),
      );
    }
  }

  Future<void> _fetchProfile() async {
    if (userId == null) return; // Ensure userId is valid before fetching data

    try {
      print("Fetching profile for user ID: $userId"); // Debugging line

      final response = await PenyediaLayananService.getPenyediaLayanan(
        userId: userId,
        page: 1, // Start with the first page
        limit: 2, // Adjust based on expected data size
      );

      if (response != null &&
          response['data'] != null &&
          response['data'].isNotEmpty) {
        final profile = response['data'].firstWhere(
          (item) => item['user_id'] == userId,
          orElse: () => null, // Correctly handle missing profile
        );

        if (profile != null) {
          setState(() {
            _isLoading = false;
            _profile = profile;
            _namaTokoController.text = _profile?['nama_toko'] ?? '';
            _deskripsiController.text = _profile?['deskripsi'] ?? '';
            _alamatController.text = _profile?['alamat'] ?? '';
            _latController.text = _profile?['lat'] ?? '';
            _longController.text = _profile?['long'] ?? '';
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile not found for this user ID')),
          );
        }
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No profile data found')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  final TextEditingController _namaTokoController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _longController = TextEditingController();

  // Sync location with device
  Future<void> _syncLocation() async {
    try {
      await _checkPermissions();
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _latController.text = position.latitude.toString();
        _longController.text = position.longitude.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location synchronized successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error syncing location: ${e.toString()}')),
      );
    }
  }

  // Check and request location permissions
  Future<void> _checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, cannot request permissions.');
    }
  }

  // Save profile data
  Future<void> _saveProfile() async {
    try {
      if (_profile == null) {
        // Create new profile
        await PenyediaLayananService.createLayananProfile(
          _namaTokoController.text,
          _deskripsiController.text,
          _alamatController.text,
          _latController.text,
          _longController.text,
          userId.toString(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile created successfully!')),
        );
      } else {
        // Update existing profile
        await PenyediaLayananService.updateLayananProfile(
          _profile?['id'].toString() ?? '',
          {
            'nama_toko': _namaTokoController.text,
            'deskripsi': _deskripsiController.text,
            'alamat': _alamatController.text,
            'lat': double.tryParse(_latController.text) ??
                0.0, // Ensure lat is a valid number
            'long': double.tryParse(_longController.text) ??
                0.0, // Ensure long is a valid number
          },
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
      setState(() => _isEditing = false);
      _fetchProfile();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _namaTokoController.dispose();
    _deskripsiController.dispose();
    _alamatController.dispose();
    _latController.dispose();
    _longController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Layanan'),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
              ? _buildCreateForm()
              : _buildProfileView(),
    );
  }

  // Create form for profile
  Widget _buildCreateForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildTextField('Nama Toko', _namaTokoController),
          _buildTextField('Deskripsi', _deskripsiController),
          _buildTextField('Alamat', _alamatController),
          _buildTextField('Latitude', _latController, editable: false),
          _buildTextField('Longitude', _longController, editable: false),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _syncLocation,
            child: const Text('Sync Location'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              final LatLng? selectedLocation = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const GoogleMapsPicker()),
              );
              if (selectedLocation != null) {
                setState(() {
                  _latController.text = selectedLocation.latitude.toString();
                  _longController.text = selectedLocation.longitude.toString();
                });
              }
            },
            child: const Text('Pick Location on Map'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _saveProfile,
            child: const Text('Create Profile'),
          ),
        ],
      ),
    );
  }

  // Display profile view
  Widget _buildProfileView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('Nama Toko', _namaTokoController,
              editable: _isEditing),
          _buildTextField('Deskripsi', _deskripsiController,
              editable: _isEditing),
          _buildTextField('Alamat', _alamatController, editable: _isEditing),
          _buildTextField('Latitude', _latController, editable: false),
          _buildTextField('Longitude', _longController, editable: false),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _syncLocation,
            child: const Text('Sync Location'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _isEditing
                ? _saveProfile
                : () => setState(() => _isEditing = true),
            child: Text(_isEditing ? 'Done' : 'Edit Profile'),
          ),
        ],
      ),
    );
  }

  // Text field widget with editable options
  Widget _buildTextField(String label, TextEditingController controller,
      {bool editable = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        enabled: editable,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple),
          ),
        ),
      ),
    );
  }
}
