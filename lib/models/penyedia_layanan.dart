class PenyediaLayanan {
  final int id;
  final String namaToko;
  final String long;
  final String lat;
  final String alamat;
  final int userId;
  final String deskripsi;
  final DateTime createdAt;
  final DateTime updatedAt;

  PenyediaLayanan({
    required this.id,
    required this.namaToko,
    required this.long,
    required this.lat,
    required this.alamat,
    required this.userId,
    required this.deskripsi,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PenyediaLayanan.fromJson(Map<String, dynamic> json) {
    return PenyediaLayanan(
      id: json['id'],
      namaToko: json['nama_toko'],
      long: json['long'],
      lat: json['lat'],
      alamat: json['alamat'],
      userId: json['user_id'],
      deskripsi: json['deskripsi'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
