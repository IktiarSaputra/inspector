// ignore_for_file: non_constant_identifier_names, unnecessary_question_mark

import 'dart:convert';

class ModelRekomendasi {
  final int? id;
  final int id_rekomendasi;
  final int inspeksi_pertanyaan_id;
  final dynamic tindak_lanjut;
  final String penanggung_jawab;
  final String due_date;
  final int prioritas;
  final int status_tindakan;
  final dynamic catatan_tindakan;
  final dynamic? file;
  final dynamic rekomendasi;
  final int review;
  final dynamic? keterangan_review;

  ModelRekomendasi({
    this.id,
    required this.id_rekomendasi,
    required this.inspeksi_pertanyaan_id,
    required this.tindak_lanjut,
    required this.penanggung_jawab,
    required this.due_date,
    required this.prioritas,
    required this.status_tindakan,
    required this.catatan_tindakan,
    this.file,
    required this.rekomendasi,
    required this.review,
    this.keterangan_review,
  });

  factory ModelRekomendasi.fromMap(Map<String, dynamic> map) {
    return ModelRekomendasi(
      id: map['id'],
      id_rekomendasi: map['id_rekomendasi'],
      inspeksi_pertanyaan_id: map['inspeksi_pertanyaan_id'],
      tindak_lanjut: map['tindak_lanjut'],
      penanggung_jawab: map['penanggung_jawab'],
      due_date: map['due_date'],
      prioritas: map['prioritas'],
      status_tindakan: map['status_tindakan'],
      catatan_tindakan: map['catatan_tindakan'],
      file: map['file'],
      rekomendasi: map['rekomendasi'],
      review: map['review'],
      keterangan_review: map['keterangan_review'],
    );
  }

  factory ModelRekomendasi.fromJson(String source) =>
      ModelRekomendasi.fromMap(json.decode(source));

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_rekomendasi': id_rekomendasi,
      'inspeksi_pertanyaan_id': inspeksi_pertanyaan_id,
      'tindak_lanjut': tindak_lanjut,
      'penanggung_jawab': penanggung_jawab,
      'due_date': due_date,
      'prioritas': prioritas,
      'status_tindakan': status_tindakan,
      'catatan_tindakan': catatan_tindakan,
      'file': file,
      'rekomendasi': rekomendasi,
      'review': review,
      'keterangan_review': keterangan_review,
    };
  }

  String toJson() => json.encode(toMap());
}