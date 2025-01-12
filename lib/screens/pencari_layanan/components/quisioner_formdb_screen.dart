import 'package:flutter/material.dart';
import 'package:laundry_app/services/pesanan_services.dart';
import 'package:url_launcher/url_launcher.dart';

class CreatePesananScreen extends StatefulWidget {
  final int id;
  const CreatePesananScreen({super.key, required this.id});

  @override
  _CreatePesananScreenState createState() => _CreatePesananScreenState();
}

class _CreatePesananScreenState extends State<CreatePesananScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _quisionerController = TextEditingController();

  DateTime? _selectedDate;
  int _status = 1; // Default status

  @override
  void dispose() {
    _namaController.dispose();
    _noHpController.dispose();
    _alamatController.dispose();
    _quisionerController.dispose();
    super.dispose();
  }

  Future<void> _createPesanan() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Call the createPesanan service
        final createdPesanan = await PesananServices().createPesanan(
          _namaController.text,
          _noHpController.text,
          _selectedDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
          _quisionerController.text,
          _status,
          _alamatController.text,
          widget.id,
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan created successfully')),
        );

        // Send a message to WhatsApp
        await _sendMessageToWhatsApp(
          context,
          _noHpController.text,
          "Pesanan Anda berhasil dibuat.\n"
          "Nama: ${_namaController.text}\n"
          "Alamat: ${_alamatController.text}\n"
          "Tanggal: ${_selectedDate?.toIso8601String() ?? DateTime.now().toIso8601String()}\n"
          "Status: ${_status == 1 ? 'Menunggu Konfirmasi' : 'Dikonfirmasi'}\n"
          "Catatan: ${_quisionerController.text}",
        );

        // Return to the previous screen with the created Pesanan
        Navigator.pop(context, createdPesanan);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating Pesanan: $e')),
        );
      }
    }
  }

  void _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.black,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Pesanan'),
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
                controller: _namaController,
                hintText: 'Masukkan nama pelanggan',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama pelanggan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Nomor HP'),
              _buildTextFormField(
                controller: _noHpController,
                hintText: 'Masukkan nomor HP',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor HP tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Alamat Penjemputan'),
              _buildTextFormField(
                controller: _alamatController,
                hintText: 'Masukkan alamat penjemputan',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat penjemputan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Tanggal'),
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white38),
                  ),
                  child: Text(
                    _selectedDate == null
                        ? 'Pilih tanggal'
                        : _selectedDate!.toLocal().toString().split(' ')[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Quisioner'),
              _buildTextAreaFormField(
                controller: _quisionerController,
                hintText: 'Masukkan quisioner atau feedback',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Quisioner tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildButton(
                    label: 'Batal',
                    color: Colors.deepPurple,
                    onPressed: () => Navigator.pop(context),
                  ),
                  _buildButton(
                    label: 'Simpan',
                    color: Colors.green,
                    onPressed: _createPesanan,
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
    String? Function(String?)? validator,
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
    String? Function(String?)? validator,
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
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
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

Future<void> _sendMessageToWhatsApp(
    BuildContext context, String phoneNumber, String message) async {
  // Ensure the phone number is valid and formatted for WhatsApp
  final formattedPhoneNumber = phoneNumber.startsWith('+')
      ? phoneNumber
      : '+62$phoneNumber'; // Add country code if missing

  const noku = "+6288217707877";

  final url = "https://wa.me/$noku?text=${Uri.encodeComponent(message)}";

  if (await canLaunch(url)) {
    await launch(url);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tidak dapat mengirim pesan WhatsApp.'),
      ),
    );
  }
}
