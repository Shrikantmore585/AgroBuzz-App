// ignore_for_file: use_build_context_synchronously

import 'package:agro_buzz/CustomerOrdersPage.dart';
import 'package:agro_buzz/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerProfilePage extends StatefulWidget {
  const CustomerProfilePage({super.key});

  @override
  State<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  static const String KEYLOGIN = 'login';
  User? _user;
  Position? _currentPosition;
  String _currentAddress = "Fetching location...";

  @override
  void initState() {
    super.initState();
    _getUserData();
    _getCurrentLocation();
  }

  void _getUserData() {
    FirebaseAuth auth = FirebaseAuth.instance;
    setState(() {
      _user = auth.currentUser;
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
      _getAddressFromLatLon();
    } catch (e) {
      Fluttertoast.showToast(msg: "Location Error: $e");
    }
  }

  Future<void> _getAddressFromLatLon() async {
    try {
      if (_currentPosition != null) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
        Placemark place = placemarks[0];
        setState(() {
          _currentAddress = "${place.locality}, ${place.postalCode}";
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Address Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.lightGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundImage: _user?.photoURL != null
                          ? NetworkImage(_user!.photoURL!)
                          : const AssetImage('assets/profile.jpg')
                              as ImageProvider,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _user?.displayName ?? "Customer",
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _user?.email ?? "Not Available",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Personal Info",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              buildCard(
                  Icons.person, _user?.displayName ?? "Unknown", screenWidth),
              buildCard(
                  Icons.email, _user?.email ?? "Not available", screenWidth),
              buildCard(Icons.location_on, _currentAddress, screenWidth),
              const SizedBox(height: 25),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Utilities",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              buildCard(Icons.download, "My Orders", screenWidth, onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomerOrder(),
                    ));
              }),
              buildCard(Icons.bar_chart, "Purchase Analytics", screenWidth,
                  onTap: () {}),
              buildCard(Icons.support_agent, "Farmer Support", screenWidth,
                  onTap: () {}),
              buildCard(Icons.logout, "Log Out", screenWidth, onTap: _logout),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCard(IconData icon, String title, double width,
      {VoidCallback? onTap}) {
    return SizedBox(
      width: width,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          leading: Icon(icon, color: Colors.lightGreen),
          title: Text(title),
          trailing: onTap != null
              ? const Icon(Icons.arrow_forward_ios, size: 16)
              : null,
          onTap: onTap,
        ),
      ),
    );
  }

  void _logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await FirebaseAuth.instance.signOut();
      await prefs.setBool(KEYLOGIN, false);
      Fluttertoast.showToast(msg: "Logged out successfully");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Logout failed: $e");
    }
  }
}
