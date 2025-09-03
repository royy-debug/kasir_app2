import 'package:flutter/material.dart';
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

  late TextEditingController _namaCtrl;
  late TextEditingController _kategoriCtrl;
  late TextEditingController _stokCtrl;
  late TextEditingController _hargaCtrl;

  @override
  void initState() {
    super.initState();
    _namaCtrl = TextEditingController(text: widget.obat?.nama ?? '');
    _kategoriCtrl = TextEditingController(text: widget.obat?.kategori ?? '');
    _stokCtrl = TextEditingController(text: widget.obat?.stok?.toString() ?? '');
    _hargaCtrl = TextEditingController(text: widget.obat?.harga?.toString() ?? '');
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _kategoriCtrl.dispose();
    _stokCtrl.dispose();
    _hargaCtrl.dispose();
    super.dispose();
  }

void _saveData() async {
  if (_formKey.currentState!.validate()) {
    final obat = Obat(
      id: widget.obat?.id, // biarkan null kalau tambah
      nama: _namaCtrl.text,
      kategori: _kategoriCtrl.text,
      stok: int.tryParse(_stokCtrl.text) ?? 0,
      harga: double.tryParse(_hargaCtrl.text) ?? 0.0,
    );

    if (widget.obat == null) {
      // tambah
      await _service.tambahObat(obat);
    } else {
      // update (pastikan id tidak null)
      await _service.updateObat(widget.obat!.id!, obat);
    }

    if (mounted) Navigator.pop(context);
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
                validator: (value) => value!.isEmpty ? "Nama wajib diisi" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _kategoriCtrl,
                decoration: const InputDecoration(labelText: "Kategori"),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stokCtrl,
                decoration: const InputDecoration(labelText: "Stok"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _hargaCtrl,
                decoration: const InputDecoration(labelText: "Harga"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _saveData,
                icon: const Icon(Icons.save),
                label: const Text("Simpan", style: TextStyle(fontSize: 16)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
