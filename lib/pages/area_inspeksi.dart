// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names, library_private_types_in_public_api, avoid_function_literals_in_foreach_calls

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:inspector/models/kategoriinspeksi.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../db_helpers/database.dart';
import '../models/areainspeksi.dart';
import '../models/kategorisoalinspeksi.dart';
import '../models/model_foto_inspeksi.dart';
import '../models/model_inspeksi_area.dart';
import '../models/model_inspeksi_pertanyaan.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../models/model_kategori_inspeksi.dart';
import '../models/model_rekomendasi.dart';
import '../models/model_subkategori_inspeksi.dart';
import 'home.dart';

class AreaInspeksiPage extends StatefulWidget {
  final int surat_tugas_id; 
  const AreaInspeksiPage({Key? key, required this.surat_tugas_id,}) : super(key: key);

  @override
  _AreaInspeksiPageState createState() => _AreaInspeksiPageState();
}

class _AreaInspeksiPageState extends State<AreaInspeksiPage> {
  List<AreaInspeksi> _areaInspeksi = [];
  List<KategoriSoalInspeksi> _kategoriSoalInspeksi = [];
  final List<KategoriInspeksi> _kategoriInspeksi = [];
  final TextEditingController _inputAreaInspeksi = TextEditingController();
  late SharedPreferences preferences;
  bool _isLoading = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadKategoriSoalInspeksi();
    _loadAreaInspeksi();
    SharedPreferences.getInstance().then((SharedPreferences sp) {
      preferences = sp;
    });
  }

  Future<void> _loadAreaInspeksi() async {
    final dbHelper = DatabaseHelper();
    setState(() {
      _isLoading = true;
    });
    final areaInspeksi = await dbHelper.getAllAreaInspeksi(widget.surat_tugas_id);
    setState(() {
      _areaInspeksi = areaInspeksi;
      _isLoading = false;
    });
  }

  Future<void> _loadKategoriSoalInspeksi() async {
    final dbHelper = DatabaseHelper();
    setState(() {
      _isLoading = true;
    });
    final kategoriSoalInspeksi = await dbHelper.getAllKategoriSoalInspeksi(widget.surat_tugas_id);
    setState(() {
      _kategoriSoalInspeksi = kategoriSoalInspeksi;
      _isLoading = false;
    });

    for (var i = 0; i < _kategoriSoalInspeksi.length; i++) {
      dbHelper.getKategoriInspeksiById(_kategoriSoalInspeksi[i].id_kategori!).then((value) {
        if (value != null) {
          setState(() {
            _kategoriInspeksi.add(value);
          });
        }
      });
    }


  }


  Future _addAreaInspeksi(id, soal_id) async {
    final dbHelper = DatabaseHelper();
    String? token = preferences.getString('token');
    Map<String, String> headers = {"Authorization": "Bearer $token"};

    setState(() {
      _isProcessing = true;
    });

    for (var dataAreaInspeksi in _areaInspeksi.where((element) => element.id_soal_kategori == id && element.is_saved == false && element.kategori_id == soal_id)) {
      final responseKategoriInspeksi = await http.post(Uri.parse('https://inspector-app.xyz/api/addareakategori'), headers: headers, body: {
        'id_soal_kategori': dataAreaInspeksi.id_soal_kategori.toString(),
        'nama_area': dataAreaInspeksi.nama_area.toString(),
      });


      if (responseKategoriInspeksi.statusCode == 200) {
        var data = json.decode(responseKategoriInspeksi.body)['data'];
        AreaInspeksi areaInspeksi = AreaInspeksi(
          id_area: data,
          nama_area: dataAreaInspeksi.nama_area,
          id_soal_kategori: dataAreaInspeksi.id_soal_kategori,
          kategori_id: dataAreaInspeksi.kategori_id,
          surat_tugas_id: widget.surat_tugas_id,
          is_saved: true,
        );

        dbHelper.saveAreaInspeksi(areaInspeksi);
        _loadAreaInspeksi();
      
      } else {

        setState(() {
          _isProcessing = true;
        });
        
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Gagal'),
              content: const Text('Area Inspeksi Gagal Di Simpan'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }

    setState(() {
      _isProcessing = false;
    });
  } 

  Future<void> _getPertanyaanInspeksi() async {
    int? userId = preferences.getInt('id');
    String? token = preferences.getString('token');
    String? email = preferences.getString('email');
    String? nama = preferences.getString('name');
    Map<String, String> headers = {"Authorization": "Bearer $token"};

    setState(() {
      _isProcessing = true;
    });

    final dbHelper = DatabaseHelper();

    try {
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
            } else {
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
              } else {
              }
            });

            List<dynamic> dataPertanyaan = sub_kategori['pertanyaan'];

            dataPertanyaan.forEach((pertanyaan) async {
              final directory = await getApplicationDocumentsDirectory();
                List<dynamic> dataFoto = pertanyaan['foto'];
                final filePath = directory.path;
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
                      id_foto_inspeksi: foto['id'],
                      id_inspeksi_pertanyaan: foto['pertanyaan_inspeksi'],
                      nama_file: foto['nama_file'],
                      longitude: foto['longitude'],
                      latitude: foto['latitude'],
                    );

                    dbHelper.getFotoInspeksiByPertanyaanIdAndNamaFile(foto['pertanyaan_inspeksi'], foto['nama_file']).then((value) async {
                      if (value == null) {
                        dbHelper.saveFotoInspeksi(fotoInspeksi);
                      } else {
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
                    } else {
                    }
                  });

                  rekomendasi = pertanyaan['rekomendasi']['rekomendasi'];
                }

              ModelInspeksiPertanyaan modelInspeksiPertanyaan = ModelInspeksiPertanyaan(
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
                rekomendasi: rekomendasi,
                foto: file,
              );

              dbHelper.getInspeksiPertanyaanBySubKategoriIdAndIdPertanyaan(pertanyaan['subkategori_inspeksi_id'], pertanyaan['id_pertanyaan'], pertanyaan['id']).then((value) {
                if (value == null) {
                  dbHelper.saveModelInspeksiPertanyaan(modelInspeksiPertanyaan);
                } else {
                }
              });
              
            });
          });
        });
      });
      setState(() {
        _isProcessing = false;
      });

      showDialog(context: context, builder: (context) {
        return AlertDialog(
          title: const Text('Berhasil'),
          content: const Text('Pertanyaan berhasil ditambahkan'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(context, 
                
                MaterialPageRoute(builder: (context) => HomePage(email: email!, name: nama!)),
                (route) => false);
              },
              child: const Text('OK'),
            ),
          ],
        );
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(e.toString()),
            actions: <Widget>[
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Area Inspeksi'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/BG.png'),
            fit: BoxFit.cover,
          ),
        ),
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(5),
        child: Column(children: <Widget>[
          Expanded(
            child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: _kategoriInspeksi.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(top: 13),
                    child: ExpansionTile(
                      backgroundColor: Colors.white,
                      collapsedBackgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      collapsedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      childrenPadding: const EdgeInsets.all(10),
                      title: Text(_kategoriInspeksi[index].nama_kategori!),
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          child: Row (
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              ElevatedButton(
                                onPressed: () {
                                  AlertDialog alert = AlertDialog(
                                    title: const Text('Tambah Area Inspeksi'),
                                    content: TextFormField(
                                      controller: _inputAreaInspeksi,
                                      decoration: const InputDecoration(
                                        labelText: 'Nama Area Inspeksi',
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Tidak'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          var data = _areaInspeksi.where((element) => element.kategori_id == _kategoriInspeksi[index].id_kategori).toList();
                                          
                                          if (data.where((element) => element.nama_area == _inputAreaInspeksi.text).isNotEmpty) {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text('Gagal'),
                                                  content: const Text('Area Inspeksi sudah ada'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text('OK'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          } else {
                                            AreaInspeksi areaInspeksi = AreaInspeksi(
                                              nama_area: _inputAreaInspeksi.text,
                                              id_soal_kategori: _kategoriSoalInspeksi[index].id_soal_kategori,
                                              kategori_id: _kategoriSoalInspeksi[index].id_kategori,
                                              surat_tugas_id: widget.surat_tugas_id,
                                              is_saved: false,
                                            );

                                            
                                            setState(() {
                                              _areaInspeksi.add(areaInspeksi);
                                              areaInspeksi = AreaInspeksi(
                                                nama_area: '',
                                                id_soal_kategori: 0,
                                                kategori_id: 0,
                                                surat_tugas_id: 0,
                                                is_saved: false,
                                              );
                                            }); 

                                            _inputAreaInspeksi.clear();
                                            
                                          }                                     
                                        },
                                        child: const Text('Ya'),
                                      ),
                                    ],
                                  );

                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return alert;
                                    },
                                  );
                                },
                                child: const Text('Tambah'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  var filteredAreaInspeksi = _areaInspeksi.where((element) => element.id_soal_kategori == _kategoriSoalInspeksi[index].id_soal_kategori).toList();
                                  var countSavedAreaInspeksi = filteredAreaInspeksi.where((element) => element.is_saved == true).toList();
                                  if (filteredAreaInspeksi.isEmpty || filteredAreaInspeksi.length == 0) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Gagal'),
                                          content: const Text('Area Inspeksi belum ada'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else if(countSavedAreaInspeksi.length == filteredAreaInspeksi.length) {
                                    
                                  } else {
                                    _addAreaInspeksi(_kategoriSoalInspeksi[index].id_soal_kategori, _kategoriSoalInspeksi[index].id_kategori).then((value) {
                                    }).catchError((error) {
                                    });
                                  }
                              }, 
                              child: const Text('Simpan'),
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: _areaInspeksi.where((element) => element.id_soal_kategori == _kategoriSoalInspeksi[index].id_soal_kategori).length == 0
                              ? const Center(
                                  child: Text('Tidak ada area inspeksi'),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _areaInspeksi.where((element) => element.id_soal_kategori == _kategoriSoalInspeksi[index].id_soal_kategori).length,
                                  itemBuilder: (context, index2) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(_areaInspeksi.where((element) => element.id_soal_kategori == _kategoriSoalInspeksi[index].id_soal_kategori).toList()[index2].nama_area!),
                                          _areaInspeksi.where((element) => element.id_soal_kategori == _kategoriSoalInspeksi[index].id_soal_kategori).toList()[index2].is_saved == false ? 
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                              //print(nama_area);
                                                  _areaInspeksi.removeWhere((element) => element.id_soal_kategori == _kategoriSoalInspeksi[index].id_soal_kategori && element.nama_area == _areaInspeksi.where((element) => element.id_soal_kategori == _kategoriSoalInspeksi[index].id_soal_kategori).toList()[index2].nama_area);
                
                                              });
                                            },
                                            icon: const Icon(Icons.delete),
                                          ) : const SizedBox()
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              
                        ),
                      ],
                    )
                  );
                },
              ),
          ),
          Visibility(
            visible: _areaInspeksi.length > 0,
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 20),
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState)  {
                  return _isProcessing ?
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        onPrimary: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        minimumSize: const Size(double.infinity, 50)
                    ),
                    onPressed: ()  {
                      int? userId = preferences.getInt('id');
                      String? token = preferences.getString('token');
                      String? email = preferences.getString('email');
                      String? nama = preferences.getString('name');
                      Map<String, String> headers = {"Authorization": "Bearer $token"};
                      _getPertanyaanInspeksi().then((value) {
                        
                      }).whenComplete(() {
                        
                      }).catchError((error) {
                        
                      });
                    },
                    child: const Text('Generate Pertanyaan'),
                  );
                }
              ),
            ),
          )
        ],
        )
      ),
    );
  }
}

