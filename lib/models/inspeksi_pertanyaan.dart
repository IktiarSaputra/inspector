import 'model_inspeksi_area.dart';
import 'model_inspeksi_pertanyaan.dart';
import 'model_kategori_inspeksi.dart';
import 'model_subkategori_inspeksi.dart';

class DataInspeksiPertanyaan {
  final ModelKategoriInspeksi kategori;
  final ModelInspeksiArea area;
  final ModelSubKategoriInspeksi subKategori;
  final ModelInspeksiPertanyaan pertanyaan;

  DataInspeksiPertanyaan({
    required this.kategori,
    required this.area,
    required this.subKategori,
    required this.pertanyaan, 
  });
}