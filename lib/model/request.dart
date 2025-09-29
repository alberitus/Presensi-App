import 'user.dart';

class RequestModel {
  final int? id;
  final int userId;
  final String status;
  final String? keterangan;
  final DateTime tanggalMulai;
  final DateTime? tanggalSelesai;
  final String? buktiDokumen;       // URL/file path bukti dokumen
  final bool isApproved;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final User? user;

  RequestModel({
    this.id,
    required this.userId,
    required this.status,
    this.keterangan,
    required this.tanggalMulai,
    this.tanggalSelesai,
    this.buktiDokumen,
    required this.isApproved,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  /// Factory untuk membuat object dari JSON
  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: json['id'],
      userId: json['user_id'],
      status: json['status'],
      keterangan: json['keterangan'],
      tanggalMulai: DateTime.parse(json['tanggal_mulai']),
      tanggalSelesai: json['tanggal_selesai'] != null
          ? DateTime.tryParse(json['tanggal_selesai'])
          : null,
      buktiDokumen: json['bukti_dokumen'],
      isApproved: json['is_approved'] == 1 || json['is_approved'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  /// Konversi object ke JSON untuk kirim ke API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'status': status,
      'keterangan': keterangan,
      'tanggal_mulai': tanggalMulai.toIso8601String().split('T')[0],
      'tanggal_selesai':
          tanggalSelesai?.toIso8601String().split('T')[0],
      'bukti_dokumen': buktiDokumen,
      'is_approved': isApproved,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      if (user != null) 'user': user!.toJson(),
    };
  }

  /// Format tanggal untuk ditampilkan (dd-MM-yyyy)
  String getFormattedTanggalMulai() {
    return "${tanggalMulai.day.toString().padLeft(2, '0')}-${tanggalMulai.month.toString().padLeft(2, '0')}-${tanggalMulai.year}";
  }

  String? getFormattedTanggalSelesai() {
    if (tanggalSelesai == null) return null;
    return "${tanggalSelesai!.day.toString().padLeft(2, '0')}-${tanggalSelesai!.month.toString().padLeft(2, '0')}-${tanggalSelesai!.year}";
  }

  /// Untuk clone/update data dengan nilai baru
  RequestModel copyWith({
    int? id,
    int? userId,
    String? status,
    String? keterangan,
    DateTime? tanggalMulai,
    DateTime? tanggalSelesai,
    String? buktiDokumen,
    bool? isApproved,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
  }) {
    return RequestModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      keterangan: keterangan ?? this.keterangan,
      tanggalMulai: tanggalMulai ?? this.tanggalMulai,
      tanggalSelesai: tanggalSelesai ?? this.tanggalSelesai,
      buktiDokumen: buktiDokumen ?? this.buktiDokumen,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
    );
  }
}
