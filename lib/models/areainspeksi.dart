// ignore_for_file: non_constant_identifier_names

class AreaInspeksi {
  final int? id;
  final int? id_area;
  final int? kategori_id;
  final int? id_soal_kategori;
  final String? nama_area;
  final int? surat_tugas_id;
  late final bool? is_saved;

  AreaInspeksi({
    this.id,
    this.id_area,
    this.kategori_id,
    this.id_soal_kategori,
    this.nama_area,
    this.surat_tugas_id,
    this.is_saved = false,
  });

  factory AreaInspeksi.fromMap(Map<String, dynamic> map){
    return AreaInspeksi(
      id: map['id'],
      id_area: map['id_area'],
      kategori_id: map['kategori_id'],
      id_soal_kategori: map['id_soal_kategori'],
      nama_area: map['nama_area'],
      surat_tugas_id: map['surat_tugas_id'],
      is_saved: map['is_saved'] == 1 ? true : false,
    );
  }

  factory AreaInspeksi.fromJson(Map<String, dynamic> json){
    return AreaInspeksi(
      id: json['id'],
      id_area: json['id_area'],
      kategori_id: json['kategori_id'],
      id_soal_kategori: json['id_soal_kategori'],
      nama_area: json['nama_area'],
      surat_tugas_id: json['surat_tugas_id'],
      is_saved: json['is_saved'],
    );
  }

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'id_area': id_area,
      'kategori_id': kategori_id,
      'id_soal_kategori': id_soal_kategori,
      'nama_area': nama_area,
      'surat_tugas_id': surat_tugas_id,
      'is_saved': is_saved,
    };
  }
}