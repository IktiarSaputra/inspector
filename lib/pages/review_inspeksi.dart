// ignore_for_file: unrelated_type_equality_checks, avoid_print, use_build_context_synchronously, non_constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:inspector/models/model_inspeksi_pertanyaan.dart';
import 'package:inspector/models/model_subkategori_inspeksi.dart';
import 'package:inspector/models/model_inspeksi_area.dart';
import 'package:inspector/models/model_kategori_inspeksi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db_helpers/database.dart';
import '../models/inspeksi_pertanyaan.dart';
import '../models/model_foto_inspeksi.dart';
import '../models/model_rekomendasi.dart';
import 'add_foto.dart';
import 'catatan.dart';
import 'rekomendasi.dart';
import 'selesai_inspeksi.dart';
import 'temuan.dart';

class ReviewInspeksiPage extends StatefulWidget {
  const ReviewInspeksiPage({Key? key, required this.surat_tugas_id}) : super(key: key);

  final int surat_tugas_id;

  @override
  _ReviewInspeksiPageState createState() => _ReviewInspeksiPageState();
}

class _ReviewInspeksiPageState extends State<ReviewInspeksiPage>  with AutomaticKeepAliveClientMixin {
  var connectivityResult;
  late DatabaseHelper dbHelper;
  late SharedPreferences preferences;
  String status = '';

  List<ModelInspeksiPertanyaan> _dataInspeksiPertanyaan = [];
  bool _isLoading = false;
  bool _isProcessing = false;
  List<dynamic> _kategoriInspeksi = [];
  List<ModelKategoriInspeksi> _kategoriSoalInspeksi = [];

  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper();
    SharedPreferences.getInstance().then((SharedPreferences sp) {
      preferences = sp;
    });
    Future.delayed(Duration.zero, () async {
      connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        const snackBar = SnackBar(
          content: Text('Tidak ada koneksi internet'),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        // ignore: unused_local_variable
        status = 'Offline';
        final kategoriSoalInspeksi = await dbHelper.getAlllKategoriInspeksiByStId(widget.surat_tugas_id);
          
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Offline'),
              content: const Text('Anda tidak dapat melihat review inspeksi, karena anda sedang offline, silahkan coba lagi ketika anda online'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        status = 'Online';
        final kategoriSoalInspeksi = await dbHelper.getAlllKategoriInspeksiByStId(widget.surat_tugas_id);
        _getPertanyaanInspeksi().then((value) {
            
        }).whenComplete(() {
          _loadKategoriSoalInspeksi();
        });
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  Future<File> getImageFileFromDirectory(int Id) async {
    final result = await dbHelper.getAlllFotoInspeksiByPertanyaanId(Id);
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final bytedata = await rootBundle.load('assets/images/empty.png');
    if (result.isEmpty) {
      final file = File('$path/empty.png');
      await file.writeAsBytes(bytedata.buffer.asUint8List(bytedata.offsetInBytes, bytedata.lengthInBytes));
      return file;
    } else {
      final file = File('$path/${result[0].nama_file}');
      return file;
    }
  }

  Future<void> _getPertanyaanInspeksi() async {
    int? userId = preferences.getInt('id');
    String? token = preferences.getString('token');
    Map<String, String> headers = {"Authorization": "Bearer $token"};

      setState(() {
        _isProcessing = true;
      });

      final dbHelper = DatabaseHelper();

      final responseKategoriInspeksi = await http.post(Uri.parse('https://inspector-app.xyz/api/inspeksipertanyaan'), headers: headers, body: {
        'id_surat_tugas': widget.surat_tugas_id.toString(),
        'id_user': userId.toString(),
      });

      List<dynamic> data = json.decode(responseKategoriInspeksi.body)['data'];

      data.forEach((kategori) async {
        ModelKategoriInspeksi modelKategoriInspeksi = ModelKategoriInspeksi(
          id_kategori: kategori['id'],
          kategori_id: kategori['kategori']['id'],
          nama_kategori: kategori['kategori']['nama_kategori'],
          surat_tugas_id: widget.surat_tugas_id,
        );

        await dbHelper.getKategoriInspeksiByStIdAndKategoriId(widget.surat_tugas_id, kategori['id'], kategori['kategori_id']).then((value) async {
          if (value == null) {
            dbHelper.saveModelKategoriInspeksi(modelKategoriInspeksi);
          } else {
            print('data 0 sudah ada');
          }
        });

        List<dynamic> dataAreaInspeksi = kategori['area_inspeksi'];

        dataAreaInspeksi.forEach((area_inspeksi) async {
          ModelInspeksiArea modelInspeksiArea = ModelInspeksiArea(
            id_area: area_inspeksi['id'],
            nama_area: area_inspeksi['nama_area'],
            kategori_inspeksi_id: area_inspeksi['soal_kategori_id'],
          );

          dbHelper.getInspeksiAreaBykategoriInspeksiIdAndAreaId(area_inspeksi['soal_kategori_id'], area_inspeksi['id']).then((value) async {
            if (value == null) {
              dbHelper.saveModelInspeksiArea(modelInspeksiArea);
              print('data 1 sudah disimpan');
            } else {
              print('data 1 sudah ada');
            }
          });

          List<dynamic> datasubkategori = area_inspeksi['subkategori'];

          datasubkategori.forEach((sub_kategori) async {
            
            ModelSubKategoriInspeksi modelSubKategoriInspeksi = ModelSubKategoriInspeksi(
              id_subkategori: sub_kategori['id'],
              area_id: sub_kategori['area_id'],
              nama_subkategori: sub_kategori['detail']['nama_subkategori'],
            );

            dbHelper.getSubKategoriInspeksiByAreaIdAndIdSubKategori(sub_kategori['area_id'], sub_kategori['id']).then((value) async {
              if (value == null) {
                dbHelper.saveModelSubKategoriInspeksi(modelSubKategoriInspeksi);
                print('data 2 sudah disimpan');
              } else {
                print('data 2 sudah ada');
              }
            });

            List<dynamic> dataPertanyaan = sub_kategori['pertanyaan'];

            dataPertanyaan.forEach((pertanyaan) async {
              final directory = await getApplicationDocumentsDirectory();
              List<dynamic> dataFoto = pertanyaan['foto'];
              final filePath = '${directory.path}';
              late dynamic file;
              if (dataFoto.isEmpty ){
                file = '';
              } else {
                List<dynamic> dataFoto = pertanyaan['foto'];
                file = dataFoto.first['nama_file'];
                dataFoto.forEach((foto) async {
                  final response = await Dio().get(
                    'https://inspector-app.xyz/upload/foto/${foto['nama_file']}',
                    options: Options(
                      responseType: ResponseType.bytes,
                      followRedirects: false,
                      validateStatus: (status) {
                        return status! < 500;
                      },
                    ),
                  );

                  FotoInspeksi fotoInspeksi = FotoInspeksi(
                    id: foto['id'],
                    id_foto_inspeksi: foto['id'],
                    id_inspeksi_pertanyaan: foto['pertanyaan_inspeksi'],
                    nama_file: foto['nama_file'],
                    longitude: foto['long'],
                    latitude: foto['lat'],
                  );

                  dbHelper.getFotoInspeksiByPertanyaanIdAndNamaFile(foto['pertanyaan_inspeksi'], foto['nama_file']).then((value) async {
                    if (value == null) {
                      dbHelper.saveFotoInspeksi(fotoInspeksi);
                      print('data foto sudah disimpan');
                    } else {
                      dbHelper.updateFotoInspeksi(fotoInspeksi);
                    }
                  });

                  final bytes = response.data;
                  await File('$filePath/${foto['nama_file']}').writeAsBytes(bytes);
                });
              }

              late String? rekomendasi;

              if(pertanyaan['rekomendasi'] == null){
                rekomendasi = '';
              } else {
                ModelRekomendasi modelRekomendasi = ModelRekomendasi(
                  id : pertanyaan['rekomendasi']['id'],
                  id_rekomendasi: pertanyaan['rekomendasi']['id'],
                  inspeksi_pertanyaan_id: pertanyaan['rekomendasi']['pertanyaan_inspeksi_id'],
                  rekomendasi: pertanyaan['rekomendasi']['rekomendasi'],
                  tindak_lanjut: pertanyaan['rekomendasi']['tindak_lanjut'],
                  due_date: pertanyaan['rekomendasi']['due_date'],
                  prioritas: pertanyaan['rekomendasi']['prioritas'],
                  status_tindakan: pertanyaan['rekomendasi']['status_tindakan'],
                  catatan_tindakan: pertanyaan['rekomendasi']['catatan_tindakan'],
                  file: pertanyaan['rekomendasi']['file'],
                  penanggung_jawab: pertanyaan['rekomendasi']['penanggung_jawab'],
                  review: pertanyaan['rekomendasi']['review'],
                  keterangan_review: pertanyaan['rekomendasi']['keterangan_review'],
                );

                dbHelper.getRekomendasiByPertanyaanId(pertanyaan['rekomendasi']['pertanyaan_inspeksi_id']).then((value) {
                  if (value == null) {
                    dbHelper.saveModelRekomendasi(modelRekomendasi);
                    print('data rekomendasi sudah disimpan');
                  } else {
                    dbHelper.updateRekomendasi(modelRekomendasi);
                  }
                });

                rekomendasi = pertanyaan['rekomendasi']['rekomendasi'];
              }
            
              ModelInspeksiPertanyaan modelInspeksiPertanyaan = ModelInspeksiPertanyaan(
                id: pertanyaan['id'],
                id_inspeksi_pertanyaan: pertanyaan['id'],
                id_pertanyaan: pertanyaan['id_pertanyaan'],
                subkategori_inspeksi_id: pertanyaan['subkategori_inspeksi_id'],
                jawaban: pertanyaan['jawaban'],
                aman: pertanyaan['aman'],
                ramah_lingkungan: pertanyaan['ramah_lingkungan'],
                catatan: pertanyaan['catatan'],
                personil_inspeksi: pertanyaan['personil_inspeksi'],
                review: pertanyaan['review'],
                pertanyaan: pertanyaan['detail_pertanyaan']['pertanyaan'],
                video: pertanyaan['detail_pertanyaan']['video'],
                rekomendasi: pertanyaan['rekomendasi'],
                foto: file,
              );
              

              dbHelper.getInspeksiPertanyaanBySubKategoriIdAndIdPertanyaan(pertanyaan['subkategori_inspeksi_id'], pertanyaan['id_pertanyaan'], pertanyaan['id']).then((value) {
                if (value == null) {
                  dbHelper.saveModelInspeksiPertanyaan(modelInspeksiPertanyaan);
                  print('data pertanyaan sudah disimpan');
                } else {
                  dbHelper.updatePertanyaanByIdInspekPer(modelInspeksiPertanyaan);
                }
              });
              
            });
          });
        });
      });
    
      setState(() {
        _isProcessing = false;
      });
    }

  Future<void> _loadKategoriSoalInspeksi() async {
    final kategoriSoalInspeksi = await dbHelper.getAlllKategoriInspeksiByStId(widget.surat_tugas_id);
    final areaInspeksi = await dbHelper.getAllInspeksiArea();
    final subCategoryinspeksi = await dbHelper.getAlllSubKategoriInspeksi();
    final inspeksiPertanyaan = await dbHelper.getAlllInspeksiPertanyaan();

    setState(() {
      _isProcessing = true;
    });

    List<ModelKategoriInspeksi> kategoriSoalInspeksis = [];
    for(var kategori in kategoriSoalInspeksi) {
      List<ModelInspeksiArea> areaInspeksiByKatId = [];
      for(var area in areaInspeksi.where((area) => area.kategori_inspeksi_id == kategori.id_kategori).toList()) {
        List<ModelSubKategoriInspeksi> subKategori = [];
        for(var subkategori in subCategoryinspeksi.where((subkategori) => subkategori.area_id == area.id_area).toList()) {
          List<ModelInspeksiPertanyaan> pertanyaanInspeksiBySubId = [];
          for(var pertanyaan in inspeksiPertanyaan.where((pertanyaan) => pertanyaan.subkategori_inspeksi_id == subkategori.id_subkategori).toList()) {
            pertanyaanInspeksiBySubId.add(ModelInspeksiPertanyaan(id_inspeksi_pertanyaan: pertanyaan.id_inspeksi_pertanyaan, id_pertanyaan: pertanyaan.id_pertanyaan, subkategori_inspeksi_id: pertanyaan.subkategori_inspeksi_id, jawaban: pertanyaan.jawaban, aman: pertanyaan.aman, ramah_lingkungan: pertanyaan.ramah_lingkungan, catatan: pertanyaan.catatan, personil_inspeksi: pertanyaan.personil_inspeksi, review: pertanyaan.review, pertanyaan: pertanyaan.pertanyaan, video: pertanyaan.video, rekomendasi: pertanyaan.rekomendasi, foto: pertanyaan.foto));
            _dataInspeksiPertanyaan.add(ModelInspeksiPertanyaan(id_inspeksi_pertanyaan: pertanyaan.id_inspeksi_pertanyaan, id_pertanyaan: pertanyaan.id_pertanyaan, subkategori_inspeksi_id: pertanyaan.subkategori_inspeksi_id, jawaban: pertanyaan.jawaban, aman: pertanyaan.aman, ramah_lingkungan: pertanyaan.ramah_lingkungan, catatan: pertanyaan.catatan, personil_inspeksi: pertanyaan.personil_inspeksi, review: pertanyaan.review, pertanyaan: pertanyaan.pertanyaan, video: pertanyaan.video, rekomendasi: pertanyaan.rekomendasi, foto: pertanyaan.foto));
          }
          
          subKategori.add(ModelSubKategoriInspeksi(id_subkategori: subkategori.id_subkategori, area_id: subkategori.area_id, nama_subkategori: subkategori.nama_subkategori, pertanyaan: pertanyaanInspeksiBySubId));
        }
        areaInspeksiByKatId.add(ModelInspeksiArea(id_area: area.id_area, nama_area: area.nama_area, kategori_inspeksi_id: area.kategori_inspeksi_id, subkategori: subKategori));
      }
      kategoriSoalInspeksis.add(
        ModelKategoriInspeksi(id_kategori: kategori.id_kategori, nama_kategori: kategori.nama_kategori, surat_tugas_id: kategori.surat_tugas_id, kategori_id: kategori.kategori_id, area: areaInspeksiByKatId)
      );
    }


    setState(() {
      _kategoriSoalInspeksi = kategoriSoalInspeksis;
      _isProcessing = false;
    });
  }

  Future<void> _saveJawabanPertanyaan(int id, jawaban) async {
    final pertanyaanInspeksi = await dbHelper.getPertanyaanByIdInspekPer(id);
    
    if (jawaban == 1) {
      if (pertanyaanInspeksi?.catatan != '-' && pertanyaanInspeksi?.catatan != null) {
        final result = await dbHelper.getAlllFotoInspeksiByPertanyaanId(id);
        final directory = await getApplicationDocumentsDirectory();
        final path = directory.path;
        if (result.isEmpty) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Peringatan'),
                content: const Text('Anda belum mengupload foto'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          ModelInspeksiPertanyaan updatedPertanyaanInspeksi = ModelInspeksiPertanyaan(
            id: pertanyaanInspeksi?.id,
            id_inspeksi_pertanyaan: pertanyaanInspeksi!.id_inspeksi_pertanyaan,
            id_pertanyaan: pertanyaanInspeksi.id_pertanyaan,
            subkategori_inspeksi_id: pertanyaanInspeksi.subkategori_inspeksi_id,
            jawaban: jawaban,
            aman: pertanyaanInspeksi.aman,
            ramah_lingkungan: pertanyaanInspeksi.ramah_lingkungan,
            pertanyaan: pertanyaanInspeksi.pertanyaan,
            personil_inspeksi: pertanyaanInspeksi.personil_inspeksi,
            catatan: pertanyaanInspeksi.catatan,
          );

          setState(() {
            _dataInspeksiPertanyaan.forEach((element) {
              if (element.id_inspeksi_pertanyaan == id) {
                element.jawaban = jawaban;
                element.catatan = pertanyaanInspeksi.catatan;
              }
            });
          });
          await dbHelper.updatePertanyaanByIdInspekPer(updatedPertanyaanInspeksi);

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Peringatan'),
                content: const Text('Jawaban berhasil disimpan pada mode offline'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Peringatan'),
              content: const Text('Catatan tidak boleh kosong'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else if (jawaban == 2) {
      if (pertanyaanInspeksi?.catatan != '-' && pertanyaanInspeksi?.catatan != null) {
        final rekomendasipertanyaan = await dbHelper.getRekomendasiByPertanyaanId(pertanyaanInspeksi?.id_inspeksi_pertanyaan);
        if (rekomendasipertanyaan == null) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Peringatan'),
                content: const Text('Anda belum mengisi rekomendasi'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          final result = await dbHelper.getAlllFotoInspeksiByPertanyaanId(id);
          final directory = await getApplicationDocumentsDirectory();
          final path = directory.path;
          
          if (result.isEmpty) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Peringatan'),
                  content: const Text('Anda belum mengupload foto'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          } else {
            ModelInspeksiPertanyaan updatedPertanyaanInspeksi = ModelInspeksiPertanyaan(
              id: pertanyaanInspeksi?.id,
              id_inspeksi_pertanyaan: pertanyaanInspeksi!.id_inspeksi_pertanyaan,
              id_pertanyaan: pertanyaanInspeksi.id_pertanyaan,
              subkategori_inspeksi_id: pertanyaanInspeksi.subkategori_inspeksi_id,
              jawaban: jawaban,
              aman: pertanyaanInspeksi.aman,
              ramah_lingkungan: pertanyaanInspeksi.ramah_lingkungan,
              pertanyaan: pertanyaanInspeksi.pertanyaan,
              personil_inspeksi: pertanyaanInspeksi.personil_inspeksi,
              catatan: pertanyaanInspeksi.catatan,
            );

            setState(() {
              _dataInspeksiPertanyaan.forEach((element) {
                if (element.id_inspeksi_pertanyaan == id) {
                  element.jawaban = jawaban;
                  element.catatan = pertanyaanInspeksi.catatan;
                }
              });
            });

            await dbHelper.updatePertanyaanByIdInspekPer(updatedPertanyaanInspeksi);

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Peringatan'),
                  content: const Text('Jawaban berhasil disimpan pada mode offline'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Peringatan'),
              content: const Text('Temuan tidak boleh kosong'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> _uploadJawaban() async {
    setState(() {
      _isLoading = true;
    });
    
    int? userId = preferences.getInt('id');
    String? token = preferences.getString('token');
    Map<String, String> headers = {"Authorization": "Bearer $token"};
    print(_dataInspeksiPertanyaan.where((element) => element.jawaban == 1 || element.jawaban == 2).toList().length);
    _dataInspeksiPertanyaan.forEach((elementpertanyaan) async {
      if(elementpertanyaan.jawaban == 1 || elementpertanyaan.jawaban == 2) {
        try {
          final response = await http.post(Uri.parse('https://inspector-app.xyz/api/updatejawaban'), headers: headers, body: {
            'id_pertanyaan_inspeksi': elementpertanyaan.id_inspeksi_pertanyaan.toString(),
            'jawaban': elementpertanyaan.jawaban.toString(),
            'aman': elementpertanyaan.aman.toString(),
            'ramah_lingkungan': elementpertanyaan.ramah_lingkungan.toString(),
            'temuan': elementpertanyaan.catatan,
          });

          if (response.statusCode == 200) {

            final result = await dbHelper.getAlllFotoInspeksiByPertanyaanId(elementpertanyaan.id_inspeksi_pertanyaan);
            final directory = await getApplicationDocumentsDirectory();
            final path = directory.path;

            if (result.isNotEmpty) {
              final file = File('$path/${result[0].nama_file}');
              final bytes = await file.readAsBytesSync();       

              print(elementpertanyaan.id_inspeksi_pertanyaan.toString());     
              
              try {
                final responsefoto = await Dio().post('https://inspector-app.xyz/api/uploadfoto', data: FormData.fromMap({
                'pertanyaan_inspeksi': elementpertanyaan.id_inspeksi_pertanyaan.toString(),
                'file': await MultipartFile.fromFile(file.path, filename: result[0].nama_file),
                'long' : result[0].longitude.toString(),
                'lat' : result[0].latitude.toString(),

              }), options: Options(headers: headers));

              print(responsefoto.statusCode);

              if (responsefoto.statusCode == 200) {
                List<dynamic> data = responsefoto.data['data'];
                data.forEach((element) async {
                  FotoInspeksi fotoInspeksi = FotoInspeksi(
                    id: element['id'],
                    id_foto_inspeksi: element['id'],
                    id_inspeksi_pertanyaan: element['pertanyaan_inspeksi'],
                    nama_file: element['nama_file'],
                    longitude: element['long'],
                    latitude: element['lat'],
                  );

                  await dbHelper.updateFotoInspeksi(fotoInspeksi);
                });
              }
              } catch (error) {
               print(error); 
              }
            }

            if(elementpertanyaan.jawaban == 2){
              final rekomendasipertanyaan = await dbHelper.getRekomendasiByPertanyaanId(elementpertanyaan.id_inspeksi_pertanyaan);
              //print(rekomendasipertanyaan?.rekomendasi);
              
              final responserekomendasi = await http.post(Uri.parse('https://inspector-app.xyz/api/updaterekomendasi'), headers: headers, body: {
                'pertanyaan_inspeksi_id': rekomendasipertanyaan!.inspeksi_pertanyaan_id.toString(),
                'rekomendasi': rekomendasipertanyaan.rekomendasi,
                'penanggung_jawab': rekomendasipertanyaan.penanggung_jawab,
                'due_date': rekomendasipertanyaan.due_date,
                'prioritas': rekomendasipertanyaan.prioritas.toString(),
              });

              if(responserekomendasi.statusCode == 200) {
                //List<dynamic> data = json.decode(response.body);
                print(response.body);
              } else {
                print('rekomendasi gagal diupload');
              }
            }
          } else {
            print('jawaban gagal diupload');
          }
        } catch (error) {
          print(error);
        }
      }
    });

    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildCategory(ModelKategoriInspeksi kategori) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        backgroundColor: Colors.white,
        collapsedBackgroundColor: Colors.white,
        childrenPadding: const EdgeInsets.all(4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Icon(Icons.apps),
            const SizedBox(width: 10),
            Expanded(child: Text(kategori.nama_kategori)),
          ],
        ),
        children: <Widget>[
          ListView.builder(
            physics:  const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: kategori.area?.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildArea(kategori.area![index]);
            },
          ),
        ],
      )
    );
  }

  Widget _buildArea(ModelInspeksiArea area) {
    return ExpansionTile(
      backgroundColor: Colors.white,
      collapsedBackgroundColor: Colors.white,
      childrenPadding: const EdgeInsets.all(4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.location_on),
          const SizedBox(width: 10),
          Text(area.nama_area),
        ],
      ),
      children: <Widget>[
        ListView.builder(
          physics:  const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: area.subkategori?.length,
          itemBuilder: (BuildContext context, int index) {
            String abjad = String.fromCharCode('A'.codeUnitAt(0) + index);
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: _buildSubCategory(area.subkategori![index], abjad),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSubCategory(ModelSubKategoriInspeksi subkategori, String abjad) {
    return ExpansionTile(
      backgroundColor: Colors.white,
      collapsedBackgroundColor: Colors.white,
      childrenPadding: const EdgeInsets.all(4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: Text(
        abjad + '. ' + subkategori.nama_subkategori,
        textAlign: TextAlign.justify,
      ),
      children: <Widget>[
        ListView.builder(
          physics:  const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: subkategori.pertanyaan?.length,
          itemBuilder: (BuildContext context, int index) {
            String nomor = String.fromCharCode('1'.codeUnitAt(0) + index);
            
            return _buildPertanyaan(subkategori.pertanyaan![index], nomor);
          },
        ),
      ],
    );
  }

  Widget _buildPertanyaan(ModelInspeksiPertanyaan pertanyaan, String nomor) {
    int? jawaban = pertanyaan.jawaban;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.only(bottom: 15),
      child: Column(
        children: <Widget>[
          Text(
            nomor + '. ' + pertanyaan.pertanyaan,
            textAlign: TextAlign.justify,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                        pertanyaan.jawaban = 1;
                    });
                  },
                  icon: const Icon(
                    Icons.check_circle_outline
                  ),
                  label: const Text('Ya'),
                  style: ElevatedButton.styleFrom(
                    primary:     pertanyaan.jawaban == 1 ? Colors.green : Colors.transparent,
                    elevation: 0,
                    onPrimary:     pertanyaan.jawaban == 1 ? Colors.white : Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                      side: const BorderSide(color: Colors.green)
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                        pertanyaan.jawaban = 2;
                    });
                  },
                  icon: const Icon(
                    Icons.cancel_outlined
                  ),
                  label: const Text('Tidak'),
                  style: ElevatedButton.styleFrom(
                    primary:     pertanyaan.jawaban == 2 ? Colors.red : Colors.transparent,
                    elevation: 0,
                    onPrimary:     pertanyaan.jawaban == 2 ? Colors.white : Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                      side: const BorderSide(color: Colors.red)
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {

                    setState(() {
                        pertanyaan.jawaban = 0;
                    });
                  },
                  icon: const Icon(
                    Icons.remove_circle_outline
                  ),
                  label: const Text('N/A'),
                  style: ElevatedButton.styleFrom(
                    primary:     pertanyaan.jawaban == 0 ? Colors.orange : Colors.transparent,
                    elevation: 0,
                    onPrimary:     pertanyaan.jawaban == 0 ? Colors.white : Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                      side: const BorderSide(color: Colors.orange)
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Visibility(
            visible: pertanyaan.jawaban == 1,
            child: Container(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CatatanPage(
                                id_inspeksi_pertanyaan: pertanyaan.id_inspeksi_pertanyaan,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.sticky_note_2_outlined
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.transparent,
                          onPrimary: Colors.blue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                            side: const BorderSide(color: Colors.blue)
                          ),
                        ),
                        label: const Text('Catatan'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          getImageFileFromDirectory(pertanyaan.id_inspeksi_pertanyaan).then((value) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Preview Foto'),
                                  content: Container(
                                    height: MediaQuery.of(context).size.height * 0.5,
                                    width: MediaQuery.of(context).size.width * 0.5,
                                    child: Image.file(value),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Tutup'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          });
                        },
                        icon: const Icon(
                          Icons.image_outlined
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.transparent,
                          onPrimary: Colors.blue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                            side: const BorderSide(color: Colors.blue)
                          ),
                        ),
                        label: const Text('Preview Foto'),
                      ),
                    ],
                  ),
                  
                ],
              )
            ),
          ),
          Visibility(
            visible: pertanyaan.jawaban == 2,
            child: Container(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TemuanPage(
                                id_inspeksi_pertanyaan: pertanyaan.id_inspeksi_pertanyaan,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.report_gmailerrorred_outlined
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.transparent,
                          onPrimary: Colors.blue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                            side: const BorderSide(color: Colors.blue)
                          ),
                        ),
                        label: const Text('Temuan'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RekomendasiPage(
                                id_inspeksi_pertanyaan: pertanyaan.id_inspeksi_pertanyaan,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.speaker_notes_outlined,
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.transparent,
                          onPrimary: Colors.blue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                            side: const BorderSide(color: Colors.blue)
                          ),
                        ),
                        label: const Text('Rekomendasi'),
                      ),
                    ],
                  ),
                ],
              )
            ),
          ),
          Visibility(
            visible: pertanyaan.jawaban == 2,
            child: Container(
              child: Column(
                children: <Widget>[
                  ElevatedButton.icon(
                    onPressed: () {
                      getImageFileFromDirectory(pertanyaan.id_inspeksi_pertanyaan).then((value) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Preview Foto'),
                              content: Container(
                                height: MediaQuery.of(context).size.height * 0.5,
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Image.file(value),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Tutup'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      });
                    },
                    icon: const Icon(
                      Icons.image_outlined
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.transparent,
                      onPrimary: Colors.blue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                        side: const BorderSide(color: Colors.blue)
                      ),
                      fixedSize: Size(MediaQuery.of(context).size.width, 40),
                    ),
                    label: const Text('Preview Foto'),
                  ),
                  const SizedBox(width: 10),
                ],
              )
            ),
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pertanyaan Inspeksi'),
      ),
      body: Container(
        decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/BG.png"),
                fit: BoxFit.cover,
              ),
            ),
          height: MediaQuery.of(context).size.height,
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(10),
                child: _isProcessing ? const Center(child: CircularProgressIndicator()) : ListView.builder(
                  itemCount: _kategoriSoalInspeksi.length,
                  itemBuilder: (context, index) {
                    return _buildCategory(_kategoriSoalInspeksi[index]);
                  },
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Peringatan'),
                            content: const Text('Apakah anda yakin ingin kembali?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Tidak'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Ya'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      fixedSize: Size(MediaQuery.of(context).size.width, 40),
                    ),
                    child: const Text('Kembali'),
                  ),
            ),
          ],
        ),
      )
    );
  }
}

