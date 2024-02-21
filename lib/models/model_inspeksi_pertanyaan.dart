// ignore_for_file: non_constant_identifier_names, unnecessary_question_mark

import 'dart:convert';

class ModelInspeksiPertanyaan {
  final int? id;
  final int id_inspeksi_pertanyaan;
  final int id_pertanyaan;
  final int subkategori_inspeksi_id;
  late int jawaban;
  final int aman;
  final int ramah_lingkungan;
  late dynamic catatan;
  final int personil_inspeksi;
  final dynamic? review;
  final dynamic? rekomendasi;
  final dynamic pertanyaan;
  final dynamic? video;
  late dynamic? foto;

  ModelInspeksiPertanyaan({
    this.id,
    required this.id_inspeksi_pertanyaan,
    required this.id_pertanyaan,
    required this.subkategori_inspeksi_id,
    required this.jawaban,
    required this.aman,
    required this.ramah_lingkungan,
    this.catatan,
    required this.personil_inspeksi,
    this.review,
    this.rekomendasi,
    required this.pertanyaan,
    this.video,
    this.foto,
  });

  factory ModelInspeksiPertanyaan.fromMap(Map<String, dynamic> map) {
    return ModelInspeksiPertanyaan(
      id: map['id'],
      id_inspeksi_pertanyaan: map['id_inspeksi_pertanyaan'],
      id_pertanyaan: map['id_pertanyaan'],
      subkategori_inspeksi_id: map['subkategori_inspeksi_id'],
      jawaban: map['jawaban'],
      aman: map['aman'],
      ramah_lingkungan: map['ramah_lingkungan'],
      catatan: map['catatan'],
      personil_inspeksi: map['personil_inspeksi'],
      review: map['review'],
      rekomendasi: map['rekomendasi'],
      pertanyaan: map['pertanyaan'],
      video: map['video'],
      foto: map['foto'],
    );
  }

  factory ModelInspeksiPertanyaan.fromJson(String source) =>
      ModelInspeksiPertanyaan.fromMap(json.decode(source));
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_inspeksi_pertanyaan': id_inspeksi_pertanyaan,
      'id_pertanyaan': id_pertanyaan,
      'subkategori_inspeksi_id': subkategori_inspeksi_id,
      'jawaban': jawaban,
      'aman': aman,
      'ramah_lingkungan': ramah_lingkungan,
      'catatan': catatan,
      'personil_inspeksi': personil_inspeksi,
      'review': review,
      'rekomendasi': rekomendasi,
      'pertanyaan': pertanyaan,
      'video': video,
      'foto': foto,
    };
  }
  

  

  
  
}