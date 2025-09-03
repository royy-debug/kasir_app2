class Obat {
  final String? id; // nullable, biar bisa null saat tambah
  final String nama;
  final String kategori;
  final int stok;
  final double harga;

  Obat({
    this.id, // tidak wajib diisi
    required this.nama,
    required this.kategori,
    required this.stok,
    required this.harga,
  });

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'kategori': kategori,
      'stok': stok,
      'harga': harga,
    };
  }

  factory Obat.fromMap(Map<String, dynamic> map, String documentId) {
    return Obat(
      id: documentId, // dari Firestore documentId
      nama: map['nama'] ?? '',
      kategori: map['kategori'] ?? '',
      stok: map['stok'] ?? 0,
      harga: (map['harga'] ?? 0).toDouble(),
    );
  }
}
