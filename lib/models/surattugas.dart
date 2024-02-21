// ignore_for_file: non_constant_identifier_names, unnecessary_question_mark

class SuratTugas {
  final int? id;
  final int? id_surat_tugas;
  final dynamic no_surat;
  final String? tgl_inspeksi;
  final int? status;
  final int? userId;
  final int? jenis_pengawasan_id;
  late final dynamic? nama_perusahaan;
  final String? komoditas_perusahaan;

  
  SuratTugas(
      {
        this.id,
      this.id_surat_tugas,
      this.no_surat,
      this.tgl_inspeksi,
      this.status,
      this.userId,
      this.jenis_pengawasan_id,
      this.nama_perusahaan,
      this.komoditas_perusahaan
    }
  );

  factory SuratTugas.fromMap(Map<String, dynamic> map){
    return SuratTugas(
      id: map['id'],
      id_surat_tugas: map['id_surat_tugas'],
      no_surat: map['no_surat'],
      tgl_inspeksi: map['tgl_inspeksi'].toString(),
      status: map['status'],
      userId: map['userId'],
      jenis_pengawasan_id: map['jenis_pengawasan_id'],
      nama_perusahaan: map['nama_perusahaan'],
      komoditas_perusahaan: map['komoditas_perusahaan']
    );
  }

  factory SuratTugas.fromJson(Map<String, dynamic> json){
    return SuratTugas(
      id: json['id'],
      id_surat_tugas: json['surat_tugas']['id'],
      no_surat: json['surat_tugas']['no_surat'],
      tgl_inspeksi: json['surat_tugas']['tgl_inspeksi'],
      status: json['status'],
      userId: json['user_id'],
      jenis_pengawasan_id: json['surat_tugas']['jenis_pengawasan'],
      nama_perusahaan: json['surat_tugas']['nama_perusahaan'],
      komoditas_perusahaan: json['surat_tugas']['komoditas_perusahaan']
    );
  }

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'id_surat_tugas': id_surat_tugas,
      'no_surat': no_surat.toString(),
      'tgl_inspeksi': tgl_inspeksi,
      'status': status,
      'userId': userId,
      'jenis_pengawasan_id': jenis_pengawasan_id,
      'nama_perusahaan': nama_perusahaan.toString(),
      'komoditas_perusahaan': komoditas_perusahaan
    };
  }
}