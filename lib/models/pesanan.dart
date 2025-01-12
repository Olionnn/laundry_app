class Pesanan {
  final int id;
  final String pNama;
  final String pNoHp;
  final String pDate;
  final String pQuisioner;
  final int pStatus;
  final String pAlamat;
  final int layananId;
  final String createdAt;
  final String updatedAt;

  Pesanan({
    required this.id,
    required this.pNama,
    required this.pNoHp,
    required this.pDate,
    required this.pQuisioner,
    required this.pStatus,
    required this.pAlamat,
    required this.layananId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pesanan.fromJson(Map<String, dynamic> json) {
    return Pesanan(
      id: json['id'] ?? 0, // Provide a default value for 'id'
      pNama: json['p_nama'] ?? '', // Default to empty string
      pNoHp: json['p_no_hp'] ?? '', // Default to empty string
      pDate: json['p_date'] ??
          DateTime.now().toIso8601String(), // Default to current date
      pQuisioner: json['p_quisioner'] ?? '', // Default to empty string
      pStatus: json['p_status'] ?? 0, // Default to 0
      pAlamat: json['p_alamat'] ?? '', // Default to empty string
      layananId: json['layanan_id'] ?? 0, // Default to 0
      createdAt: json['created_at'] ??
          DateTime.now().toIso8601String(), // Default to current date
      updatedAt: json['updated_at'] ??
          DateTime.now().toIso8601String(), // Default to current date
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'p_nama': pNama,
      'p_no_hp': pNoHp,
      'p_date': pDate,
      'p_quisioner': pQuisioner,
      'p_status': pStatus,
      'p_alamat': pAlamat,
      'layanan_id': layananId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
