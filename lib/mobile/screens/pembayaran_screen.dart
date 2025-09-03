import 'package:flutter/material.dart';
import '../models/obat_detail.dart';
import '../services/obat_service.dart';
import 'detail_pembayaran_screen.dart';
class PembayaranScreen extends StatefulWidget {
  final Map<Obat, int> cart;

  const PembayaranScreen({super.key, required this.cart});

  @override
  State<PembayaranScreen> createState() => _PembayaranScreenState();
}

class _PembayaranScreenState extends State<PembayaranScreen> {
  final _service = ObatService();
  String _metodePembayaran = "Cash";
  late final double _totalHarga; // ✅ dihitung sekali aja

  @override
  void initState() {
    super.initState();
    _totalHarga = widget.cart.entries.fold(
      0,
      (sum, entry) => sum + (entry.key.harga * entry.value),
    );
  }

  Future<void> _prosesPembayaran() async {
    try {
      // 🔹 Step 1: cek & update stok lewat service
      for (var entry in widget.cart.entries) {
        final obat = entry.key;
        final jumlah = entry.value;

        final stokTerbaru = await _service.getStokById(obat.id!);

        if (stokTerbaru >= jumlah) {
          await _service.updateStok(obat.id!, stokTerbaru - jumlah);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Stok ${obat.nama} tidak mencukupi ❌")),
            );
          }
          return;
        }
      }

      // 🔹 Step 2: simpan transaksi lewat service
      await _service.simpanTransaksi(
        cart: widget.cart,
        metode: _metodePembayaran,
        total: _totalHarga,
      );

      // 🔹 Step 3: pindah ke struk pembayaran
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DetailPembayaranScreen(
              cart: widget.cart,
              totalHarga: _totalHarga,
              metode: _metodePembayaran,
            ),
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pembayaran berhasil ✅")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Pembayaran gagal: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pembayaran")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ Pisahkan ke widget agar gak rebuild tiap kali state kecil berubah
            Expanded(child: _CartList(cart: widget.cart)),

            const Divider(),
            ListTile(
              title: const Text("Total",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: Text(
                "Rp $_totalHarga",
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),

            // ✅ hanya dropdown ini yang trigger rebuild
            DropdownButtonFormField<String>(
              value: _metodePembayaran,
              items: const [
                DropdownMenuItem(value: "Cash", child: Text("Cash")),
                DropdownMenuItem(
                    value: "Non-Cash",
                    child: Text("Non-Cash (Transfer, e-Wallet)")),
              ],
              onChanged: (val) => setState(() => _metodePembayaran = val!),
              decoration: const InputDecoration(
                labelText: "Metode Pembayaran",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _prosesPembayaran,
              icon: const Icon(Icons.check),
              label: const Text("Bayar Sekarang"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// 🔹 widget terpisah biar gak ikut rebuild
class _CartList extends StatelessWidget {
  final Map<Obat, int> cart;

  const _CartList({required this.cart});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: cart.entries.map((entry) {
        final obat = entry.key;
        final jumlah = entry.value;
        return ListTile(
          title: Text(obat.nama),
          subtitle: Text("Jumlah: $jumlah x Rp${obat.harga}"),
          trailing: Text("Rp ${obat.harga * jumlah}"),
        );
      }).toList(),
    );
  }
}
