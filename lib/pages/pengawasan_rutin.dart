import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inspector/models/personilinspeksi.dart';
import 'package:inspector/models/kategoriinspeksi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../db_helpers/database.dart';
import '../models/surattugas.dart';
import 'detail_pengawasan_rutin.dart';
import '../api.dart';

class PengawasanRutin extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _PengawasanRutinState createState() => _PengawasanRutinState();
}

class _PengawasanRutinState extends State<PengawasanRutin> {
  final dbHelper = DatabaseHelper();
  List<SuratTugas> _suratTugasList = [];
  TextEditingController _searchController = TextEditingController();
  List<SuratTugas> _searchResult  = [];
  // ignore: prefer_typing_uninitialized_variables
  var connectivityResult;
  String status = '';

  bool _isLoading = false;
  bool _isDone = false;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    Future.delayed(Duration.zero, () async {
      connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        setState(() {
          _isLoading = false;
          status = 'Offline';
        });
        _loadSuratTugas();
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
        fetchData();
      }
    });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> _loadSuratTugas() async {
    final database = DatabaseHelper();
    final suratTugasList = await database.getAllSuratTugas();
    setState(() {
      _suratTugasList = suratTugasList;
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Future<List<SuratTugas>> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('id');
    String? token = prefs.getString('token');
    String? name = prefs.getString('name');
    Map<String, String> headers = {"Authorization": "Bearer $token"};
    final response = await http.post(
        Uri.parse('${Api.GetSuratTugas}?id_user=$userId'),
        headers: headers);
    if (response.statusCode == 200) {
      //print(response.body);
      List<SuratTugas> suratTugasList = [];
      List<dynamic> data = json.decode(response.body)['data'];
      final DatabaseHelper db = DatabaseHelper();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      db.deleteAllSuratTugas();
      db.deleteAllKategoriInspeksi();
      db.deleteAllPersonilInspeksi();
      for (var element in data) {
        List<dynamic> datasub = element['surat_tugas'];
        for (var elementsub in datasub) {
          final responseKategoriInspeksi = await http.post(Uri.parse('https://inspector-app.xyz/api/kategori'),
              body: {
                'inspeksi_jenis': elementsub['inspeksi_jenis'].toString(),
                'kategori_jenis': elementsub['kategori_jenis'].toString(),
              }, headers: headers
          );
            
          var dataKategoriInspeksi = json.decode(responseKategoriInspeksi.body)['data'];
          for (var elementKategoriInspeksi in dataKategoriInspeksi) {
            KategoriInspeksi kategoriInspeksi = KategoriInspeksi(
              id_kategori: elementKategoriInspeksi['id'],
              inspeksi_jenis: elementKategoriInspeksi['inspeksi_jenis'],
              kategori_jenis: elementKategoriInspeksi['kategori_jenis'],
              nama_kategori: elementKategoriInspeksi['nama_kategori'],
            );

            db.getKategoriInspeksiById(elementKategoriInspeksi['id']).then((value) {
              if (value == null) {
                db.saveKategoriInspeksi(kategoriInspeksi);
              }
            });
          }
          final responsePersonil = await http.post(
              Uri.parse('${Api.DetailSuratTugas}?id_surat_tugas=${elementsub['id']}'),
              headers: headers);
          var dataPersonil = json.decode(responsePersonil.body)['data']['personil'];
          for (var elementPersonil in dataPersonil) {
            PersonilInspeksi personilInspeksi = PersonilInspeksi(
              id: elementPersonil['id'],
              st_inspeksi_id: elementPersonil['st_inspeksi_id'],
              nama_personil: elementPersonil['detail_user']['name'],
              status: elementPersonil['status'],
            );
            if (elementPersonil['detail_user']['name'] == name) {
              if (elementsub['status'] == 2) {
                _isDone = true;
              } else {
                _isDone = false;
              }
            } else {
              _isDone = false;
            }
            db.findPersonilInspeksiByStIdAndName(elementPersonil['st_inspeksi_id'], elementPersonil['detail_user']['name']).then((value) {
              if (value == null) {
                db.savePersonilInspeksi(personilInspeksi);
              }
            });
          }
          db.getAllSuratTugas();
          SuratTugas suratTugas = SuratTugas(
            id_surat_tugas: elementsub['id'],
            no_surat: elementsub['no_surat'],
            tgl_inspeksi: elementsub['tgl_inspeksi'],
            status: elementsub['status'],
            userId: element['id_user'],
            jenis_pengawasan_id: elementsub['jenis_pengawasan'],
            nama_perusahaan: elementsub['detail_perusahaan']['nama_perusahaan'],
            komoditas_perusahaan: elementsub['detail_perusahaan']['komoditas_perusahaan'],
          );
          db.getSuratTugasById(elementsub['id']).then((value) {
            if (value == null) {
              db.saveSuratTugas(suratTugas);
              setState(() {
                _suratTugasList.add(suratTugas);
              });
            }
          });
        }
      }
      setState(() {
        _isLoading = false;
      });
      return suratTugasList;
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception(response.body);
    }
  }

  void _searchItem(String value) {
    setState(() {
      _searchResult = _suratTugasList.where((item) => item.no_surat.toLowerCase().contains(value.toLowerCase())).toList();
    });
  }

  bool _isSearching() {
    return _searchResult.length != 0;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/BG.png"),
                fit: BoxFit.cover,
              ),
            ),
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: <Widget>[
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/banner1.png"),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  height: MediaQuery.of(context).size.height / 3 - 10,
                  child: Stack(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.only(left: 10, top: 10, right: 15),
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(64, 255, 255, 255),
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        padding: const EdgeInsets.only(left: 16, right: 10, top: 13, bottom: 13),
                                        child: const Icon(
                                          Icons.arrow_back_ios,
                                          color: Colors.white,  
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            "Pengawasan Rutin",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.circle,
                                color: status == 'Online' ? Colors.green : Colors.red,
                                size: 16,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                status,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: TextFormField(
                              controller: _searchController,
                              onChanged: (value) {
                                _searchItem(value);
                              },
                              decoration: InputDecoration(
                                hintText: 'Cari Surat Tugas',
                                hintStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                suffixIcon: const Icon(
                                  Icons.search,
                                  color: Colors.white,
                                ),
                                filled: true,
                                fillColor: const Color.fromARGB(64, 255, 255, 255),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                    color: Color.fromARGB(64, 255, 255, 255),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                    color: Color.fromARGB(64, 255, 255, 255),
                                  ),
                                ),
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // ignore: prefer_const_literals_to_create_immutables
                      children: <Widget>[
                        const CircularProgressIndicator(),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          'Tunggu Sebentar \n Sedang Memuat Data',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),

                      ],
                    ),                   
                  )
                :
                Container(
                    margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3 + 10, bottom: 10, left: 12, right: 12),

                    child: _isSearching() ? Builder(
                      builder: (BuildContext context) {
                        if (_searchResult.isEmpty) {
                          return const Center(
                            child: Text('Data tidak ditemukan'),
                          );
                        } else {
                          return ListView.builder(
                            itemCount: _searchResult.length,
                            itemBuilder: (context, index) {
                              return SuratTugasListItem(suratTugas: _searchResult[index], isDone: _isDone);
                            },
                          );
                        }
                      },
                    ) : Builder(
                      builder: (BuildContext context) {
                        if (_suratTugasList.isEmpty) {
                          return const Center(
                            child: Text('Data tidak ditemukan'),
                          );
                        } else {
                          return ListView.builder(
                            itemCount: _suratTugasList.length,
                            itemBuilder: (context, index) {
                              if(_suratTugasList.isEmpty) {
                                return const Center(
                                  child: Text('Tidak ada data'),
                                );
                              } else {
                                return SuratTugasListItem(suratTugas: _suratTugasList[index], isDone: _isDone);
                              }
                            },
                          );
                        }
                      },
                    ),
                )
              ]
            )
          ),
        ),
        floatingActionButton: status == 'Online' ? FloatingActionButton(
          onPressed: () {
            setState(() {
              _isLoading = true;
              _suratTugasList.clear();
            });
            fetchData();
          },
          child: const Icon(Icons.refresh),
          backgroundColor: Colors.blue,
        ) : null,
      ),
    );
  }
}

class SuratTugasListItem extends StatelessWidget {
  final SuratTugas suratTugas;
  final bool isDone;

  const SuratTugasListItem({Key? key, required this.suratTugas, required this.isDone})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      width: MediaQuery.of(context).size.width,
      child: Card(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailPengawasanRutin(id: suratTugas.id_surat_tugas),
              ),
            );
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(15),
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget> [
                if(suratTugas.status == 1)
                  // ignore: prefer_const_constructors
                  const Icon(
                        Icons.stacked_bar_chart,
                        color: Colors.blue,
                        size: 33,
                      )
                else if(suratTugas.status == 2)
                  isDone ? const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 33,
                      )
                  : const Icon(
                        Icons.stacked_bar_chart,
                        color: Colors.blue,
                        size: 33,
                      )
                else if(suratTugas.status == 3)
                  const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 33,
                      )
                else
                  const Icon(
                        Icons.apps,
                        color: Colors.grey,
                        size: 33,
                      ),
                const SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      suratTugas.no_surat.toString(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                  
                    Row(
                      children: <Widget>[
                        Text(
                          suratTugas.tgl_inspeksi.toString(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Icon(
                          Icons.circle,
                          color: Colors.grey,
                          size: 5,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        if(suratTugas.status == 1)
                          // ignore: prefer_const_constructors
                          Text(
                              'Siap Inspeksi',
                              // ignore: prefer_const_constructors
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                              ),
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,
                              
                            )
                        else if(suratTugas.status == 2)
                          isDone ? const Text(
                              'Menunggu Inspeksi Lain',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                            ) : const Text(
                              'Siap Inspeksi',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            )
                        else if(suratTugas.status == 3)
                          const Text(
                              'Selesai Inspeksi',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            )
                        else
                          const Text(
                              'Belum Generate Pertanyaan',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),

                        const SizedBox(
                          width: 5,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          )
        )
      )
    );
  }
}
