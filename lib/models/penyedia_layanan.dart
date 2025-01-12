class PenyediaLayanan {
  final int id;
  final String namaToko;
  final double long;
  final double lat;
  final String alamat;
  final int userId;
  final String deskripsi;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? ownerName; // Owner's name
  final String? ownerPhone; // Owner's phone number
  final String? ownerEmail; // Owner's email

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
    this.ownerName,
    this.ownerPhone,
    this.ownerEmail,
  });

  factory PenyediaLayanan.fromJson(Map<String, dynamic> json) {
    final user = json['user']; // Extract the 'user' object
    return PenyediaLayanan(
      id: json['id'] ?? 0, // Default to 0 if 'id' is null
      namaToko: json['nama_toko'] ?? 'Unknown', // Default to 'Unknown'
      long: double.tryParse(json['long']?.toString() ?? '0') ?? 0.0,
      lat: double.tryParse(json['lat']?.toString() ?? '0') ?? 0.0,
      alamat: json['alamat'] ?? 'Alamat tidak tersedia',
      userId: json['user_id'] ?? 0,
      deskripsi: json['deskripsi'] ?? 'Deskripsi tidak tersedia',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      ownerName: (user != null && user['name'] != null) ? user['name'] : null,
      ownerPhone:
          (user != null && user['no_hp'] != null) ? user['no_hp'] : null,
      ownerEmail:
          (user != null && user['email'] != null) ? user['email'] : null,
    );
  }

  Map<String, dynamic>? toJson() {
    return {
      'id': id,
      'nama_toko': namaToko,
      'long': long,
      'lat': lat,
      'alamat': alamat,
      'user_id': userId,
      'deskripsi': deskripsi,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user': {
        'name': ownerName,
        'no_hp': ownerPhone,
        'email': ownerEmail,
      },
    };
  }
}

class PenyediaLayananList {
  final int id;
  final String namaToko;
  final String long;
  final String lat;
  final String alamat;
  final int userId;
  final String deskripsi;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? distance; // Distance from user's location

  PenyediaLayananList(
      {required this.id,
      required this.namaToko,
      required this.long,
      required this.lat,
      required this.alamat,
      required this.userId,
      required this.deskripsi,
      required this.createdAt,
      required this.updatedAt,
      this.distance});

  factory PenyediaLayananList.fromJson(Map<String, dynamic> json) {
    return PenyediaLayananList(
      id: json['id'],
      namaToko: json['nama_toko'],
      long: json['long'],
      lat: json['lat'],
      alamat: json['alamat'],
      userId: json['user_id'],
      deskripsi: json['deskripsi'],
      distance: json['distance'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic>? toJson() {
    return {
      'id': id,
      'nama_toko': namaToko,
      'long': long,
      'lat': lat,
      'alamat': alamat,
      'user_id': userId,
      'deskripsi': deskripsi,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
