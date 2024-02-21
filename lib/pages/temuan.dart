// ignore_for_file: non_constant_identifier_names, library_private_types_in_public_api

import 'package:flutter/material.dart';
import '../db_helpers/database.dart';
import '../models/model_inspeksi_pertanyaan.dart';

class TemuanPage extends StatefulWidget {
  final int id_inspeksi_pertanyaan;

  const TemuanPage({Key? key, required this.id_inspeksi_pertanyaan})
      : super(key: key);

  @override

  _TemuanPageState createState() => _TemuanPageState();
}

class _TemuanPageState extends State<TemuanPage> {
  final _formKey = GlobalKey<FormState>();
  final _temuanController = TextEditingController();
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _getPertanyaanInspeksi();
  }

  void _getPertanyaanInspeksi() async {
    final pertanyaanInspeksi = await dbHelper.getPertanyaanByIdInspekPer(widget.id_inspeksi_pertanyaan);

    setState(() {
      _temuanController.text = pertanyaanInspeksi?.catatan;
    });
  }

  Future<void> _updateCatatan() async {
    setState(() {
    });

    if (_formKey.currentState!.validate()) {
      final pertanyaanInspeksi = await dbHelper.getPertanyaanByIdInspekPer(widget.id_inspeksi_pertanyaan);

      if (pertanyaanInspeksi != null) {
        ModelInspeksiPertanyaan updatedPertanyaanInspeksi = ModelInspeksiPertanyaan(
          id: pertanyaanInspeksi.id,
          id_inspeksi_pertanyaan: pertanyaanInspeksi.id_inspeksi_pertanyaan,
          id_pertanyaan: pertanyaanInspeksi.id_pertanyaan,
          subkategori_inspeksi_id: pertanyaanInspeksi.subkategori_inspeksi_id,
          jawaban: pertanyaanInspeksi.jawaban,
          aman: pertanyaanInspeksi.aman,
          ramah_lingkungan: pertanyaanInspeksi.ramah_lingkungan,
          pertanyaan: pertanyaanInspeksi.pertanyaan,
          personil_inspeksi: pertanyaanInspeksi.personil_inspeksi,
          catatan: _temuanController.text,
        );

        await dbHelper.updatePertanyaanByIdInspekPer(updatedPertanyaanInspeksi);
      }
    }

    setState(() {
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Temuan'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _temuanController,
                decoration: const InputDecoration(
                  labelText: 'Temuan',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty || value == '-') {
                    return 'Temuan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if(_formKey.currentState!.validate()) {
                    _updateCatatan().then((value) {
                      
                    }).whenComplete(() {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Berhasil'),
                            content: const Text('Temuan berhasil disimpan'),
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
                    }).catchError((error) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Gagal'),
                            content: const Text('Temuan gagal disimpan'),
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
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blue,
                  fixedSize: Size(MediaQuery.of(context).size.width, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}