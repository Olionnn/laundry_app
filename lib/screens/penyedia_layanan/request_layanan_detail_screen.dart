import 'package:flutter/material.dart';
import 'package:laundry_app/models/pesanan.dart';
import 'package:laundry_app/services/pesanan_services.dart';

class DetailRequestLayananScreen extends StatefulWidget {
  final Map<String, dynamic> pesanan;

  const DetailRequestLayananScreen({super.key, required this.pesanan});

  @override
  _DetailRequestLayananScreenState createState() =>
      _DetailRequestLayananScreenState();
}

class _DetailRequestLayananScreenState
    extends State<DetailRequestLayananScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaPelangganController;
  late TextEditingController _noHpController;
  late TextEditingController _alamatController;
  late TextEditingController _yangDimintaController;
  late String _status;

  @override
  void initState() {
    super.initState();

    print("Pesanan data: ${widget.pesanan}");

    // Initialize controllers with fallback values for null fields
    _namaPelangganController =
        TextEditingController(text: widget.pesanan['p_nama'] ?? '');
    _noHpController =
        TextEditingController(text: widget.pesanan['p_no_hp'] ?? '');
    _alamatController =
        TextEditingController(text: widget.pesanan['p_alamat'] ?? '');
    _yangDimintaController =
        TextEditingController(text: widget.pesanan['p_quisioner'] ?? '');
    _status = _mapStatusToName(widget.pesanan['p_status'] as int? ?? 0);
  }

  @override
  void dispose() {
    _namaPelangganController.dispose();
    _noHpController.dispose();
    _alamatController.dispose();
    _yangDimintaController.dispose();
    super.dispose();
  }

  String _mapStatusToName(int? status) {
    if (status == null) return 'Unknown Status';
    switch (status) {
      case 1:
        return 'Menunggu Konfirmasi';
      case 2:
        return 'Dikonfirmasi';
      case 3:
        return 'Ditolak';
      default:
        return 'Unknown Status';
    }
  }

  int _mapNameToStatus(String statusName) {
    switch (statusName) {
      case 'Menunggu Konfirmasi':
        return 1;
      case 'Dikonfirmasi':
        return 2;
      case 'Ditolak':
        return 3;
      default:
        return 0; // Default to 0 for unknown status
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Request: ${widget.pesanan['id'] ?? 'Unknown ID'}'),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildSectionTitle('Nama Pelanggan'),
              _buildTextFormField(
                controller: _namaPelangganController,
                hintText: 'Nama Pelanggan',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama Pelanggan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Nomor HP'),
              _buildTextFormField(
                controller: _noHpController,
                hintText: 'Nomor HP',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor HP tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Yang Diminta'),
              _buildTextAreaFormField(
                controller: _yangDimintaController,
                hintText: 'Layanan yang diminta atau feedback',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Layanan yang Diminta tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Alamat Penjemputan'),
              _buildTextFormField(
                controller: _alamatController,
                hintText: 'Alamat Penjemputan',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat Penjemputan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Status'),
              _buildDropdownButtonFormField<String>(
                value: _status,
                items: <String>[
                  'Menunggu Konfirmasi',
                  'Dikonfirmasi',
                  'Ditolak',
                ],
                onChanged: (value) => setState(() => _status = value!),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildButton(
                    label: 'Kembali',
                    color: Colors.deepPurple,
                    onPressed: () => Navigator.pop(context),
                  ),
                  _buildButton(
                    label: 'Simpan',
                    color: Colors.green,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          final updatedPesanan =
                              await PesananServices().updatePesanan(
                            widget.pesanan['id'] ?? 0, // Default ID to 0
                            _namaPelangganController.text,
                            _noHpController.text,
                            widget.pesanan['p_date'] ??
                                DateTime.now()
                                    .toIso8601String(), // Default date
                            _yangDimintaController.text,
                            _mapNameToStatus(_status),
                            _alamatController.text,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pesanan updated successfully'),
                            ),
                          );

                          Navigator.pop(context, updatedPesanan);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white12,
      ),
      validator: validator,
    );
  }

  Widget _buildTextAreaFormField({
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: 4,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white12,
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownButtonFormField<T>({
    required T value,
    required List<T> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                item.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white12,
      ),
      dropdownColor: Colors.black, // Dropdown menu color
      iconEnabledColor: Colors.white, // Dropdown icon color
    );
  }

  Widget _buildButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: color),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
