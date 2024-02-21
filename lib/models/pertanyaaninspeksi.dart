// ignore_for_file: non_constant_identifier_names, unnecessary_question_mark

class PertanyaanInspeksi {
  final int? id;
  final int? id_pertanyaan;
  final int? area_id;
  final int? subkategori_inspeksi_id;
  final int? personil_inspeksi;
  final int? jawaban;
  final String? aman;
  final String? ramah_lingkungan;
  final dynamic? catatan;
  final dynamic? review; 
  final int? pertanyaan_id;
  final dynamic? pertanyaan;
  final dynamic? rekomendasi;
  final dynamic? foto;


  PertanyaanInspeksi({
    this.id,
    this.id_pertanyaan,
    this.area_id,
    this.subkategori_inspeksi_id,
    this.personil_inspeksi,
    this.jawaban,
    this.aman,
    this.ramah_lingkungan,
    this.catatan,
    this.review,
    this.pertanyaan_id,
    this.pertanyaan,
    this.rekomendasi,
    this.foto,
  });

  factory PertanyaanInspeksi.fromMap(Map<String, dynamic> map){
    return PertanyaanInspeksi(
      id: map['id'],
      id_pertanyaan: map['id_pertanyaan'],
      area_id: map['area_id'],
      subkategori_inspeksi_id: map['subkategori_inspeksi_id'],
      personil_inspeksi: map['personil_inspeksi'],
      jawaban: map['jawaban'],
      aman: map['aman'],
      ramah_lingkungan: map['ramah_lingkungan'],
      catatan: map['catatan'],
      review: map['review'],
      pertanyaan_id: map['pertanyaan_id'],
      pertanyaan: map['pertanyaan'],
      rekomendasi: map['rekomendasi'],
      foto: map['foto'],
    );
  }

  factory PertanyaanInspeksi.fromJson(Map<String, dynamic> json){
    return PertanyaanInspeksi(
      id: json['id'],
      id_pertanyaan: json['id_pertanyaan'],
      area_id: json['area_id'],
      subkategori_inspeksi_id: json['subkategori_inspeksi_id'],
      personil_inspeksi: json['personil_inspeksi'],
      jawaban: json['jawaban'],
      aman: json['aman'],
      ramah_lingkungan: json['ramah_lingkungan'],
      catatan: json['catatan'],
      review: json['review'],
      pertanyaan_id: json['pertanyaan_id'],
      pertanyaan: json['pertanyaan'],
      rekomendasi: json['rekomendasi'],
      foto: json['foto'],
    );
  }

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'id_pertanyaan': id_pertanyaan,
      'area_id': area_id,
      'subkategori_inspeksi_id': subkategori_inspeksi_id,
      'personil_inspeksi': personil_inspeksi,
      'jawaban': jawaban,
      'aman': aman,
      'ramah_lingkungan': ramah_lingkungan,
      'catatan': catatan,
      'review': review,
      'pertanyaan_id': pertanyaan_id,
      'pertanyaan': pertanyaan,
      'rekomendasi': rekomendasi,
      'foto': foto,
    };
  }
}