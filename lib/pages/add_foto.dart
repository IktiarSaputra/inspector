// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:coderjava_image_editor_pro/coderjava_image_editor_pro.dart';
import 'package:path_provider/path_provider.dart';

import '../db_helpers/database.dart';
import '../models/model_foto_inspeksi.dart';

class AddFotoPage extends StatefulWidget {
  final int id_inspeksi_pertanyaan;

  const AddFotoPage({Key? key, required this.id_inspeksi_pertanyaan})
      : super(key: key);
  @override
  _AddFotoPageState createState() => _AddFotoPageState();
}

class _AddFotoPageState extends State<AddFotoPage> {
  bool _isLoading = false;
  final dbHelper = DatabaseHelper();
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  String? _imageName;
  String lat = '';
  String long = '';

  @override
  void initState() {
    super.initState();
    __getCurrentLocation();
  }

  Future<void> getImageEditor() async {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return CoderJavaImageEditorPro(
            appBarColor: Colors.blue,
            bottomBarColor: Colors.blue,
            pathSave: null,
            defaultPathImage: _imageFile!.path,
            isShowingChooseImage: false,
            isShowingFlip: false,
            isShowingRotate: false,
            isShowingBlur: false,
            isShowingFilter: false,
            isShowingEmoji: false,
          );
        },
      ),
    ).then((value) {
      if (value != null) {
        setState(() {
          _imageFile = XFile(value.path);
        });
      }
    }).catchError((er) {
    });
  }

  void __getCurrentLocation() async {
    final LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied, take appropriate action
      // like showing a dialog or redirect to settings
      return;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device
    final Position position = await Geolocator.getCurrentPosition();
    setState(() {
      lat = position.latitude.toString();
      long = position.longitude.toString();
    });
  }

  void _getImage(ImageSource source) async {
    final XFile? selectedImage = await _picker.pickImage(source: source, imageQuality: 25);


    setState(() {
      _imageFile = selectedImage;
      _imageName = DateTime.now().millisecondsSinceEpoch.toString();
    });
  }

  Future<void> _updateFoto() async {
    setState(() {
      _isLoading = true;
    });

    final pertanyaanInspeksi = await dbHelper.getAlllFotoInspeksiByPertanyaanId(widget.id_inspeksi_pertanyaan);
      final directory = await getApplicationDocumentsDirectory();
      final filePath = directory.path;
      if (pertanyaanInspeksi.length > 0) {
      
        var id = pertanyaanInspeksi[0].id! + 1;
        FotoInspeksi fotoInspeksi = FotoInspeksi(
          id: pertanyaanInspeksi[0].id,
          id_foto_inspeksi: pertanyaanInspeksi[0].id_foto_inspeksi,
          id_inspeksi_pertanyaan: pertanyaanInspeksi[0].id_inspeksi_pertanyaan,
          nama_file: _imageName,
          longitude: long,
          latitude: lat,
        );

        await dbHelper.updateFotoInspeksi(fotoInspeksi);
        final file = File('$filePath/$_imageName');
        final bytes = await _imageFile?.readAsBytes();
        await file.writeAsBytes(bytes!);
      } else {

        var id = pertanyaanInspeksi.length + 1;
        FotoInspeksi fotoInspeksi = FotoInspeksi(
          id_foto_inspeksi: id,
          id_inspeksi_pertanyaan: widget.id_inspeksi_pertanyaan,
          nama_file: _imageName,
          longitude: long,
          latitude: lat,
        );

        dbHelper.getFotoInspeksiByPertanyaanIdAndNamaFile(widget.id_inspeksi_pertanyaan, _imageName!).then((value) {
          if (value == null) {
            dbHelper.saveFotoInspeksi(fotoInspeksi);
          } else {
            dbHelper.updateFotoInspeksi(fotoInspeksi);
          }
        });

        final file = File('$filePath/$_imageName');
        final bytes = await _imageFile?.readAsBytes();
        await file.writeAsBytes(bytes!);
      }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Foto'),
      ),
      body: Center(
        child: _imageFile == null
            ? const Text('Tidak ada foto yang di upload')
            : Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  Image.file(
                    File(_imageFile!.path),
                    width: MediaQuery.of(context).size.width,
                    height: 300,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text('Latitude: $lat'),
                  ),
                  SizedBox(height: 5),
                  Center(
                    child: Text('Longitude: $long'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF2ECC71),
                      onPrimary: Colors.white,
                      elevation: 0,
                      fixedSize: Size(MediaQuery.of(context).size.width - 20, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      side: const BorderSide(color: Color(0xFF2ECC71), width: 3),
                    ),
                    onPressed: () async {
                      _updateFoto().then((value) {
                        
                      }).whenComplete(() {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Success'),
                            content: const Text('Foto berhasil disimpan'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      });
                    },
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const <Widget>[
                              Icon(Icons.save),
                              SizedBox(width: 10),
                              Text('Simpan Foto'),
                            ],
                          ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFFF5B041),
                      onPrimary: Colors.white,
                      elevation: 0,
                      fixedSize: Size(MediaQuery.of(context).size.width - 20, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      side: const BorderSide(color: Color(0xFFF5B041), width: 3),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const <Widget>[
                        Icon(Icons.edit),
                        SizedBox(width: 10),
                        Text('Edit Foto'),
                      ],
                    ),
                    onPressed: () {
                      getImageEditor();
                    },
                  ),

              ]),
            ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () {
              _getImage(ImageSource.camera);
            },
            tooltip: 'Take a Photo',
            child: const Icon(Icons.add_a_photo),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              _getImage(ImageSource.gallery);
            },
            tooltip: 'Choose from Gallery',
            child: const Icon(Icons.photo_library),
          ),
        ],
      ),
    );
  }
  
}