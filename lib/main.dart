// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inspector/pages/login.dart';
import 'package:inspector/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {  
  runApp(const MyApp());
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inspector',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoggedIn = false;
  String _email = '';
  String _name = '';
  @override
  void initState() {
    super.initState();
    _checkLogin();
    _navigateToLogin();
  }

  void _checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('isLoggedIn') == true) {
      
      setState(() {
        _isLoggedIn = true;
        _email = prefs.getString('email')!;
        _name = prefs.getString('name')!;

      });

    } else {
      setState(() {
        _isLoggedIn = false;
      });
    }
  }

  void _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 5)); // Tunda selama 2 detik

    if (_isLoggedIn) {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(email: _email, name: _name)), // Navigasi ke halaman home
      );
    } else {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()), // Navigasi ke halaman login
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg-login.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: <Widget>[
            Center(
              child: Image.asset(
                "assets/images/img_splashscreen.png",
                width: 300,
                height: 300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
