import 'user.dart';

class Absensi {
  final int? id;
  final int userId;
  final DateTime tanggal;
  final String? jamMasuk;
  final String? jamKeluar;
  final String? lokasiMasuk;
  final String? lokasiKeluar;
  final String status;
  final bool isFakeGps;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  final User? user;

  Absensi({
    this.id,
    required this.userId,
    required this.tanggal,
    this.jamMasuk,
    this.jamKeluar,
    this.lokasiMasuk,
    this.lokasiKeluar,
    required this.status,
    required this.isFakeGps,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory Absensi.fromJson(Map<String, dynamic> json) {
    return Absensi(
      id: json['id'],
      userId: json['user_id'],
      tanggal: DateTime.parse(json['tanggal']),
      jamMasuk: json['jam_masuk'],
      jamKeluar: json['jam_keluar'],
      lokasiMasuk: json['lokasi_masuk'],
      lokasiKeluar: json['lokasi_keluar'],
      status: json['status'],
      isFakeGps: json['is_fake_gps'] == 1 || json['is_fake_gps'] == true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'tanggal': tanggal.toIso8601String().split('T')[0],
      'jam_masuk': jamMasuk,
      'jam_keluar': jamKeluar,
      'lokasi_masuk': lokasiMasuk,
      'lokasi_keluar': lokasiKeluar,
      'status': status,
      'is_fake_gps': isFakeGps,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      if (user != null) 'user': user!.toJson(),
    };
  }

  String? getFormattedJamMasuk() {
    return jamMasuk;
  }

  String? getFormattedJamKeluar() {
    return jamKeluar;
  }

  String getFormattedTanggal() {
    return "${tanggal.day.toString().padLeft(2, '0')}-${tanggal.month.toString().padLeft(2, '0')}-${tanggal.year}";
  }

  bool get hasCheckedIn => jamMasuk != null;

  bool get hasCheckedOut => jamKeluar != null;

  Absensi copyWith({
    int? id,
    int? userId,
    DateTime? tanggal,
    String? jamMasuk,
    String? jamKeluar,
    String? lokasiMasuk,
    String? lokasiKeluar,
    String? status,
    bool? isFakeGps,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
  }) {
    return Absensi(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tanggal: tanggal ?? this.tanggal,
      jamMasuk: jamMasuk ?? this.jamMasuk,
      jamKeluar: jamKeluar ?? this.jamKeluar,
      lokasiMasuk: lokasiMasuk ?? this.lokasiMasuk,
      lokasiKeluar: lokasiKeluar ?? this.lokasiKeluar,
      status: status ?? this.status,
      isFakeGps: isFakeGps ?? this.isFakeGps,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
    );
  }
}