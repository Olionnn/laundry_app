import 'package:flutter/material.dart';

class DetailRequestLayananScreen extends StatefulWidget {
  final int requestId;

  const DetailRequestLayananScreen({super.key, required this.requestId});

  @override
  _DetailRequestLayananScreenState createState() =>
      _DetailRequestLayananScreenState();
}

class _DetailRequestLayananScreenState
    extends State<DetailRequestLayananScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaPelangganController =
      TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  String _layanan = 'Cuci dan Setrika';
  String _status = 'Menunggu Konfirmasi';

  @override
  void initState() {
    super.initState();
    // Initialize controllers with default values
    _namaPelangganController.text = 'John Doe';
    _alamatController.text = 'Jl. Contoh No. 456, Jakarta';
  }

  @override
  void dispose() {
    _namaPelangganController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Request ${widget.requestId}'),
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
              _buildSectionTitle('Layanan yang Diminta'),
              _buildDropdownButtonFormField<String>(
                value: _layanan,
                items: <String>[
                  'Cuci dan Setrika',
                  'Cuci Saja',
                  'Setrika Saja'
                ],
                onChanged: (value) => setState(() => _layanan = value!),
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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Handle save logic
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
  }) {
    return TextFormField(
      controller: controller,
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
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white12,
      ),
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
