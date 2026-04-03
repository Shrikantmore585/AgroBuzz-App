import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  final addressController = TextEditingController();

  String? selectedCategory;
  Position? _currentPosition;

  final List<String> categories = [
    'Vegetables',
    'Fruits',
    'Seeds',
    'Tools',
    'Fertilizer'
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
      });

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];

      String address = "${place.locality}, ${place.postalCode}";
      setState(() {
        addressController.text = address;
      });
    } catch (e) {
      print("Location error: $e");
    }
  }

  void _submitProduct() async {
    if (_formKey.currentState!.validate() &&
        selectedCategory != null &&
        _currentPosition != null) {
      await FirebaseFirestore.instance.collection('products').add({
        'name': nameController.text.trim(),
        'price': priceController.text.trim(),
        'description': descriptionController.text.trim(),
        'category': selectedCategory,
        'location': addressController.text.trim(),
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Product added successfully!")),
      );

      nameController.clear();
      priceController.clear();
      descriptionController.clear();
      addressController.clear();
      setState(() {
        selectedCategory = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("Please fill all fields and ensure location is fetched")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2FDF6),
      appBar: AppBar(
        title: Text("Add New Product"),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Enter Product Details",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800])),
              SizedBox(height: 20),
              TextFormField(
                controller: nameController,
                decoration: _inputDecoration("Product Name"),
                validator: (value) =>
                    value!.isEmpty ? "Enter product name" : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: priceController,
                decoration: _inputDecoration("Price (₹)"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Enter price" : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: _inputDecoration("Description"),
                maxLines: 4,
                validator: (value) =>
                    value!.isEmpty ? "Enter description" : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: _inputDecoration("Select Category"),
                value: selectedCategory,
                items: categories
                    .map((category) => DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
                validator: (value) =>
                    value == null ? "Please select a category" : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: addressController,
                decoration: _inputDecoration("Address"),
                validator: (value) => value!.isEmpty ? "Enter address" : null,
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Add Product",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.green[800]),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.green),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.green, width: 2),
      ),
    );
  }
}
