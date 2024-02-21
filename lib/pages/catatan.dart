import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../db_helpers/database.dart';
import '../models/model_inspeksi_pertanyaan.dart';
import 'pertanyaan_inspeksi.dart';

class CatatanPage extends StatefulWidget {
  final int id_inspeksi_pertanyaan;

  const CatatanPage({Key? key, required this.id_inspeksi_pertanyaan})
      : super(key: key);

  @override

  _CatatanPageState createState() => _CatatanPageState();
}

class _CatatanPageState extends State<CatatanPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final _catatanController = TextEditingController();
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _getPertanyaanInspeksi();
  }

  void _getPertanyaanInspeksi() async {
    final pertanyaanInspeksi = await dbHelper.getPertanyaanByIdInspekPer(widget.id_inspeksi_pertanyaan);

    setState(() {
      _catatanController.text = pertanyaanInspeksi?.catatan;
    });
  }

  Future<void> _updateCatatan() async {
    setState(() {
      _isLoading = true;
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
          catatan: _catatanController.text,
        );

        await dbHelper.updatePertanyaanByIdInspekPer(updatedPertanyaanInspeksi);
      }
    }

    setState(() {
      _isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catatan'),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _catatanController,
                decoration: InputDecoration(
                  labelText: 'Catatan',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty || value == '-') {
                    return 'Catatan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _updateCatatan().then((value) {
                      
                    }).whenComplete(() {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Berhasil'),
                            content: Text('Catatan berhasil disimpan'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                },
                                child: Text('OK'),
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
                            title: Text('Gagal'),
                            content: Text('Catatan gagal disimpan'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  onPrimary: Colors.white,
                  fixedSize: Size(MediaQuery.of(context).size.width, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                child: Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}