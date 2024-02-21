// ignore_for_file: non_constant_identifier_names

import 'model_inspeksi_pertanyaan.dart';

class ModelSubKategoriInspeksi{
  final int? id;
  final int id_subkategori;
  final int area_id;
  final String nama_subkategori;
  List<ModelInspeksiPertanyaan>? pertanyaan = [];


  ModelSubKategoriInspeksi({this.id, required this.id_subkategori, required this.area_id, required this.nama_subkategori, this.pertanyaan});

  factory ModelSubKategoriInspeksi.fromMap(Map<String, dynamic> json) => ModelSubKategoriInspeksi(
    id: json["id"],
    id_subkategori: json["id_subkategori"],
    area_id: json["area_id"],
    nama_subkategori: json["nama_subkategori"],
  );

  factory ModelSubKategoriInspeksi.fromJson(Map<String, dynamic> json) => ModelSubKategoriInspeksi(
    id: json["id"],
    id_subkategori: json["id_subkategori"],
    area_id: json["area_id"],
    nama_subkategori: json["nama_subkategori"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "id_subkategori": id_subkategori,
    "area_id": area_id,
    "nama_subkategori": nama_subkategori,
  };
}
