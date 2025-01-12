import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class QuisionerLayananScreen extends StatelessWidget {
  final String phoneNumber;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController quisionerController = TextEditingController();

  QuisionerLayananScreen({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    // Pre-fill the phone number
    phoneNumberController.text = phoneNumber;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quisioner Layanan"),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: ListView(
            children: [
              _buildSectionTitle('Nama'),
              _buildTextFormField(
                controller: nameController,
                hintText: 'Masukkan nama Anda',
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Nomor Telepon'),
              _buildTextFormField(
                controller: phoneNumberController,
                hintText: 'Masukkan nomor telepon',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Alamat'),
              _buildTextFormField(
                controller: addressController,
                hintText: 'Masukkan alamat Anda',
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Quisioner'),
              _buildTextAreaFormField(
                controller: quisionerController,
                hintText: 'Masukkan quisioner atau feedback',
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  final phone = phoneNumberController.text.trim();
                  final address = addressController.text.trim();
                  final quisioner = quisionerController.text.trim();

                  if (name.isEmpty ||
                      phone.isEmpty ||
                      address.isEmpty ||
                      quisioner.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Semua field harus diisi."),
                      ),
                    );
                    return;
                  }

                  _openWhatsApp(context, phone,
                      "Nama: $name\nAlamat: $address\nQuisioner: $quisioner");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                child: const Text(
                  "Kirim ke WhatsApp",
                  style: TextStyle(color: Colors.white),
                ),
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
    );
  }

  Widget _buildTextAreaFormField({
    required TextEditingController controller,
    required String hintText,
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
    );
  }

  void _openWhatsApp(
      BuildContext context, String phoneNumber, String message) async {
    phoneNumber = "+6288217707877";
    final url =
        "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tidak dapat membuka WhatsApp. Coba lagi nanti."),
        ),
      );
    }
  }
}
