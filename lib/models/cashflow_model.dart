class Cashflow {
  final int id;
  final String jenis;
  final int nominal;
  final String tanggal;
  final String deskripsi;
  final int? categoryId; // ID kategori (opsional, bisa null)
  final String? categoryName; // Nama kategori (opsional, bisa null)

  Cashflow({
    required this.id,
    required this.jenis,
    required this.nominal,
    required this.tanggal,
    required this.deskripsi,
    this.categoryId, // Tambahkan categoryId
    this.categoryName, // Tambahkan categoryName
  });

  factory Cashflow.fromJson(Map<String, dynamic> json) {
    return Cashflow(
      id: json['id'],
      jenis: json['jenis'],
      nominal: json['nominal'],
      tanggal: json['tanggal'],
      deskripsi: json['deskripsi'],
      categoryId: json['category_id'] != null
          ? int.parse(json['category_id'])
          : null, // Parsing category_id
      categoryName: json['category_name'], // Nama kategori
    );
  }
}
