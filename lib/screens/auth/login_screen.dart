import 'package:flutter/material.dart';
import 'package:laundry_app/routes/app_routes.dart';
import 'package:laundry_app/services/auth_services.dart';
import 'package:laundry_app/services/penyedia_layanan_services.dart';
import 'package:laundry_app/widgets/responsive_container.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveContainer(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Spacer(),
              const Text(
                'NAMA APP',
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 50),
              _buildTextField(
                'Email / Nomor Handphone',
                emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harap masukkan email atau nomor handphone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                'Password',
                passwordController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harap masukkan password';
                  }
                  if (value.length < 6) {
                    return 'Password harus lebih dari 6 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      // Call login service
                      final response = await authService.login(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                      );

                      // Extract user ID from login response
                      final userId = response['data']['user']['id'];
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Login berhasil! Selamat datang ${response['data']['user']['name']}',
                          ),
                        ),
                      );

                      // Check penyedia_layanan using user_id
                      final penyediaResponse =
                          await PenyediaLayananService.getPenyediaLayanan(
                        page: 1,
                        limit: 2,
                        userId: userId,
                      );

                      // If data is empty, redirect to penyedia_layanan profile
                      if ((penyediaResponse['data'] as List).isEmpty) {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.profileLayanan,
                        );
                      } else {
                        // Redirect to request layanan
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.requestLayanan,
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Login gagal: ${e.toString()}')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                ),
                child: const Text('LOGIN'),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/register'),
                child: const Text(
                  'Tidak punya akun? Tekan untuk membuat akun',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hintText,
    TextEditingController controller, {
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
