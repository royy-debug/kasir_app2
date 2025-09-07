import 'package:flutter/material.dart';
import '../models/obat_detail.dart';
import '../services/obat_service.dart';
import 'obat_form_screen.dart';
import 'pembayaran_screen.dart';

class ObatListScreen extends StatefulWidget {
  const ObatListScreen({super.key});

  @override
  State<ObatListScreen> createState() => _ObatListScreenState();
}

class _ObatListScreenState extends State<ObatListScreen> {
  final _service = ObatService();
  final Map<String, int> _cart = {};
  List<Obat> _obatList = [];

  void _tambahObat(Obat obat) {
    if (obat.stok > (_cart[obat.id] ?? 0)) {
      setState(() => _cart[obat.id!] = (_cart[obat.id] ?? 0) + 1);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Stok tidak mencukupi")),
      );
    }
  }

  void _kurangiObat(Obat obat) {
    if ((_cart[obat.id] ?? 0) > 0) {
      setState(() {
        _cart[obat.id!] = _cart[obat.id]! - 1;
        if (_cart[obat.id] == 0) _cart.remove(obat.id);
      });
    }
  }

  void _batalPesanan() {
    setState(() => _cart.clear());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Pesanan dibatalkan")),
    );
  }

  void _showOptions(Obat obat) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text("Edit Obat"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ObatFormScreen(obat: obat)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("Hapus Obat"),
              onTap: () async {
                Navigator.pop(context);
                await _service.deleteObat(obat.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Obat berhasil dihapus")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Obat>>(
      stream: _service.getObatList(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        _obatList = snapshot.data ?? [];
        if (_obatList.isEmpty) {
          return const Center(child: Text("Belum ada data obat"));
        }

        return Stack(
          children: [
            GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: _obatList.length,
              itemBuilder: (_, i) {
                final obat = _obatList[i];
                final jumlahDipilih = _cart[obat.id] ?? 0;

                return GestureDetector(
                  onLongPress: () => _showOptions(obat),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16)),
                            ),
                            child: const Center(
                              child: Icon(Icons.medical_services,
                                  size: 50, color: Colors.grey),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(obat.nama,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Text("Kategori: ${obat.kategori}",
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey[600])),
                              Text("Stok: ${obat.stok}",
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey[600])),
                              const SizedBox(height: 6),
                              Text("Rp ${obat.harga}",
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: jumlahDipilih == 0
                                ? ElevatedButton(
                                    key: ValueKey("TambahBtn-${obat.id}"),
                                    onPressed: () => _tambahObat(obat),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      minimumSize:
                                          const Size(double.infinity, 40),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text("Tambah"),
                                  )
                                : Row(
                                    key: ValueKey("CounterRow-${obat.id}"),
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        onPressed: () => _kurangiObat(obat),
                                        icon: const Icon(Icons.remove_circle,
                                            color: Colors.red),
                                      ),
                                      Text("$jumlahDipilih",
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                      IconButton(
                                        onPressed: () => _tambahObat(obat),
                                        icon: const Icon(Icons.add_circle,
                                            color: Colors.green),
                                      ),
                                    ],
                                  ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),

            // FAB tetap muncul di luar GridView
            if (_cart.isNotEmpty)
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton.extended(
                  onPressed: () async {
                    final selectedCart = {
                      for (var obat in _obatList)
                        if (_cart.containsKey(obat.id)) obat: _cart[obat.id]!,
                    };

                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PembayaranScreen(cart: selectedCart),
                      ),
                    );

                    if (result == true) setState(() => _cart.clear());
                  },
                  icon: const Icon(Icons.payment),
                  label: Text("Bayar (${_cart.length})"),
                ),
              ),
          ],
        );
      },
    );
  }
}
