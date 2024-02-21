// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db_helpers/database.dart';
import 'package:http/http.dart' as http;
import '../models/kategoriinspeksi.dart';
import '../models/kategorisoalinspeksi.dart';
import 'area_inspeksi.dart';

class KategoriInspeksiPage extends StatefulWidget {
  final int surat_tugas_id;
  const KategoriInspeksiPage({Key? key, required this.surat_tugas_id}) : super(key: key);

  @override
  _KategoriInspeksiPageState createState() => _KategoriInspeksiPageState();
}

class _KategoriInspeksiPageState extends State<KategoriInspeksiPage> {
  List<KategoriInspeksi> _kategoriInspeksi = [];
  List<dynamic> selectedIndexes = [];
  late SharedPreferences preferences;
  bool _isLoading = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    //_getKategoriSoalInspeksi();
    _loadKategoriInspeksi();
    SharedPreferences.getInstance().then((SharedPreferences sp) {
      preferences = sp;
    });
  }

  Future<void> _loadKategoriInspeksi() async {
    final dbHelper = DatabaseHelper();
    setState(() {
      _isLoading = true;
    });
    
    final kategoriInspeksi = await dbHelper.getAllKategoriInspeksi();

    setState(() {
      _kategoriInspeksi = kategoriInspeksi;
      _isLoading = false;
    });

    for (var i = 0; i < _kategoriInspeksi.length; i++) {
      dbHelper.getKategoriSoalInspeksiById(_kategoriInspeksi[i].id_kategori!, widget.surat_tugas_id).then((value) {
        if (value != null) {
          setState(() {
            selectedIndexes.add(i);
          });
        }
      });
    }
  }

  Future<void> _getKategoriSoalInspeksi() async {

    setState(() {
      _isLoading = true;
    });

    final dbHelper = DatabaseHelper();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('id');
    String? token = prefs.getString('token');
    Map<String, String> headers = {"Authorization": "Bearer $token"};
    final response = await http.post(
      Uri.parse('https://inspector-app.xyz/api/getsoalkategori/'), 
      headers: headers,
      body: {
        'id_surat_tugas': widget.surat_tugas_id.toString(),
      },
    );

    print(response.body);
       
    if (response.statusCode == 200) {
      var data = json.decode(response.body)['data'];
      for (var i = 0; i < data.length; i++) {
        KategoriSoalInspeksi kategoriSoalInspeksi = KategoriSoalInspeksi(
          id_kategori: data[i]['id_kategori'],
          id_soal_kategori: data[i]['id_soal_kategori'],
          surat_tugas_id: data[i]['surat_tugas_id'],
          nama_kategori: data[i]['nama_kategori'],
        );

        dbHelper.getKategoriSoalInspeksiById(data[i]['id_kategori'], data[i]['surat_tugas_id']).then((value) {
          if (value == null) {
            dbHelper.saveKategoriSoalInspeksi(kategoriSoalInspeksi);
          }
        });
      }
    }
  }

  Future<void> _addKategoriToServer(id, nama_kategori) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('id');
    String? token = prefs.getString('token');
    Map<String, String> headers = {"Authorization": "Bearer $token"};
    final dbHelper = DatabaseHelper();

    setState(() {
      _isProcessing = true;
    });

    final response = await http.post(
      Uri.parse('https://inspector-app.xyz/api/addsoalkategori'),
      headers: headers,
      body: {
        'id_kategori': id.toString(),
        'id_surat_tugas': widget.surat_tugas_id.toString(),
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      int? id_kategori = data['id_soal_kategori'];
      print(id_kategori);
      print(id);
      KategoriSoalInspeksi kategoriSoalInspeksi = KategoriSoalInspeksi(
        id_kategori: id,
        id_soal_kategori: data['id_soal_kategori'],
        surat_tugas_id: widget.surat_tugas_id,
        nama_kategori: nama_kategori,
      );

      dbHelper.getKategoriSoalInspeksiById(id!, widget.surat_tugas_id).then((value) {
        if (value == null) {
          dbHelper.saveKategoriSoalInspeksi(kategoriSoalInspeksi);
        }
      });

      setState(() {
        _isProcessing = false;
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Gagal'),
            content: const Text('Kategori gagal ditambahkan'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _deleteKategoriFromServer(id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('id');
    String? token = prefs.getString('token');
    Map<String, String> headers = {"Authorization": "Bearer $token"};
    final dbHelper = DatabaseHelper();

    // ignore: use_build_context_synchronously

    final response = await http.post(
      Uri.parse('https://inspector-app.xyz/api/deletesoalkategori'),
      headers: headers,
      body: {
        'id_kategori': id.toString(),
        'surat_tugas_id': widget.surat_tugas_id.toString(),
      },
    );

    if (response.statusCode == 200) {
      dbHelper.deleteKategoriSoalInspeksiById(id).then((value) {
        print('delete');
      });

      setState(() {
        _isProcessing = false;
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Gagal'),
            content: const Text('Kategori gagal dihapus'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
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
        title: const Text('Kategori Inspeksi'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/BG.png'),
            fit: BoxFit.cover,
          ),
        ),
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(5),
        child:  Column(
          children: <Widget>[
            Expanded(
              child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: _kategoriInspeksi.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: CheckboxListTile(
                      title: Text(_kategoriInspeksi[index].nama_kategori),
                      value: selectedIndexes.contains(index),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _addKategoriToServer(_kategoriInspeksi[index].id_kategori!, _kategoriInspeksi[index].nama_kategori).then((value) {
                              return selectedIndexes.add(index);
                            }).whenComplete(() {
                            }).catchError((error) {
                            });
                            
                            print(selectedIndexes);
                          } else {
                            _isProcessing = true;
                            _deleteKategoriFromServer(_kategoriInspeksi[index].id_kategori!).then((value) {
                              return selectedIndexes.remove(index);   
                            }).whenComplete(() {
                            }).catchError((error) {
                               print(error);
                            });
                            
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: _isProcessing
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ElevatedButton(
                onPressed: () {
                  
                  if(selectedIndexes.length == 0) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Gagal'),
                          content: const Text('Pilih kategori terlebih dahulu'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AreaInspeksiPage(surat_tugas_id: widget.surat_tugas_id),
                      ),
                    );
                  }

                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  onPrimary: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  minimumSize: const Size(double.infinity, 50)
                ),
                child: const Text('Selanjutnya'),
              ),
            )
          ],
        )
      )
    );
  }
}