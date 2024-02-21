// ignore_for_file: non_constant_identifier_names, unnecessary_question_mark

class KategoriInspeksi {
  final int? id;
  final int? id_kategori;
  final dynamic nama_kategori;
  final int? inspeksi_jenis;
  final dynamic? kategori_jenis;
  final int? status;

  KategoriInspeksi(
      {this.id,
      this.id_kategori,
      this.nama_kategori,
      this.inspeksi_jenis,
      this.kategori_jenis,
      this.status}
  );
    
  factory KategoriInspeksi.fromMap(Map<String, dynamic> map){
    return KategoriInspeksi(
      id: map['id'],
      id_kategori: map['id_kategori'],
      nama_kategori: map['nama_kategori'],
      inspeksi_jenis: map['inspeksi_jenis'],
      kategori_jenis: map['kategori_jenis'],
      status: map['status']
    );
  }

  factory KategoriInspeksi.fromJson(Map<String, dynamic> json){
    return KategoriInspeksi(
      id: json['id'],
      id_kategori: json['id_kategori'],
      nama_kategori: json['nama_kategori'],
      inspeksi_jenis: json['inspeksi_jenis'],
      kategori_jenis: json['kategori_jenis'],
      status: json['status']
    );
  }

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'id_kategori': id_kategori,
      'nama_kategori': nama_kategori.toString(),
      'inspeksi_jenis': inspeksi_jenis,
      'kategori_jenis': kategori_jenis.toString(),
      'status': status
    };
  }


}