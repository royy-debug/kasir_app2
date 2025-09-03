import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference _obatCollection =
      FirebaseFirestore.instance.collection('obat');

  // Ambil semua obat
  Stream<QuerySnapshot> getObatStream() {
    return _obatCollection.snapshots();
  }

  // Hitung jumlah obat terjual (untuk chart bar)
  Future<Map<String, int>> getSalesData() async {
    final snapshot = await _obatCollection.get();
    Map<String, int> salesData = {};

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final nama = data['nama'] ?? 'Unknown';
      final terjual = data['terjual'] ?? 0;

      salesData[nama] = terjual;
    }
    return salesData;
  }
}
