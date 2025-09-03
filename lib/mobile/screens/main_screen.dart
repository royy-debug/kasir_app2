import 'package:flutter/material.dart';
import 'package:kasir_app2/mobile/utils/constants.dart';
import 'package:kasir_app2/mobile/screens/dashboard_screen.dart';
import 'package:kasir_app2/mobile/screens/obat_list_screen.dart';
import 'package:kasir_app2/mobile/screens/obat_form_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // ✅ Jadikan static final supaya tidak dibuat ulang saat rebuild
  static final List<Widget> _pages = [
    const DashboardScreen(),   // jangan ada AppBar di dalam screen ini
    const ObatListScreen(),
    const ObatFormScreen(),
  ];

  static const List<String> _titles = [
    "Dashboard",
    "Produk",
    "Tambah Produk",
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    // ✅ Tidak perlu Navigator pushReplacement
    // karena Wrapper/StreamBuilder di main.dart yang akan redirect ke AuthScreen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),

      // ✅ IndexedStack simpan state tiap halaman
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            activeIcon: Icon(Icons.add_box),
            label: 'Tambah',
          ),
        ],
      ),
    );
  }
}
