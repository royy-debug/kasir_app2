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
  final ValueNotifier<String> _metodePembayaran = ValueNotifier("Cash");
  late final double _totalHarga;

  @override
  void initState() {
    super.initState();
    _totalHarga = widget.cart.entries.fold(
      0,
      (sum, entry) => sum + (entry.key.harga * entry.value),
    );
  }

  void _tampilkanQRIS(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Pembayaran Non-Cash", textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "assets/images/qris_gopay.jpg",
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            const Text(
              "Silakan scan QR GoPay di atas untuk menyelesaikan pembayaran.\n"
              "Klik 'Selesai' setelah pembayaran berhasil.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _prosesPembayaran();
            },
            child: const Text("Selesai"),
          ),
        ],
      ),
    );
  }

  Future<void> _prosesPembayaran() async {
    try {
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

      await _service.simpanTransaksi(
        cart: widget.cart,
        metode: _metodePembayaran.value,
        total: _totalHarga,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DetailPembayaranScreen(
              cart: widget.cart,
              totalHarga: _totalHarga,
              metode: _metodePembayaran.value,
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
  void dispose() {
    _metodePembayaran.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pembayaran")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(child: _CartList(cart: widget.cart)),

            const Divider(),
            ListTile(
              title: const Text(
                "Total",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Text(
                "Rp $_totalHarga",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ✅ Dropdown hanya rebuild sendiri
            ValueListenableBuilder<String>(
              valueListenable: _metodePembayaran,
              builder: (context, metode, _) {
                return DropdownButtonFormField<String>(
                  value: metode,
                  items: const [
                    DropdownMenuItem(value: "Cash", child: Text("Cash")),
                    DropdownMenuItem(
                        value: "Non-Cash",
                        child: Text("Non-Cash (Transfer, e-Wallet)")),
                  ],
                  onChanged: (val) => _metodePembayaran.value = val!,
                  decoration: const InputDecoration(
                    labelText: "Metode Pembayaran",
                    border: OutlineInputBorder(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // ✅ Tombol bayar terpisah
            _TombolBayar(
              metodePembayaran: _metodePembayaran,
              prosesPembayaran: _prosesPembayaran,
              tampilkanQRIS: _tampilkanQRIS,
            ),
          ],
        ),
      ),
    );
  }
}

// 🔹 ListView pakai builder (lebih efisien)
class _CartList extends StatelessWidget {
  final Map<Obat, int> cart;
  const _CartList({required this.cart});

  @override
  Widget build(BuildContext context) {
    final entries = cart.entries.toList();
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final obat = entry.key;
        final jumlah = entry.value;
        return ListTile(
          title: Text(obat.nama),
          subtitle: Text("Jumlah: $jumlah x Rp${obat.harga}"),
          trailing: Text("Rp ${obat.harga * jumlah}"),
        );
      },
    );
  }
}

// 🔹 Tombol bayar dipisah biar gak rebuild
class _TombolBayar extends StatelessWidget {
  final ValueNotifier<String> metodePembayaran;
  final Future<void> Function() prosesPembayaran;
  final void Function(BuildContext) tampilkanQRIS;

  const _TombolBayar({
    required this.metodePembayaran,
    required this.prosesPembayaran,
    required this.tampilkanQRIS,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: metodePembayaran,
      builder: (context, metode, _) {
        return ElevatedButton.icon(
          onPressed: () {
            if (metode == "Cash") {
              prosesPembayaran();
            } else {
              tampilkanQRIS(context);
            }
          },
          icon: const Icon(Icons.check),
          label: const Text("Bayar Sekarang"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            minimumSize: const Size(double.infinity, 50),
          ),
        );
      },
    );
  }
}
