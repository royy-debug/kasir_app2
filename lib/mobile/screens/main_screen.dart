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

  // ✅ Jangan langsung taruh ObatFormScreen di _pages
  static final List<Widget> _pages = [
    const DashboardScreen(),
    const ObatListScreen(),
    const SizedBox(), // placeholder untuk Tambah Produk
  ];

  static const List<String> _titles = [
    "Dashboard",
    "Produk",
    "Tambah Produk",
  ];

  void _onItemTapped(int index) async {
    if (index == 2) {
      // 🔹 Kalau tab Tambah Produk dipilih, buka form pakai push
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ObatFormScreen()),
      );

      // 🔹 Kalau hasilnya "goToProduk", pindah ke tab Produk
      if (result == "goToProduk") {
        setState(() => _selectedIndex = 1);
      }
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
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
