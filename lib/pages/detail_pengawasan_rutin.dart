// ignore_for_file: prefer_final_fields, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:inspector/pages/pertanyaan_inspeksi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../db_helpers/database.dart';
import '../models/personilinspeksi.dart';
import '../models/surattugas.dart';
import 'kategori_inspeksi.dart';
import 'review_inspeksi.dart';


class DetailPengawasanRutin extends StatefulWidget {
  final int? id;
  const DetailPengawasanRutin({Key? key, this.id}) : super(key: key);

  @override
  _DetailPengawasanRutinState createState() => _DetailPengawasanRutinState();
}

class _DetailPengawasanRutinState extends State<DetailPengawasanRutin> {
  final dbHelper = DatabaseHelper();
  List<PersonilInspeksi> _personilInspeksi = [];
  late SharedPreferences preferences;
  var connectivityResult;
  String status = '';
  String? name = '';
  String textButton = '';
  Map<String, dynamic>? _suratTugas;
  bool _isgenerate = false;
  bool _isDone = false;
  
  @override
  void initState() {
    super.initState();
    _loadpersonilInspeksi();
    _loadSuratTugas();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        preferences = prefs;
      });
    });


    Future.delayed(Duration.zero, () async {
      await _loadpersonilInspeksi();
      await _loadSuratTugas();
      connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        setState(() {
          status = 'Offline';
        });
        const snackBar = SnackBar(
          content: Text('Tidak ada koneksi internet'),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        // ignore: unused_local_variable
      } else {
        setState(() {
          status = 'Online';
        });
      }
    });
  }

  Future<SuratTugas?> _loadSuratTugas() async {
    final database = DatabaseHelper();
    final suratTugas = await database.getSuratTugasById(widget.id!);
    final nameuser = await preferences.getString('name');
    setState(() {
      _suratTugas = suratTugas?.toMap();  
      name = nameuser!;
    });

    print(_suratTugas);

    return null;
  }

  Future<void> _loadpersonilInspeksi() async {
    final database = DatabaseHelper();
    final personilInspeksiList = await database.getAllPersonilInspeksiByStId(widget.id!);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _personilInspeksi = personilInspeksiList;
      if (_suratTugas!['status'] == 0) {
        if (_personilInspeksi.first.nama_personil == prefs.getString('name')) {
          if(status == 'Online'){
            _isgenerate = true;
            _isDone = false;
            textButton = 'Generate Pertanyaan';
          } else {
            _isgenerate = false;
            _isDone = false;
          }
        } else {
          _isgenerate = false;
          _isDone = false;
        }
      } else if (_suratTugas!['status'] == 1) {
        _isgenerate = true;
        textButton = 'Lanjutkan Inspeksi';
      } else if (_suratTugas!['status'] == 2) {
        _personilInspeksi.forEach((element) {
          if (element.nama_personil == prefs.getString('name') && element.status == 2) {
            _isDone = true;
            _isgenerate = false;
            textButton = 'Lihat Hasil Inspeksi';
          } else if (element.nama_personil == prefs.getString('name') && element.status == 0) {
            _isDone = false;
            _isgenerate = true;
            textButton = 'Lanjutkan Inspeksi';
          }
        });
      } else if (_suratTugas!['status'] == 3) {
        _personilInspeksi.forEach((element) {
          if (element.nama_personil == prefs.getString('name') && element.status == 2) {
            _isDone = true;
            _isgenerate = false;
            textButton = 'Lihat Hasil Inspeksi';
          } else if (element.nama_personil == prefs.getString('name') && element.status == 0) {
            _isDone = false;
            _isgenerate = true;
            textButton = 'Lanjutkan Inspeksi';
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengawasan Rutin'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/BG.png"),
            fit: BoxFit.cover,
          ),
        ),
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(12),
        child: Container(
          child: Column(
            children: <Widget>[
              ExpansionTile(
                backgroundColor: Colors.white,
                collapsedBackgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                title: Row(
                  children: const [
                    Icon(Icons.library_books),
                    SizedBox(width: 10),
                    Text('Detail Surat Tugas'),
                  ],
                ),
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 0),
                    width: MediaQuery.of(context).size.width,
                    child: Text('${_suratTugas?['no_surat']}'),
                  ),
                  // add more widgets as needed
                ],
              ),
              const SizedBox(height: 15),
              ExpansionTile(
                backgroundColor: Colors.white,
                collapsedBackgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                title: Row(
                  children: const [
                    Icon(Icons.apartment_rounded),
                    SizedBox(width: 10),
                    Text('Detail Perusahaan'),
                  ],
                ),
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 0),
                    width: MediaQuery.of(context).size.width,
                    child: Text('${_suratTugas?['nama_perusahaan']}'),
                  ),
                  // add more widgets as needed
                ],
              ),
              const SizedBox(height: 15),
              ExpansionTile(
                backgroundColor: Colors.white,
                collapsedBackgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                title: Row(
                  children: const [
                    Icon(Icons.supervisor_account),
                    SizedBox(width: 10),
                    Text('Detail Personil Inspeksi'),
                  ],
                ),
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 0),
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _personilInspeksi.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                            title: Text(_personilInspeksi[index].nama_personil.toString()),
                        );
                      },
                    ),
                  ),
                  // add more widgets as needed
                ],
              ),
              const SizedBox(height: 50),
              _isgenerate ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  
                  if (_suratTugas?['status'] == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => KategoriInspeksiPage(surat_tugas_id: _suratTugas?['id_surat_tugas'],),
                      ),
                    );
                  } else {
                    if (_isDone) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReviewInspeksiPage(surat_tugas_id: _suratTugas?['id_surat_tugas'],),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PertanyaanInspeksiPage(surat_tugas_id: _suratTugas?['id_surat_tugas'],),
                        ),
                      );
                    }
                  }
                },
                child: Text(
                  _isDone ? 'Lihat Hasil Inspeksi' : textButton,
                  style: const TextStyle(fontSize: 16),
                ),
              ) : Container(
                child: const Text(''),
              ),

              _isDone ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewInspeksiPage(surat_tugas_id: _suratTugas?['id_surat_tugas'],),
                    ),
                  );
                },
                child: const Text(
                  'Lihat Hasil Inspeksi',
                  style: TextStyle(fontSize: 16),
                ),
              ) : Container(
                child: const Text(''),
              ),
            ],
          ),
        )
      ),
    );
  }
}
