// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inspector/db_helpers/database.dart';
import 'package:inspector/pages/kaidah_pertambangan.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inspector/pages/login.dart';

class HomePage extends StatefulWidget {
  
  final String email;
  final String name;
  
  const HomePage({super.key, required this.email, required this.name});
  
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late SharedPreferences preferences;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        preferences = prefs;
      });
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

  var _selectedTab = _SelectedTab.home;

  void _handleIndexChanged(int i) {
    setState(() {
      _selectedTab = _SelectedTab.values[i];
    });
    print(_selectedTab);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: SafeArea(
          child: _selectedTab == _SelectedTab.home
              ? Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/BG.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                height: MediaQuery.of(context).size.height,
                child: Column(
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
                      child: Stack(
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Container(
                                    padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 15),
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        TextButton(
                                          onPressed: () {},
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.white, fixedSize: const Size(200, 50),
                                          ),
                                          child: Row(
                                            children: <Widget>[
                                              const Icon(
                                                Icons.account_circle,
                                                color: Colors.white,
                                                size: 35,
                                              ),
                                              const SizedBox(width: 10),
                                              Flexible(
                                                child: RichText(
                                                  overflow: TextOverflow.ellipsis,
                                                  strutStyle: const StrutStyle(fontSize: 12.0),
                                                  text: TextSpan(
                                                      style: const TextStyle(color: Colors.white),
                                                      text: 'Halo, ${widget.name}'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                            icon: const Icon(
                                              Icons.logout_outlined,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                            onPressed: () async {
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text("Logout"),
                                                      content: const Text("Apakah anda yakin ingin logout?"),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          child: const Text("Tidak"),
                                                          onPressed: () {
                                                            Navigator.of(context).pop();
                                                          },
                                                        ),
                                                        TextButton(
                                                          onPressed: () async {
                                                            await preferences.remove('email');
                                                            await preferences.remove('name');
                                                            await preferences.remove('token');
                                                            await preferences.remove('id');
                                                            await preferences.remove('jenis_users_id');
                                                            preferences.setBool('isLoggedIn', false);
                                                            final DatabaseHelper db = DatabaseHelper();
                                                            await db.deleteAllUsers();
                                                            setState(() {
                                                            });
                                                            // ignore: use_build_context_synchronously
                                                            Navigator.pushAndRemoveUntil(context, 
                                                              MaterialPageRoute(builder: (context) => LoginPage()), 
                                                              (route) => false);
                                                          },
                                                          child: const Text("Ya"),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                            },
                                            
                                          ),
                                      ],
                                    ),
                                    
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.only(left: 18, bottom: 10, right: 15),
                                width: MediaQuery.of(context).size.width,
                                child: const Text(
                                "Kaidah Pertambangan \nYang Baik",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => KaidahPertambangan()),
                        );
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/images/KP.png"),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        margin: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
                        child: const Center(
                          child: Text(
                            '',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // aksi yang dijalankan ketika container ditekan
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/images/TKPP.png"),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        margin: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 20),
                        child: const Center(
                          child: Text(
                            '',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : _selectedTab == _SelectedTab.favorite
              ? Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/BG.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: Text("Notifikasi"),
                  ),
                )
              : _selectedTab == _SelectedTab.search
              ? Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/BG.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Center(
                    child: Text("Regulasi"),
                  ),
                )
              : Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/BG.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Center(
                    child: Text("Hubungi Kami"),
                  ),
                ),
        ),
        bottomNavigationBar: 
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/BG.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: DotNavigationBar(
            margin: EdgeInsets.only(left: 10, right: 10),
            currentIndex: _SelectedTab.values.indexOf(_selectedTab),
            dotIndicatorColor: Colors.blue,
            unselectedItemColor: Colors.grey[300],
            enablePaddingAnimation: false,
            onTap: _handleIndexChanged,
            items: [
              /// Home
              DotNavigationBarItem(
                icon: Icon(Icons.home),
                selectedColor: Colors.blue,
              ),

              /// Likes
              DotNavigationBarItem(
                icon: Icon(Icons.notifications),
                selectedColor: Colors.blue,
              ),

              /// Search
              DotNavigationBarItem(
                icon: Icon(Icons.menu_book),
                selectedColor: Colors.blue,
              ),

              /// Profile
              DotNavigationBarItem(
                icon: Icon(Icons.support_agent_outlined),
                selectedColor: Colors.blue,
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

enum _SelectedTab { home, favorite, search, person }


