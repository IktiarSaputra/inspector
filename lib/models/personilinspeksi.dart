// ignore_for_file: non_constant_identifier_names

class PersonilInspeksi {
  int? id;
  int? st_inspeksi_id;
  dynamic nama_personil;
  int? status;

  PersonilInspeksi({this.id, this.st_inspeksi_id, this.nama_personil, this.status});

  factory PersonilInspeksi.fromMap(Map<String, dynamic> map) {
    return PersonilInspeksi(
      id: map['id'],
      st_inspeksi_id: map['st_inspeksi_id'],
      nama_personil: map['nama_personil'],
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'st_inspeksi_id': st_inspeksi_id,
      'nama_personil': nama_personil.toString(),
      'status': status,
    };
  }

  factory PersonilInspeksi.fromJson(Map<String, dynamic> json) {
    return PersonilInspeksi(
      id: json['id'],
      st_inspeksi_id: json['st_inspeksi_id'],
      nama_personil: json['nama_personil'],
      status: json['status'],
    );
  } 
}