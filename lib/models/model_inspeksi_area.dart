// ignore_for_file: non_constant_identifier_names

import 'package:inspector/models/model_subkategori_inspeksi.dart';

class ModelInspeksiArea{

  final int? id;
  final int id_area;
  final int kategori_inspeksi_id;
  final dynamic nama_area;
  List<ModelSubKategoriInspeksi>? subkategori = [];

  ModelInspeksiArea({this.id, required this.id_area, required this.kategori_inspeksi_id, required this.nama_area, this.subkategori});

  factory ModelInspeksiArea.fromMap(Map<String, dynamic> json) => ModelInspeksiArea(
    id: json["id"],
    id_area: json["id_area"],
    kategori_inspeksi_id: json["kategori_inspeksi_id"],
    nama_area: json["nama_area"],
  );

  factory ModelInspeksiArea.fromJson(Map<String, dynamic> json) => ModelInspeksiArea(
    id: json["id"],
    id_area: json["id_area"],
    kategori_inspeksi_id: json["kategori_inspeksi_id"],
    nama_area: json["nama_area"],
  );

  get length => null;

  Map<String, dynamic> toMap() => {
    "id": id,
    "id_area": id_area,
    "kategori_inspeksi_id": kategori_inspeksi_id,
    "nama_area": nama_area,
  };

  

}