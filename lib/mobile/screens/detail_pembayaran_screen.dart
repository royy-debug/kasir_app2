import 'package:flutter/material.dart';
import '../models/obat_detail.dart';

class DetailPembayaranScreen extends StatelessWidget {
  final Map<Obat, int> cart;
  final double totalHarga;
  final String metode;

  const DetailPembayaranScreen({
    super.key,
    required this.cart,
    required this.totalHarga,
    required this.metode,
  });

  @override
  Widget build(BuildContext context) {
    final tanggal = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text("Struk Pembayaran")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("💊 Apotek Flutter",
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text("Tanggal: ${tanggal.toLocal()}"),
            Text("Metode: $metode"),
            const Divider(),
            Expanded(
              child: ListView(
                children: cart.entries.map((entry) {
                  final obat = entry.key;
                  final jumlah = entry.value;
                  return ListTile(
                    dense: true,
                    title: Text(obat.nama),
                    subtitle: Text("x$jumlah @Rp${obat.harga}"),
                    trailing: Text("Rp ${obat.harga * jumlah}"),
                  );
                }).toList(),
              ),
            ),
            const Divider(),
            Align(
              alignment: Alignment.centerRight,
              child: Text("Total: Rp $totalHarga",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // nanti bisa ditambah fitur cetak PDF / share
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Fitur cetak struk belum tersedia")),
                );
              },
              icon: const Icon(Icons.print),
              label: const Text("Cetak Struk"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
