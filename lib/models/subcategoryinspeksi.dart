// ignore_for_file: non_constant_identifier_names, unnecessary_question_mark

class SubCategoryInspeksi{
  final int? id;
  final int? id_subkategori_inspeksi;
  final int? area_id;
  final int? subkategori_id; 
  final int? kategori_id;
  final int? surat_tugas_id;
  final String? nama_subkategori;
  final int? status;
  final int? inspeksi_jenis;
  final dynamic? kode_edupak;

  SubCategoryInspeksi({
    this.id,
    this.id_subkategori_inspeksi,
    this.area_id,
    this.subkategori_id,
    this.kategori_id,
    this.surat_tugas_id,
    this.nama_subkategori,
    this.status,
    this.inspeksi_jenis,
    this.kode_edupak,
  });

  factory SubCategoryInspeksi.fromMap(Map<String, dynamic> map){
    return SubCategoryInspeksi(
      id: map['id'],
      id_subkategori_inspeksi: map['id_subkategori_inspeksi'],
      area_id: map['area_id'],
      subkategori_id: map['subkategori_id'],
      kategori_id: map['kategori_id'],
      surat_tugas_id: map['surat_tugas_id'],
      nama_subkategori: map['nama_subkategori'],
      status: map['status'],
      inspeksi_jenis: map['inspeksi_jenis'],
      kode_edupak: map['kode_edupak'],
    );
  }

  factory SubCategoryInspeksi.fromJson(Map<String, dynamic> json){
    return SubCategoryInspeksi(
      id: json['id'],
      id_subkategori_inspeksi: json['id_subkategori_inspeksi'],
      area_id: json['area_id'],
      subkategori_id: json['subkategori_id'],
      kategori_id: json['kategori_id'],
      surat_tugas_id: json['surat_tugas_id'],
      nama_subkategori: json['nama_subkategori'],
      status: json['status'],
      inspeksi_jenis: json['inspeksi_jenis'],
      kode_edupak: json['kode_edupak'],
    );
  }

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'id_subkategori_inspeksi': id_subkategori_inspeksi,
      'area_id': area_id,
      'subkategori_id': subkategori_id,
      'kategori_id': kategori_id,
      'surat_tugas_id': surat_tugas_id,
      'nama_subkategori': nama_subkategori,
      'status': status,
      'inspeksi_jenis': inspeksi_jenis,
      'kode_edupak': kode_edupak,
    };
  }
}