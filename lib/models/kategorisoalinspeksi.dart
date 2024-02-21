// ignore_for_file: non_constant_identifier_names, unnecessary_question_mark

class KategoriSoalInspeksi {
  final int? id_soal_kategori;
  final int? id_kategori;
  final dynamic? nama_kategori;
  final int? surat_tugas_id;

  KategoriSoalInspeksi({
    this.id_kategori,
    this.id_soal_kategori,
    this.nama_kategori,
    this.surat_tugas_id,
  });

  factory KategoriSoalInspeksi.fromMap(Map<String, dynamic> map){
    return KategoriSoalInspeksi(
      id_kategori: map['id_kategori'],
      id_soal_kategori: map['id_soal_kategori'],
      nama_kategori: map['nama_kategori'],
      surat_tugas_id: map['surat_tugas_id'],
    );
  }

  factory KategoriSoalInspeksi.fromJson(Map<String, dynamic> json){
    return KategoriSoalInspeksi(
      id_kategori: json['id_kategori'],
      id_soal_kategori: json['id_soal_kategori'],
      nama_kategori: json['nama_kategori'],
      surat_tugas_id: json['surat_tugas_id'],
    );
  }

  Map<String, dynamic> toMap(){
    return {
      'id_kategori': id_kategori,
      'id_soal_kategori': id_soal_kategori,
      'nama_kategori': nama_kategori,
      'surat_tugas_id': surat_tugas_id,
    };
  }
  

}