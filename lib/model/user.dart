class User {
  final int id;
  final String nik;
  final String namaLengkap;
  final String division;
  final DateTime tanggalMasuk;
  final String statusKaryawan;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.nik,
    required this.namaLengkap,
    required this.division,
    required this.tanggalMasuk,
    required this.statusKaryawan,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nik: json['nik'],
      namaLengkap: json['nama_lengkap'],
      division: json['division'],
      tanggalMasuk: DateTime.parse(json['tanggal_masuk']),
      statusKaryawan: json['status_karyawan'],
      role: json['role'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nik': nik,
      'nama_lengkap': namaLengkap,
      'division': division,
      'tanggal_masuk': tanggalMasuk.toIso8601String(),
      'status_karyawan': statusKaryawan,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}