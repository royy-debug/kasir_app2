import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/obat_detail.dart';

class ObatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Koleksi obat
  CollectionReference<Map<String, dynamic>> get _obatCollection =>
      _firestore.collection('obat');

  // ✅ Koleksi penjualan
  CollectionReference<Map<String, dynamic>> get _penjualanCollection =>
      _firestore.collection('penjualan');

  // ✅ Stream list obat
  Stream<List<Obat>> getObatList() {
    return _obatCollection.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => Obat.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }

  // ✅ Tambah obat
  Future<void> tambahObat(Obat obat) async {
    await _obatCollection.add({
      'nama': obat.nama,
      'kategori': obat.kategori,
      'stok': obat.stok,
      'harga': obat.harga,
    });
  }

  // ✅ Update obat
  Future<void> updateObat(String id, Obat obat) async {
    await _obatCollection.doc(id).update({
      'nama': obat.nama,
      'kategori': obat.kategori,
      'stok': obat.stok,
      'harga': obat.harga,
    });
  }

  // ✅ Hapus obat
   Future<void> deleteObat(String id) async {
    try {
      await _obatCollection.doc(id).delete();
    } catch (e) {
      throw Exception("Gagal menghapus obat: $e");
    }
  }


  // ✅ Ambil stok terbaru
  Future<int> getStokById(String id) async {
    final doc = await _obatCollection.doc(id).get();
    final data = doc.data();
    return (data?['stok'] as num?)?.toInt() ?? 0;
  }

  // ✅ Update stok manual
  Future<void> updateStok(String id, int stokBaru) async {
    await _obatCollection.doc(id).update({'stok': stokBaru});
  }

  // ✅ Kurangi stok saat transaksi
  Future<void> kurangiStok(String id, int jumlah) async {
    final ref = _obatCollection.doc(id);

    await _firestore.runTransaction((trx) async {
      final snapshot = await trx.get(ref);
      final stokLama = (snapshot['stok'] as num).toInt();
      if (stokLama < jumlah) {
        throw Exception("Stok tidak cukup");
      }
      trx.update(ref, {'stok': stokLama - jumlah});
    });
  }

  // ✅ Simpan transaksi
  Future<void> simpanTransaksi({
  required Map<Obat, int> cart,
  required String metode,
  required double total,
}) async {
  final items = cart.entries.map((e) => {
    "obatId": e.key.id,
    "nama": e.key.nama,
    "harga": e.key.harga,
    "jumlah": e.value,
  }).toList();

  await FirebaseFirestore.instance.collection('penjualan').add({
    "tanggal": DateTime.now(),
    "metode": metode,
    "total": total,
    "items": items,
  });
}

}
