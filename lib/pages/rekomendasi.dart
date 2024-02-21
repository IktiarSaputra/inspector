import 'dart:math';

import 'package:flutter/material.dart';

import 'package:inspector/pages/pertanyaan_inspeksi.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';


import '../db_helpers/database.dart';
import '../models/model_rekomendasi.dart';

class RekomendasiPage extends StatefulWidget {
  final int id_inspeksi_pertanyaan;

  const RekomendasiPage({Key? key, required this.id_inspeksi_pertanyaan})
      : super(key: key);

  @override
  _RekomendasiPageState createState() => _RekomendasiPageState();
}

class _RekomendasiPageState extends State<RekomendasiPage> {

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _longitudeController = TextEditingController();
  final _penanggungJawabController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _rekomendasiController = TextEditingController();
  final _prioritasController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _controller = TextEditingController();
  final dbHelper = DatabaseHelper();
  String lat = '';
  String long = '';
  int selectedPrioritas = 0;
  bool _isLoading = false;

  final List<Map<int, String>> options = [
  {0: 'Pilih Prioritas'},
  {1: 'Non Critical'},
  {2: 'Critical'},
];

  @override
  void initState() {
    super.initState();
    __getCurrentLocation();
    _getRekomendasi();
  }

  Future<void> _getRekomendasi() async {
    final pertanyaanInspeksi = await dbHelper.getRekomendasiByPertanyaanId(widget.id_inspeksi_pertanyaan);

    if (pertanyaanInspeksi != null) {
      setState(() {
        _penanggungJawabController.text = pertanyaanInspeksi.penanggung_jawab;
        _dueDateController.text = pertanyaanInspeksi.due_date;
        _rekomendasiController.text = pertanyaanInspeksi.rekomendasi;
        _prioritasController.text = int.parse(pertanyaanInspeksi.prioritas.toString()).toString();
        selectedPrioritas = int.parse(pertanyaanInspeksi.prioritas.toString());
      });
    } else {
      setState(() {
        _penanggungJawabController.text = 'KTT';
        _dueDateController.text = '';
        _rekomendasiController.text = '';
        _prioritasController.text = '';
      });
    }

    
  }

  void __getCurrentLocation() async {
    final LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Akses Lokasi Dibutuhkan'),
          content: const Text('Aplikasi ini membutuhkan akses lokasi'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device
    final Position position = await Geolocator.getCurrentPosition();
    setState(() {
      lat = position.latitude.toString();
      long = position.longitude.toString();
      _longitudeController.text = long;
      _latitudeController.text = lat;
    });
  }

  Future _saveRekomendasi() async {
    
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      ModelRekomendasi rekomendasi = ModelRekomendasi(
        id: null,
        id_rekomendasi: Random().nextInt(100),
        inspeksi_pertanyaan_id: widget.id_inspeksi_pertanyaan,
        penanggung_jawab: _penanggungJawabController.text,
        due_date: _dueDateController.text,
        rekomendasi: _rekomendasiController.text,
        prioritas: selectedPrioritas,
        status_tindakan: 0,
        catatan_tindakan: "-",
        tindak_lanjut: '-',
        file: null,
        review: 0,
        keterangan_review: null,
      );

      await dbHelper.getRekomendasiByPertanyaanId(widget.id_inspeksi_pertanyaan).then((value) async {
        if (value != null) {
          ModelRekomendasi rekomendasiupdate = ModelRekomendasi(
            id: value.id,
            id_rekomendasi: value.id_rekomendasi,
            inspeksi_pertanyaan_id: widget.id_inspeksi_pertanyaan,
            penanggung_jawab: _penanggungJawabController.text,
            due_date: _dueDateController.text,
            rekomendasi: _rekomendasiController.text,
            prioritas: selectedPrioritas,
            status_tindakan: 0,
            catatan_tindakan: "-",
            tindak_lanjut: '-',
            file: null,
            review: 0,
            keterangan_review: null,
          );
          await dbHelper.updateRekomendasi(rekomendasiupdate);
        } else {
          await dbHelper.saveModelRekomendasi(rekomendasi);
        }
      });

      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }

  }


  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Rekomendasi'),
      ),
      body: SingleChildScrollView(
        child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/BG.png"),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _penanggungJawabController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Penanggung Jawab',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Penanggung Jawab tidak boleh kosong';
                  }
                  return null;
                },
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField(
                decoration: const InputDecoration(
                  labelText: 'Prioritas',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.priority_high),
                ),
                value: selectedPrioritas,
                items: options.map((Map<int, String> option) {
                  final int value = option.keys.first;
                  final String label = option.values.first;
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(label),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Prioritas tidak boleh kosong';
                  } else if (value == 0) {
                    return 'Prioritas tidak boleh kosong';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _prioritasController.text = value.toString();
                    selectedPrioritas = int.parse(value.toString());
                  });
                },
              ),
              Visibility(
                visible: selectedPrioritas == 1 ? true : false,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _dueDateController,
                      decoration: const InputDecoration(
                        labelText: 'Due Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Due Date tidak boleh kosong';
                        }
                        return null;
                      },
                      onTap: () async {
                        DateTime? date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        var formatter = DateFormat('yyyy-MM-dd');
                        if (date != null) {
                          _dueDateController.text = formatter.format(date);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _longitudeController,
                decoration: const InputDecoration(
                  labelText: 'Longitude',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.location_on),
                ),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _latitudeController,
                decoration: const InputDecoration(
                  labelText: 'Latitude',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.location_on),
                ),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _rekomendasiController,
                decoration: InputDecoration(
                  labelText: 'Catatan Rekomendasi',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty || value == '-') {
                    return 'Catatan Rekomendasi tidak boleh kosong';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        fixedSize: Size(MediaQuery.of(context).size.width, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _saveRekomendasi().then((value) {
                            
                          }).whenComplete(() {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Berhasil'),
                                  content: const Text('Data berhasil disimpan'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }).catchError((error) {
                            print(error);
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Gagal'),
                                  content: const Text('Data gagal disimpan'),
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
                          });
                        }
                      },
                      child: const Text('Simpan'),
                    ),
            ],
          ),
        ),
      )
      )
    )
    );
  }
}

