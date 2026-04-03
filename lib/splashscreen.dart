// ignore_for_file: use_build_context_synchronously

import 'package:agro_buzz/AdminMainScreen.dart';
import 'package:agro_buzz/CustomerMainScreen.dart';
import 'package:agro_buzz/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const String KEYLOGIN = 'login';

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 3), () {
      whereToGo();
    });
  }

  void whereToGo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? isLoggedIn = prefs.getBool(KEYLOGIN);
    final String? role = prefs.getString("role");

    if (isLoggedIn == true) {
      if (role == 'admin') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => AdminMainScreen()));
      } else if (role == 'customer') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => CustomerMainScreen()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => LoginScreen()));
      }
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FDF6),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.gif', width: 320, height: 320),
          ],
        ),
      ),
    );
  }
}
