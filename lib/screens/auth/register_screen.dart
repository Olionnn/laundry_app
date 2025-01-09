import 'package:flutter/material.dart';
import 'package:laundry_app/services/auth_services.dart';
import 'package:laundry_app/widgets/responsive_container.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _authService = AuthService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _noHpController = TextEditingController();
  final _alamatController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    setState(() => _isLoading = true);

    try {
      await _authService.register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
        _noHpController.text,
        2, // Role ID untuk pengguna
        _alamatController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveContainer(
        child: Column(
          children: [
            const Spacer(),
            const Text(
              'NAMA APP',
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 50),
            _buildTextField('Nama', _nameController),
            const SizedBox(height: 20),
            _buildTextField('Email', _emailController),
            const SizedBox(height: 20),
            _buildTextField('Password', _passwordController, obscureText: true),
            const SizedBox(height: 20),
            _buildTextField('Nomor Handphone', _noHpController),
            const SizedBox(height: 20),
            _buildTextField('Alamat', _alamatController),
            const SizedBox(height: 40),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _handleRegister,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 40),
                    ),
                    child: const Text('REGISTER'),
                  ),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/login'),
              child: const Text(
                'Sudah punya akun? Login',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
