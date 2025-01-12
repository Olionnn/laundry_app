import 'package:flutter/material.dart';
import 'package:laundry_app/services/auth_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainLayout extends StatelessWidget {
  final String title;
  final Widget body;
  final int currentIndex;
  final Function(int) onTabTapped;

  MainLayout({
    super.key,
    required this.title,
    required this.body,
    required this.currentIndex,
    required this.onTabTapped,
  });

  @override
  @override
  Widget build(BuildContext context) {
    AuthService authService = AuthService();

    return FutureBuilder<bool>(
      future: authService.checkToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text(title),
              backgroundColor: Colors.deepPurple,
            ),
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text(title),
              backgroundColor: Colors.deepPurple,
            ),
            backgroundColor: Colors.black,
            body: body,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: onTabTapped,
              backgroundColor: Colors.deepPurple,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.grey,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.map),
                  label: 'Maps',
                ),
                snapshot.data == true
                    ? const BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Dashboard',
                      )
                    : const BottomNavigationBarItem(
                        icon: Icon(Icons.login),
                        label: 'Login',
                      ),
              ],
            ),
          );
        }
      },
    );
  }
}
