import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/obat_detail.dart';
import '../services/obat_service.dart';

class ObatFormScreen extends StatefulWidget {
  final Obat? obat;
  const ObatFormScreen({super.key, this.obat});

  @override
  State<ObatFormScreen> createState() => _ObatFormScreenState();
}

class _ObatFormScreenState extends State<ObatFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ObatService();

  late final TextEditingController _namaCtrl;
  late final TextEditingController _kategoriCtrl;
  late final TextEditingController _stokCtrl;
  late final TextEditingController _hargaCtrl;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _namaCtrl = TextEditingController(text: widget.obat?.nama ?? '');
    _kategoriCtrl = TextEditingController(text: widget.obat?.kategori ?? '');
    _stokCtrl =
        TextEditingController(text: widget.obat?.stok?.toString() ?? '');
    _hargaCtrl =
        TextEditingController(text: widget.obat?.harga?.toString() ?? '');
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _kategoriCtrl.dispose();
    _stokCtrl.dispose();
    _hargaCtrl.dispose();
    super.dispose();
  }

  String? _required(String? value) =>
      (value == null || value.trim().isEmpty) ? "Wajib diisi" : null;

  String? _validInt(String? value) =>
      (value != null && value.isNotEmpty && int.tryParse(value) == null)
          ? "Harus angka bulat"
          : null;

  String? _validDouble(String? value) =>
      (value != null && value.isNotEmpty && double.tryParse(value) == null)
          ? "Harus angka"
          : null;

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final obat = Obat(
      id: widget.obat?.id,
      nama: _namaCtrl.text.trim(),
      kategori: _kategoriCtrl.text.trim(),
      stok: int.tryParse(_stokCtrl.text) ?? 0,
      harga: double.tryParse(_hargaCtrl.text) ?? 0.0,
    );

    try {
      if (widget.obat == null) {
        await _service.tambahObat(obat);
      } else {
        await _service.updateObat(widget.obat!.id!, obat);
      }

      if (mounted) Navigator.pop(context, "goToProduk"); // 🔹 kirim signal balik
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.obat == null ? "Tambah Obat" : "Edit Obat"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _namaCtrl,
                decoration: const InputDecoration(labelText: "Nama Obat"),
                validator: _required,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _kategoriCtrl,
                decoration: const InputDecoration(labelText: "Kategori"),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stokCtrl,
                decoration: const InputDecoration(labelText: "Stok"),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: _validInt,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _hargaCtrl,
                decoration: const InputDecoration(labelText: "Harga"),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: _validDouble,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _saving ? null : _saveData,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _saving ? "Menyimpan..." : "Simpan",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
