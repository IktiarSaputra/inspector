// ignore_for_file: non_constant_identifier_names, unnecessary_question_mark

class FotoInspeksi {
  final int? id;
  final int? id_foto_inspeksi;
  final dynamic? nama_file;
  final dynamic? longitude;
  final dynamic? latitude;
  final int? id_inspeksi_pertanyaan;

  FotoInspeksi({
    this.id,
    this.id_foto_inspeksi,
    this.nama_file,
    this.longitude,
    this.latitude,
    this.id_inspeksi_pertanyaan,
  });

  factory FotoInspeksi.fromMap(Map<String, dynamic> json) => FotoInspeksi(
        id: json["id"],
        id_foto_inspeksi: json["id_foto_inspeksi"],
        nama_file: json["nama_file"],
        longitude: json["longitude"],
        latitude: json["latitude"],
        id_inspeksi_pertanyaan: json["id_inspeksi_pertanyaan"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "id_foto_inspeksi": id_foto_inspeksi,
        "nama_file": nama_file,
        "longitude": longitude,
        "latitude": latitude,
        "id_inspeksi_pertanyaan": id_inspeksi_pertanyaan,
      };

  
}