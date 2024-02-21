// ignore_for_file: constant_identifier_names

class Api {
  static const String BASE_URL = "https://inspector-app.xyz/api/";
  static const String Login = "${BASE_URL}login";
  static const String GetSuratTugas = "${BASE_URL}surat_tugas";
  static const String DetailSuratTugas = "${BASE_URL}detail_surat_tugas/";
  static const String GetKategoriInspeksi = "$BASE_URL/kategori";
  static const String AddKateogriInspeksi = "$BASE_URL/addsoalkategori";
  static const String AddAreaInspeksi = "$BASE_URL/addareakategori";
  static const String GetSoalInspeksi = "$BASE_URL/inspeksipertanyaan";
}