// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, avoid_print, library_private_types_in_public_api, use_super_parameters

import 'package:agro_buzz/AdminMainScreen.dart';
import 'package:agro_buzz/CustomerMainScreen.dart';
import 'package:agro_buzz/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';

class MyRegister extends StatefulWidget {
  const MyRegister({Key? key}) : super(key: key);

  @override
  _MyRegisterState createState() => _MyRegisterState();
}

class _MyRegisterState extends State<MyRegister> {
  static const String KEYLOGIN = 'login';

  TextEditingController emailController = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController cpassword = TextEditingController();
  bool isPasswordVisible = false;
  bool isPasswordVisible1 = false;
  String selectedRole = 'customer';

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(e.message.toString());
      return null;
    }
  }

  void navigateBasedOnRole(String uid, String role) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(KEYLOGIN, true);

    if (role == 'admin') {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => AdminMainScreen()));
    } else {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => CustomerMainScreen()));
    }
  }

  void createAccount() async {
    String email = emailController.text.trim();
    String pass = password.text.trim();
    String cpass = cpassword.text.trim();
    if (email.isEmpty || pass.isEmpty || cpass.isEmpty) {
      _showErrorDialog("Please Enter Your Details");
    } else if (pass != cpass) {
      _showErrorDialog("Passwords Do Not Match");
    } else {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: pass);
        String uid = userCredential.user!.uid;
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'email': email,
          'role': selectedRole,
        });
        navigateBasedOnRole(uid, selectedRole);
      } on FirebaseAuthException catch (e) {
        _showErrorDialog(e.message.toString());
      } catch (e) {
        print(e.toString());
      }
    }
  }

  void loginWithGoogle() async {
    UserCredential? userCredential = await signInWithGoogle();
    if (userCredential != null) {
      final uid = userCredential.user!.uid;
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      // If user doesn't exist in Firestore, create a new user document with 'farmer' role
      if (!doc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'email': userCredential.user!.email,
          'role': 'customer', // Default role is farmer
        });
      }

      // After fetching or setting role, navigate based on the role
      String role = doc.exists
          ? doc['role']
          : 'customer'; // Ensure role exists before accessing it
      navigateBasedOnRole(uid, role);
    } else {
      _showErrorDialog("Google Login Failed");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0FAF1),
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Text("AgroBuzz Register"),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => LoginScreen()));
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 32),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return buildMobileLayout();
                } else {
                  return buildDesktopLayout();
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMobileLayout() {
    return Column(
      children: [
        buildIllustration(),
        buildHeaderText(),
        buildSubHeaderText(),
        buildForm(),
      ],
    );
  }

  Widget buildDesktopLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: 50),
        Expanded(
          child: Center(
            child: Column(
              children: [
                buildIllustration(),
                buildHeaderText(),
                buildSubHeaderText(),
                buildForm(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildIllustration() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.green.shade50,
      ),
      child: Center(
        child: Icon(
          Icons.eco,
          size: 60,
          color: Colors.green,
        ),
      ),
    );
  }

  Widget buildHeaderText() {
    return Text(
      'Welcome to AgroBuzz!',
      style: TextStyle(
          fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[800]),
    );
  }

  Widget buildSubHeaderText() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        "Create your account to explore smart farming solutions",
        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget buildForm() {
    return Container(
      width: 800,
      padding: EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          buildTextField(emailController, "Email", Icons.email, false),
          SizedBox(height: 12),
          buildTextField(
              password, "Password", Icons.lock, true, isPasswordVisible, () {
            setState(() => isPasswordVisible = !isPasswordVisible);
          }),
          SizedBox(height: 12),
          buildTextField(cpassword, "Confirm Password", Icons.lock, true,
              isPasswordVisible1, () {
            setState(() => isPasswordVisible1 = !isPasswordVisible1);
          }),
          SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: selectedRole,
            items: ['customer', 'admin'].map((role) {
              return DropdownMenuItem(
                  value: role, child: Text(role.toUpperCase()));
            }).toList(),
            onChanged: (value) => setState(() => selectedRole = value!),
            decoration: InputDecoration(
              labelText: 'Select Role',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          SizedBox(height: 22),
          buildAgriNestButton(
              "Register", createAccount, Colors.green[700]!, Colors.white),
          SizedBox(height: 16),
          buildAgriNestButton("Continue with Google", loginWithGoogle,
              Colors.white, Colors.black,
              icon: 'assets/images/google.png'),
        ],
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label,
      IconData icon, bool isPassword,
      [bool isVisible = false, VoidCallback? toggleVisibility]) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? !isVisible : false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: toggleVisibility,
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget buildAgriNestButton(
      String text, VoidCallback onPressed, Color bgColor, Color textColor,
      {String? icon}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          padding: EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Image.asset(icon, height: 24, width: 24),
              SizedBox(width: 12),
            ],
            Text(text,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
