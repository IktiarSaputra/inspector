// ignore_for_file: non_constant_identifier_names

import 'package:inspector/models/model_inspeksi_area.dart';

class ModelKategoriInspeksi {
  final int? id;
  final int id_kategori;
  final int kategori_id;
  final String nama_kategori;
  final int surat_tugas_id;
  List<ModelInspeksiArea>? area = [];

  ModelKategoriInspeksi(
      {this.id,
      required this.id_kategori,
      required this.kategori_id,
      required this.nama_kategori,
      required this.surat_tugas_id,
      this.area
      });


  factory ModelKategoriInspeksi.fromMap(Map<String, dynamic> json) =>
      ModelKategoriInspeksi(
        id: json["id"],
        id_kategori: json["id_kategori"],
        kategori_id: json["kategori_id"],
        nama_kategori: json["nama_kategori"],
        surat_tugas_id: json["surat_tugas_id"],
      );
    
  factory ModelKategoriInspeksi.fromJson(Map<String, dynamic> json) =>
      ModelKategoriInspeksi(
        id: json["id"],
        id_kategori: json["id_kategori"],
        kategori_id: json["kategori_id"],
        nama_kategori: json["nama_kategori"],
        surat_tugas_id: json["surat_tugas_id"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "id_kategori": id_kategori,
        "kategori_id": kategori_id,
        "nama_kategori": nama_kategori,
        "surat_tugas_id": surat_tugas_id,
      };

  Map<String, dynamic> toJson() => {
        "id": id,
        "id_kategori": id_kategori,
        "kategori_id": kategori_id,
        "nama_kategori": nama_kategori,
        "surat_tugas_id": surat_tugas_id,
      };
  

}