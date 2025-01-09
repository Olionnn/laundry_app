import 'package:flutter/material.dart';
import 'package:laundry_app/screens/penyedia_layanan/components/main_layout.dart';

class HalamanPenyediaLayanan extends StatelessWidget {
  const HalamanPenyediaLayanan({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Dashboard Penyedia Layanan',
      currentIndex: 0,
      onTabTapped: (index) {
        // Handle navigation between tabs
        if (index == 1) {
          Navigator.pushNamed(context, '/profile_layanan');
        } else if (index == 2) {
          Navigator.pushNamed(context, '/');
        }
      },
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.2,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              // Navigasi ke Detail Request dengan ID
              Navigator.pushNamed(
                context,
                '/detail_request_layanan',
                arguments: index + 1, // Kirim ID request sebagai argument
              );
            },
            child: Card(
              color: Colors.white12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.local_laundry_service,
                      size: 40,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Request ${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Detail layanan...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
