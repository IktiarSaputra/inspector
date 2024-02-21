// ignore_for_file: depend_on_referenced_packages, non_constant_identifier_names, prefer_is_empty

import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/areainspeksi.dart';
import '../models/kategoriinspeksi.dart';
import '../models/kategorisoalinspeksi.dart';
import '../models/model_foto_inspeksi.dart';
import '../models/model_inspeksi_area.dart';
import '../models/model_inspeksi_pertanyaan.dart';
import '../models/model_kategori_inspeksi.dart';
import '../models/model_rekomendasi.dart';
import '../models/model_subkategori_inspeksi.dart';
import '../models/pertanyaaninspeksi.dart';
import '../models/subcategoryinspeksi.dart';
import '../models/surattugas.dart';
import '../models/personilinspeksi.dart';
import '../models/user.dart';

class DatabaseHelper {
  factory DatabaseHelper() => _instance;

  DatabaseHelper._();

  static Database? _db;
  static final DatabaseHelper _instance = DatabaseHelper._();

  Future<Database> initDatabase() async {
    final path = join(await getDatabasesPath(), 'myapp.db');
    return _db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
        CREATE TABLE user (
          id INTEGER PRIMARY KEY,
          name TEXT,
          email TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE surat_tugas (
          id INTEGER PRIMARY KEY,
          id_surat_tugas INTEGER,
          no_surat VARCHAR(255),
          tgl_inspeksi TEXT,
          status INTEGER,
          userId INTEGER,
          jenis_pengawasan_id INTEGER,
          nama_perusahaan VARCHAR(255),
          komoditas_perusahaan VARCHAR(255)
        )
      ''');

    await db.execute('''
        CREATE TABLE personil_inspeksi (
          id INTEGER PRIMARY KEY,
          st_inspeksi_id INTEGER,
          nama_personil VARCHAR(255),
          status INTEGER
        )
      ''');

    await db.execute('''
        CREATE TABLE kategori_inspeksi (
          id INTEGER PRIMARY KEY,
          id_kategori INTEGER,
          nama_kategori VARCHAR(255),
          inspeksi_jenis INTEGER,
          kategori_jenis VARCHAR(255),
          status INTEGER
        )
      ''');

    await db.execute('''
        CREATE TABLE kategori_soal_inspeksi (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          id_kategori INTEGER,
          id_soal_kategori INTEGER,
          nama_kategori VARCHAR(255),
          surat_tugas_id INTEGER
        )
      ''');


    await db.execute('''
        CREATE TABLE inspeksi_kategori (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          id_kategori INTEGER,
          kategori_id INTEGER,
          nama_kategori VARCHAR(255),
          surat_tugas_id INTEGER
        )
      ''');

    await db.execute('''
        CREATE TABLE inspeksi_area (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          id_area INTEGER,
          kategori_inspeksi_id INTEGER,
          nama_area VARCHAR(255)
        )
      ''');

    await db.execute('''
        CREATE TABLE subkategori_inspeksi (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          id_subkategori INTEGER,
          area_id INTEGER,
          nama_subkategori VARCHAR(255)
        )
      ''');

      await db.execute('''
        CREATE TABLE inspeksi_pertanyaan (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          id_inspeksi_pertanyaan INTEGER,
          id_pertanyaan INTEGER,
          subkategori_inspeksi_id INTEGER,
          jawaban INTEGER,
          aman INTEGER,
          ramah_lingkungan INTEGER,
          catatan TEXT,
          personil_inspeksi INTEGER,
          review TEXT,
          rekomendasi TEXT,
          pertanyaan TEXT,
          video TEXT,
          foto BLOB
        )
      ''');

      await db.execute('''
        CREATE TABLE foto_inspeksi (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          id_foto_inspeksi INTEGER,
          nama_file TEXT,
          longitude TEXT,
          latitude TEXT,
          id_inspeksi_pertanyaan INTEGER
        )
      ''');

    

    await db.execute('''
        CREATE TABLE area_inspeksi (
          id INTEGER PRIMARY KEY,
          id_area INTEGER,
          kategori_id INTEGER,
          id_soal_kategori INTEGER,
          nama_area VARCHAR(255),
          surat_tugas_id INTEGER,
          is_saved BOOLEAN
        )
      ''');



      await db.execute('''
        CREATE TABLE subcategory_inspeksi (
          id INTEGER PRIMARY KEY,
          id_subkategori_inspeksi INTEGER,
          area_id INTEGER,
          subkategori_id INTEGER,
          kategori_id INTEGER,
          surat_tugas_id INTEGER,
          nama_subkategori TEXT,
          status INTEGER,
          inspeksi_jenis INTEGER,
          kode_edupak INTEGER
        )
      ''');

      await db.execute('''
        CREATE TABLE rekomendasi (
          id INTEGER PRIMARY KEY,
          id_rekomendasi INTEGER,
          inspeksi_pertanyaan_id INTEGER,
          tindak_lanjut TEXT,
          penanggung_jawab STRING,
          due_date STRING,
          prioritas INTEGER,
          status_tindakan INTEGER,
          catatan_tindakan TEXT,
          file BLOB,
          rekomendasi TEXT,
          review INTEGER,
          keterangan_review TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE pertanyaan_inspeksi (
          id INTEGER PRIMARY KEY,
          id_pertanyaan INTEGER,
          area_id INTEGER,
          subkategori_inspeksi_id INTEGER,
          personil_inspeksi INTEGER,
          jawaban INTEGER Comment '0 = belum dijawab, 1 = ya, 2 = tidak',
          aman INTEGER Comment '0 = belum dijawab, 1 = ya, 2 = tidak',
          ramah_lingkungan INTEGER Comment '0 = belum dijawab, 1 = ya, 2 = tidak',
          catatan TEXT,
          review TEXT,
          pertanyaan_id INTEGER,
          pertanyaan TEXT,
          rekomendasi TEXT,
          foto BLOB
        )
      ''');
    });
  }

  Future<List<PertanyaanInspeksi>> getAllPertanyaanInspeksiByStId(int subkategori_id) async {
    final dbClient = await _getDb();
    final result = await dbClient.query('pertanyaan_inspeksi', where: 'subkategori_inspeksi_id = ?', whereArgs: [subkategori_id]);
    return result.map((e) => PertanyaanInspeksi.fromMap(e)).toList();
  }

  Future<PertanyaanInspeksi?> checkAllPertanyaanInspeksiByStId(subkategori_id, pertanyaan_id) async {
    final dbClient = await _getDb();
    final result =
        await  dbClient.query('pertanyaan_inspeksi', where: 'subkategori_inspeksi_id = ? AND pertanyaan_id = ?', whereArgs: [subkategori_id,pertanyaan_id]);
    if (result.length > 0) {
      return PertanyaanInspeksi.fromMap(result.first);
    }
    return null;
  }

  Future<List<AreaInspeksi>> getAllAreaInspeksiByStId(int surat_tugas_id, int kategori_id) async {
    final dbClient = await _getDb();
    final result = await dbClient.query('area_inspeksi', where: 'surat_tugas_id = ? AND kategori_id = ?', whereArgs: [surat_tugas_id,kategori_id]);
    return result.map((e) => AreaInspeksi.fromMap(e)).toList();
  }

  Future<List<SubCategoryInspeksi>> getAllSubcategoryInspeksiByStId(int surat_tugas_id, area_id,kategori_id) async {
    final dbClient = await _getDb();
    final result = await dbClient.query('subcategory_inspeksi', where: 'surat_tugas_id = ? AND area_id = ? AND kategori_id = ?', whereArgs: [surat_tugas_id,area_id,kategori_id]);
    return result.map((e) => SubCategoryInspeksi.fromMap(e)).toList();
  }

  Future<SubCategoryInspeksi?> checkAllSubcategoryInspeksiByStId(int surat_tugas_id, area_id,kategori_id, nama_subkategori) async {
    final dbClient = await _getDb();
    final result =
        await  dbClient.query('subcategory_inspeksi', where: 'surat_tugas_id = ? AND area_id = ? AND kategori_id = ? AND nama_subkategori = ?', whereArgs: [surat_tugas_id,area_id,kategori_id,nama_subkategori]);
    if (result.length > 0) {
      return SubCategoryInspeksi.fromMap(result.first);
    }
    return null;
  }

  Future<List<SubCategoryInspeksi>> getAllsSubcategoryInspeksi() {
    return _getDb().then((db) {
      return db.query('subcategory_inspeksi').then((maps) {
        final subcategoryInspeksi = <SubCategoryInspeksi>[];
        for (final map in maps) {
          subcategoryInspeksi.add(SubCategoryInspeksi.fromMap(map));
        }
        return subcategoryInspeksi;
      });
    });
  }

  Future<int> savePertanyaanInspeksi(PertanyaanInspeksi pertanyaanInspeksi) async {
    final dbClient = await _getDb();
    return await dbClient.insert('pertanyaan_inspeksi', pertanyaanInspeksi.toMap());
  }

  Future<int> saveSubcategoryInspeksi(SubCategoryInspeksi subCategoryInspeksi) async {
    final dbClient = await _getDb();
    return await dbClient.insert('subcategory_inspeksi', subCategoryInspeksi.toMap());
  }

  Future<List<SubCategoryInspeksi>> getAllSubcategoryInspeksi(int surat_tugas_id, int area_id, int kategori_id) async {
    final dbClient = await _getDb();
    final result = await dbClient.query('subcategory_inspeksi', where: 'surat_tugas_id = ? AND area_id = ? AND kategori_id = ?', whereArgs: [surat_tugas_id,area_id,kategori_id]);
    return result.map((e) => SubCategoryInspeksi.fromMap(e)).toList();
  }

  Future<int> saveKategoriSoalInspeksi(KategoriSoalInspeksi kategoriSoalInspeksi) async {
    final dbClient = await _getDb();
    try {
      await dbClient.insert('kategori_soal_inspeksi', kategoriSoalInspeksi.toMap());
    } catch (e) {
    }

    return 0;
  }

  Future<List<KategoriSoalInspeksi>> getAllKategoriSoalInspeksi(int surat_tugas_id) async {
    final dbClient = await _getDb();
    final result = await dbClient.query('kategori_soal_inspeksi', where: 'surat_tugas_id = ?', whereArgs: [surat_tugas_id]);
    return result.map((e) => KategoriSoalInspeksi.fromMap(e)).toList();
  }

  Future<KategoriSoalInspeksi?> getKategoriSoalInspeksiById(int id,int st_id) async {
    final dbClient = await _getDb();
    final result =
        await dbClient.query('kategori_soal_inspeksi', where: 'id_kategori = ? AND surat_tugas_id = ?', whereArgs: [id,st_id]);
    if (result.length > 0) {
      return KategoriSoalInspeksi.fromMap(result.first);
    }
    return null;
  }

  Future<void> deleteKategoriSoalInspeksiById(int id) async {
    final dbClient = await _getDb();
    await dbClient.delete('kategori_soal_inspeksi', where: 'id_soal_kategori = ?', whereArgs: [id]);
  }

  Future<void> deleteAllKategoriSoalInspeksi() async {
    final dbClient = await _getDb();
    await dbClient.delete('kategori_soal_inspeksi');
  }

  Future<int> saveAreaInspeksi(AreaInspeksi areaInspeksi) async {
    final dbClient = await _getDb();
    return await dbClient.insert('area_inspeksi', areaInspeksi.toMap());
  }

  Future<AreaInspeksi?> findAreaInspeksiById(String name, int st_id, kat_id) async {
    final dbClient = await _getDb();
    final result =
        await dbClient.query('area_inspeksi', where: 'nama_area = ? AND surat_tugas_id = ? AND kategori_id = ?', whereArgs: [name,st_id,kat_id]);
    if (result.length > 0) {
      return AreaInspeksi.fromMap(result.first);
    }
    return null;
  }

  Future<List<AreaInspeksi>> getAllAreaInspeksi(int surat_tugas_id) async {
    final dbClient = await _getDb();
    final result = await dbClient.query('area_inspeksi', where: 'surat_tugas_id = ?', whereArgs: [surat_tugas_id]);
    return result.map((e) => AreaInspeksi.fromMap(e)).toList();
  }

  Future<AreaInspeksi?> getAreaInspeksiById(int id) async {
    final dbClient = await _getDb();
    final result =
        await dbClient.query('area_inspeksi', where: 'id_area = ?', whereArgs: [id]);
    if (result.length > 0) {
      return AreaInspeksi.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateAreaInspeksi(int id, st_id,String name,int id_area) async {
    final dbClient = await _getDb();
    final result = await dbClient.update('area_inspeksi', {'id_area': id_area}, where: 'kategori_id = ? AND surat_tugas_id = ? AND nama_area = ?', whereArgs: [id,st_id,name]);
    return result;
  }

  Future<void> deleteAreaInspeksiById(int id, st_id, name) async {
    final dbClient = await _getDb();
    await dbClient.delete('area_inspeksi', where: 'kategori_id = ? AND surat_tugas_id = ? AND nama_area = ?', whereArgs: [id,st_id,name]);
  }

  Future<void> updateAreaInspeksiById(int id, st_id, name) async {
    final dbClient = await _getDb();
    await dbClient.update('area_inspeksi', {'nama_area': name}, where: 'kategori_id = ? AND surat_tugas_id = ? AND id_area = ?', whereArgs: [id,st_id,name]);
  }

  Future<void> deleteAllAreaInspeksi() async {
    final dbClient = await _getDb();
    await dbClient.delete('area_inspeksi');
  }

  Future<int> saveKategoriInspeksi(KategoriInspeksi kategoriInspeksi) async {
    final dbClient = await _getDb();
    return await dbClient.insert('kategori_inspeksi', kategoriInspeksi.toMap());
  }

  Future<KategoriInspeksi?> getKategoriInspeksiById(int id) async {
    final dbClient = await _getDb();
    final result =
        await dbClient.query('kategori_inspeksi', where: 'id_kategori = ?', whereArgs: [id]);
    if (result.length > 0) {
      return KategoriInspeksi.fromMap(result.first);
    }
    return null;
  }

  Future<void> deleteKategoriInspeksiById(int id) async {
    final dbClient = await _getDb();
    await dbClient.delete('kategori_inspeksi', where: 'id_kategori = ?', whereArgs: [id]);
  }

  Future<void> deleteAllKategoriInspeksi() async {
    final dbClient = await _getDb();
    await dbClient.delete('kategori_inspeksi');
  }

  Future<int> saveSuratTugas(SuratTugas suratTugas) async {
    final dbClient = await _getDb();
    return await dbClient.insert('surat_tugas', suratTugas.toMap());
  }

  Future<SuratTugas?> getSuratTugasById(int id) async {
    final dbClient = await _getDb();
    final result =
        await dbClient.query('surat_tugas', where: 'id_surat_tugas = ?', whereArgs: [id]);
    if (result.length > 0) {
      return SuratTugas.fromMap(result.first);
    }
    return null;
  }

  Future<void> updateSuratTugas(int id, int status) async {
    final dbClient = await _getDb();
    await dbClient.update('surat_tugas', {'status': status}, where: 'id_surat_tugas = ?', whereArgs: [id]);
  }

  Future<void> deleteSuratTugasById(int id) async {
    final dbClient = await _getDb();
    await dbClient.delete('surat_tugas', where: 'id_surat_tugas = ?', whereArgs: [id]);
  }

  Future<void> deleteAllSuratTugas() async {
    final dbClient = await _getDb();
    await dbClient.delete('surat_tugas');
  }

  Future<List<SuratTugas>> getAllSuratTugas() async {
    final dbClient = await _getDb();
    final result = await dbClient.query('surat_tugas');
    return result.map((suratTugas) => SuratTugas.fromMap(suratTugas)).toList(); 
  }

  Future<List<KategoriInspeksi>> getAllKategoriInspeksi() async {
    final dbClient = await _getDb();
    final result = await dbClient.query('kategori_inspeksi');
    return result.map((kategoriInspeksi) => KategoriInspeksi.fromMap(kategoriInspeksi)).toList(); 
  }

  Future<int> savePersonilInspeksi(PersonilInspeksi personilInspeksi) async {
    final dbClient = await _getDb();
    return await dbClient.insert('personil_inspeksi', personilInspeksi.toMap());
  }

  Future<PersonilInspeksi?> getAllPersonilInspeksiById(int id) async {
    final dbClient = await _getDb();
    final result =
        await dbClient.query('personil_inspeksi', where: 'id = ?', whereArgs: [id]);
    if (result.length > 0) {
      return PersonilInspeksi.fromMap(result.first);
    }
    return null;
  }

  Future<PersonilInspeksi?> findPersonilInspeksiByStIdAndName(int stId, String name) async {
    final dbClient = await _getDb();
    final result =
        await dbClient.query('personil_inspeksi', where: 'st_inspeksi_id = ? AND nama_personil = ?', whereArgs: [stId, name]);
    if (result.length > 0) {
      return PersonilInspeksi.fromMap(result.first);
    }
    return null;
  }

  Future<List<PersonilInspeksi>> getAllPersonilInspeksiByStId(int stId) async {
    final dbClient = await _getDb();
    final result = await dbClient.query('personil_inspeksi', where: 'st_inspeksi_id = ?', whereArgs: [stId]);
    return result.map((personilInspeksi) => PersonilInspeksi.fromMap(personilInspeksi)).toList();
  }

  Future<void> deleteAllPersonilInspeksi() async {
    final dbClient = await _getDb();
    await dbClient.delete('personil_inspeksi');
  } 

  Future<int> saveUser(User user) async {
    final dbClient = await _getDb();
    return await dbClient.insert('user', user.toMap());
  }

  Future<User?> getUserByEmail(String email) async {
    final dbClient = await _getDb();
    final result =
        await dbClient.query('user', where: 'email = ?', whereArgs: [email]);
    if (result.length > 0) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<User?> getUserById(int id) async {
    final dbClient = await _getDb();
    final result =
        await dbClient.query('user', where: 'id = ?', whereArgs: [id]);
    if (result.length > 0) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<List<User>> getAllUsers() async {
    final dbClient = await _getDb();
    final result = await dbClient.query('user');
    return result.map((user) => User.fromMap(user)).toList();
  }

  Future<void> deleteUserById(int id) async {
    final dbClient = await _getDb();
    await dbClient.delete('user', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllUsers() async {
    final dbClient = await _getDb();
    await dbClient.delete('user');
  }

  Future<int> saveModelKategoriInspeksi(ModelKategoriInspeksi modelKategoriInspeksi) async {
    final dbClient = await _getDb();
    return await dbClient.insert('inspeksi_kategori', modelKategoriInspeksi.toMap());
  }

  Future<ModelKategoriInspeksi?> getKategoriInspeksiByStIdAndKategoriId(int stId, int kategoriId, int kategori_id) async {
    final dbClient = await _getDb();
    final result =
        await dbClient.query('inspeksi_kategori', where: 'surat_tugas_id = ? AND id_kategori = ? AND kategori_id = ?', whereArgs: [stId, kategoriId, kategori_id]);
    if (result.length > 0) {
      return ModelKategoriInspeksi.fromMap(result.first);
    }
    return null;
  }

  Future<List<ModelKategoriInspeksi>> getAlllKategoriInspeksiByStId(int stId) async {
    final dbClient = await _getDb();
    final result = await dbClient.query('inspeksi_kategori', where: 'surat_tugas_id = ?', whereArgs: [stId]);
    return result.map((modelKategoriInspeksi) => ModelKategoriInspeksi.fromMap(modelKategoriInspeksi)).toList();
  }

  Future<void> deleteAllModelKategoriInspeksi() async {
    final dbClient = await _getDb();
    await dbClient.delete('inspeksi_kategori');
  }

  Future<int> saveModelInspeksiArea(ModelInspeksiArea modelInspeksiArea) async {
    final dbClient = await _getDb();
    return await dbClient.insert('inspeksi_area', modelInspeksiArea.toMap());
  }

  Future<ModelInspeksiArea?> getInspeksiAreaBykategoriInspeksiIdAndAreaId(int kategoriInspeksiId, int areaId) async {
    final dbClient = await _getDb();
    final result =
        await dbClient.query('inspeksi_area', where: 'kategori_inspeksi_id = ? AND id_area = ?', whereArgs: [kategoriInspeksiId, areaId]);
    if (result.length > 0) {
      return ModelInspeksiArea.fromMap(result.first);
    }
    return null;
  }

  Future<List<ModelInspeksiArea>> getAllInspeksiAreaBykategoriInspeksiId(int kat_ins_id) async {
    final dbClient = await _getDb();
    final result = await dbClient.query('inspeksi_area', where: 'kategori_inspeksi_id = ?', whereArgs: [kat_ins_id]);
    return result.map((modelInspeksiArea) => ModelInspeksiArea.fromMap(modelInspeksiArea)).toList();
  }

  Future<List<ModelInspeksiArea>> getAllInspeksiArea() async {
    final dbClient = await _getDb();
    final result = await dbClient.query('inspeksi_area');
    return result.map((modelInspeksiArea) => ModelInspeksiArea.fromMap(modelInspeksiArea)).toList();
  }

  Future<void> deleteAllModelInspeksiArea() async {
    final dbClient = await _getDb();
    await dbClient.delete('inspeksi_area');
  }

  Future<int> saveModelSubKategoriInspeksi(ModelSubKategoriInspeksi modelSubKategoriInspeksi) async {
    final dbClient = await _getDb();
    return await dbClient.insert('subkategori_inspeksi', modelSubKategoriInspeksi.toMap());
  }

  Future<ModelSubKategoriInspeksi?> getSubKategoriInspeksiByAreaIdAndIdSubKategori(int areaId, int idSubKategori) async {
    final dbClient = await _getDb();
    final result =
        await dbClient.query('subkategori_inspeksi', where: 'area_id = ? AND id_subkategori = ?', whereArgs: [areaId, idSubKategori]);
    if (result.length > 0) {
      return ModelSubKategoriInspeksi.fromMap(result.first);
    }
    return null;
  }

  Future<List<ModelSubKategoriInspeksi>> getAlllSubKategoriInspeksiByAreaId(int areaId) async {
    final dbClient = await _getDb();
    final result = await dbClient.query('subkategori_inspeksi', where: 'area_id = ?', whereArgs: [areaId]);
    return result.map((modelSubKategoriInspeksi) => ModelSubKategoriInspeksi.fromMap(modelSubKategoriInspeksi)).toList();
  }

  Future<List<ModelSubKategoriInspeksi>> getAlllSubKategoriInspeksi() async {
    final dbClient = await _getDb();
    final result = await dbClient.query('subkategori_inspeksi');
    return result.map((modelSubKategoriInspeksi) => ModelSubKategoriInspeksi.fromMap(modelSubKategoriInspeksi)).toList();
  }

  Future<void> deleteAllModelSubKategoriInspeksi() async {
    final dbClient = await _getDb();
    await dbClient.delete('subkategori_inspeksi');
  }

  Future<int> saveModelRekomendasi(ModelRekomendasi modelRekomendasi) async {
    final dbClient = await _getDb();
    return await dbClient.insert('rekomendasi', modelRekomendasi.toMap());
  }

  Future<ModelRekomendasi?> getRekomendasiByPertanyaanId(id) async {
    final dbClient = await _getDb();
    final result = await dbClient.query('rekomendasi', where: 'inspeksi_pertanyaan_id = ?', whereArgs: [id]);
    if (result.length > 0) {
      return ModelRekomendasi.fromMap(result.first);
    }
    return null;
  }

  Future<List<ModelRekomendasi>> getAlllRekomendasi() async {
    final dbClient = await _getDb();
    final result = await dbClient.query('rekomendasi');
    return result.map((modelRekomendasi) => ModelRekomendasi.fromMap(modelRekomendasi)).toList();
  }

  Future<int> updateRekomendasi(ModelRekomendasi modelRekomendasi) async {
    final dbClient = await _getDb();
    return await dbClient.update('rekomendasi', modelRekomendasi.toMap(), where: 'inspeksi_pertanyaan_id = ?', whereArgs: [modelRekomendasi.inspeksi_pertanyaan_id]);
  }

  Future<void> deleteAllModelRekomendasi() async {
    final dbClient = await _getDb();
    await dbClient.delete('rekomendasi');
  }

  Future<int> saveModelInspeksiPertanyaan(ModelInspeksiPertanyaan modelInspeksiPertanyaan) async {
    final dbClient = await _getDb();
    return await dbClient.insert('inspeksi_pertanyaan', modelInspeksiPertanyaan.toMap());
  }

  Future<ModelInspeksiPertanyaan?> getInspeksiPertanyaanBySubKategoriIdAndIdPertanyaan(int subKategoriId, int idPertanyaan, int idInspeksiPertanyaan) async {
    final dbClient = await _getDb();
    final result =
        await dbClient.query('inspeksi_pertanyaan', where: 'subkategori_inspeksi_id = ? AND id_pertanyaan = ? AND id_inspeksi_pertanyaan = ?', whereArgs: [subKategoriId, idPertanyaan, idInspeksiPertanyaan]);
    if (result.length > 0) {
      return ModelInspeksiPertanyaan.fromMap(result.first);
    }
    return null;
  }

  Future<List<ModelInspeksiPertanyaan>> getAlllInspeksiPertanyaanBySubKategoriId(int subKategoriId) async {
    final dbClient = await _getDb();
    final result = await dbClient.query('inspeksi_pertanyaan', where: 'subkategori_inspeksi_id = ?', whereArgs: [subKategoriId]);
    return result.map((modelInspeksiPertanyaan) => ModelInspeksiPertanyaan.fromMap(modelInspeksiPertanyaan)).toList();
  }

  Future<List<ModelInspeksiPertanyaan>> getAlllInspeksiPertanyaan() async {
    final dbClient = await _getDb();
    final result = await dbClient.transaction((txn) => txn.query('inspeksi_pertanyaan'));
    return result.map((modelInspeksiPertanyaan) => ModelInspeksiPertanyaan.fromMap(modelInspeksiPertanyaan)).toList();
  }

  Future<ModelInspeksiPertanyaan?> getPertanyaanByIdInspekPer(int id) async {
    final dbClient = await _getDb();
    final result = await dbClient.query('inspeksi_pertanyaan', where: 'id_inspeksi_pertanyaan = ?', whereArgs: [id]);
    if (result.length > 0) {
      return ModelInspeksiPertanyaan.fromMap(result.first);
    }
    return null;
  }

  Future<int> saveFotoInspeksi(FotoInspeksi fotoInspeksi) async {
    final dbClient = await _getDb();
    return await dbClient.insert('foto_inspeksi', fotoInspeksi.toMap());
  }

  Future<FotoInspeksi?> getFotoInspeksiByPertanyaanIdAndNamaFile(int id, String namaFile) async {
    final dbClient = await _getDb();
    final result = await dbClient.query('foto_inspeksi', where: 'id_inspeksi_pertanyaan = ? AND nama_file = ?', whereArgs: [id, namaFile]);
    if (result.length > 0) {
      return FotoInspeksi.fromMap(result.first);
    }
    return null;
  }

  Future<List<FotoInspeksi>> getAlllFotoInspeksiByPertanyaanId(int id) async {
    final dbClient = await _getDb();
    final result = await dbClient.query('foto_inspeksi', where: 'id_inspeksi_pertanyaan = ?', whereArgs: [id]);
    return result.map((fotoInspeksi) => FotoInspeksi.fromMap(fotoInspeksi)).toList();
  }

  Future<int> updateFotoInspeksi(FotoInspeksi fotoInspeksi) async {
    final dbClient = await _getDb();
    return await dbClient.update('foto_inspeksi', fotoInspeksi.toMap(), where: 'id_inspeksi_pertanyaan = ?', whereArgs: [fotoInspeksi.id_inspeksi_pertanyaan]);
  }

  Future<int> updatePertanyaanByIdInspekPer(ModelInspeksiPertanyaan modelInspeksiPertanyaan) async {
    final dbClient = await _getDb();
    return await dbClient.update('inspeksi_pertanyaan', modelInspeksiPertanyaan.toMap(), where: 'id_inspeksi_pertanyaan = ?', whereArgs: [modelInspeksiPertanyaan.id_inspeksi_pertanyaan]);
  }

  Future<void> deleteAllModelInspeksiPertanyaan() async {
    final dbClient = await _getDb();
    await dbClient.delete('inspeksi_pertanyaan');
  }

  Future<Database> _getDb() async {
    // if (_db == null) {
    //   _db = await initDatabase();
    // }
    _db ??= await initDatabase();
    return _db!;
  }
}
