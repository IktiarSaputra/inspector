// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../db_helpers/database.dart';
import '../models/user.dart';
import '/pages/home.dart';
import 'dart:convert';
import '../api.dart';

class LoginPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isHidden = true;


  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void showAlertDialog(BuildContext context, String message) {

  // set up tombol OK
  Widget okButton = TextButton(
    child: const Text("OK"),
    onPressed: () {
      Navigator.of(context).pop(); // tutup dialog
    },
  );

  // membuat dialog
  AlertDialog alert = AlertDialog(
    title: const Text("Information"),
    content: Text(message),
    actions: [
      okButton,
    ],
  );

  // tampilkan dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final response = await http.post(
          Uri.parse(Api.Login),
          body: {
            'email': _emailController.text,
            'password': _passwordController.text,
          },
        );

        SharedPreferences prefs = await SharedPreferences.getInstance();

        final responseData = jsonDecode(response.body);

        setState(() {
          _isLoading = false;
        });
        
        if (response.statusCode == 200) {
          if(responseData['data']['jenis_users'] == 2){
            prefs.setInt('id', responseData['data']['id']);
            prefs.setString('token', responseData['meta']['token']);
            prefs.setString('email', responseData['data']['email']);
            prefs.setString('name', responseData['data']['name']);
            prefs.setInt('jenis_users_id', responseData['data']['jenis_users']);
            prefs.setBool('isLoggedIn', true);
            String? name = prefs.getString('name');
            String? email = prefs.getString('email')!;

            final User user = User(
              name: responseData['data']['name'],
              email: responseData['data']['email'],
            );

            final DatabaseHelper db = DatabaseHelper();
            await db.saveUser(user);

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (BuildContext context) => HomePage(name: name!, email: email),
              ),
              (route) => false,
            );
          } else {
            showAlertDialog(context, 'Anda tidak memiliki akses');
          }
          // Navigasi ke halaman selanjutnya setelah login berhasil
        } else if (response.statusCode == 400) {
          setState(() {
            _isLoading = false;
          });
          _scaffoldKey.currentState!.showSnackBar(
            const SnackBar(
              content: Text("Email atau password yang anda masukkan salah"),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          setState(() {
            _isLoading = false;
          });
          _scaffoldKey.currentState!.showSnackBar(
            const SnackBar(
              content: Text("Terjadi kesalahan, silahkan coba lagi"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _scaffoldKey.currentState!.showSnackBar(
          const SnackBar(
            content: Text("Terjadi kesalahan, silahkan coba lagi"),
            backgroundColor: Colors.red,
          ),
        );
      }


      
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
        body: Center(
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/bg-login.png"),
                fit: BoxFit.cover,
              ),
            ),
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(bottom: 20.0),
                    child: Center(
                      child: Image.asset(
                        "assets/images/text_logo.png",
                        width: 300,
                        height: 100,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(
                        color: Colors.white,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFF9F9F9)), // Merubah warna border saat normal
                        borderRadius: BorderRadius.circular(30),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFF9F9F9)), // Merubah warna border saat sedang aktif/focus
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email harus diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _isHidden,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(
                        color: Colors.white,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isHidden ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _isHidden = !_isHidden;
                          });
                        },
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFF9F9F9)), // Merubah warna border saat normal
                        borderRadius: BorderRadius.circular(30),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFF9F9F9)), // Merubah warna border saat sedang aktif/focus
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password harus diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF78272E), Color(0xFF984C59)],
                            stops: [0, 1],
                            tileMode: TileMode.clamp,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            Future.delayed(const Duration(milliseconds: 500), () {
                              _login();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ), backgroundColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                          ),
                          child: const Text("Login"),
                        ),
                      )

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
