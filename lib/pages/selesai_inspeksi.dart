// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:http/http.dart' as http;

import 'home.dart';

class SelesaiInspeksiPage extends StatefulWidget {
  final int surat_tugas_id;

  const SelesaiInspeksiPage({Key? key, required this.surat_tugas_id}) : super(key: key);

  @override
  _SelesaiInspeksiPageState createState() => _SelesaiInspeksiPageState();

}

class _SelesaiInspeksiPageState extends State<SelesaiInspeksiPage> {

  final _borderWidth = 5.0;
  final GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey();
  late SharedPreferences preferences;
  bool _isLoading = false;
  String name = '';
  String email = '';
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        preferences = prefs;
      });
    });

    Future.delayed(Duration.zero, () async {
      controller.text = await preferences.getString('name')!;
    });
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      name = preferences.getString('name')!;
      email = preferences.getString('email')!;
    });
    int? userId = preferences.getInt('id');
    String? token = preferences.getString('token');
    Map<String, String> headers = {"Authorization": "Bearer $token"};
    final response = await http.post(
      Uri.parse('https://inspector-app.xyz/api/updateselesaipertanyaan'), headers: headers, body: {
        'id_surat_tugas': widget.surat_tugas_id.toString(),
        'id_user': userId.toString(),
      }
    );

    if (response.statusCode == 200) {
      setState(() {
        _isLoading = false;
      });

      showDialog(context: context, builder: (context) {
        return AlertDialog(
          title: const Text('Berhasil'),
          content: const Text('Inspeksi telah selesai'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(context, 
                
                MaterialPageRoute(builder: (context) => HomePage(email: email, name: name)),
                (route) => false);
              },
              child: const Text('OK'),
            ),
          ],
        );
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load data');
    }
  }

  Future<void> _saveSignature() async {
    if (_signaturePadKey.currentState != null) {
      setState(() {
        _isLoading = true;
      });

      int? userId = preferences.getInt('id');
      int? suratTugasId = widget.surat_tugas_id;
      String? token = preferences.getString('token');
      Map<String, String> headers = {"Authorization": "Bearer $token"};
      final data = await _signaturePadKey.currentState!.toImage(pixelRatio: 3.0);
      final bytes = await data.toByteData(format: ImageByteFormat.png);
      final encoded = bytes!.buffer.asUint8List();
      final directory = await getApplicationDocumentsDirectory();
      final image = File('${directory.path}/signature_$userId-$suratTugasId.png');
      await image.writeAsBytes(encoded);

      final response = await Dio().post(
        'https://inspector-app.xyz/api/store_signature',
        data: FormData.fromMap({
          'id_inspeksi': widget.surat_tugas_id.toString(),
          'id_user': userId.toString(),
          'file': await MultipartFile.fromFile(image.path, filename: 'signature_$userId-$suratTugasId.png'),
        }),
        options: Options(
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        
        setState(() {
          _isLoading = false;
        });
        
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Berhasil'),
              content: const Text('Berhasil mengupload tanda tangan, silahkan klik OK untuk menyelesaikan inspeksi'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();

                    _submit();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        
      } else {
        setState(() {
          _isLoading = false;
        });

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Gagal'),
              content: const Text('Gagal mengupload tanda tangan'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selesai Inspeksi'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/BG.png"),
            fit: BoxFit.cover,
          ),
        ),
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(20),
        child: Form(
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 20),
              
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.5 - 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SfSignaturePad(
                  key: _signaturePadKey,
                  minimumStrokeWidth: 3,
                  maximumStrokeWidth: 6,
                  strokeColor: Colors.blue,
                  backgroundColor: Colors.white,
                  
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                    onPressed: () {
                      _signaturePadKey.currentState!.clear();
                      setState(() {
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      fixedSize: Size(MediaQuery.of(context).size.width * 0.4, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    child: const Text('Hapus'),
                  ),              
              const SizedBox(height: 20),
              _isLoading ? const CircularProgressIndicator() : ElevatedButton(
                onPressed: () async {
                  _saveSignature();
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  fixedSize: Size(MediaQuery.of(context).size.width, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                child: const Text('Selesai Inspeksi'),
              ),
            ],
          ),
        )
      )
    );
  }
}