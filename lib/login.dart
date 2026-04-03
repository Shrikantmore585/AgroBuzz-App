// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, camel_
import 'package:agro_buzz/AdminMainScreen.dart';
import 'package:agro_buzz/CustomerMainScreen.dart';
import 'package:agro_buzz/forgot.dart';
import 'package:agro_buzz/register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const String KEYLOGIN = 'login';

  final TextEditingController mailController = TextEditingController();
  final TextEditingController passw = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    mailController.dispose();
    passw.dispose();
    super.dispose();
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
      showAlertDialog("Error", e.message ?? "An error occurred.");
      return null;
    }
  }

  void loginAccount() async {
    setState(() => _isLoading = true);

    String email = mailController.text.trim();
    String password = passw.text.trim();

    if (email == "" || password == "") {
      showAlertDialog("Error", "Please enter your details.");
      setState(() => _isLoading = false);
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        final uid = userCredential.user!.uid;
        final userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (userDoc.exists) {
          String role = userDoc.data()!['role'];

          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool(KEYLOGIN, true);
          prefs.setString("role", role);

          if (role == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => AdminMainScreen()),
            );
          } else if (role == 'customer') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => CustomerMainScreen()),
            );
          } else {
            showAlertDialog("Error", "Role not recognized.");
          }
        } else {
          showAlertDialog("Error", "User data not found.");
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showAlertDialog("Error", "User not found.");
      } else if (e.code == 'wrong-password') {
        showAlertDialog("Error", "Incorrect password.");
      } else {
        showAlertDialog("Error", e.message ?? "Login failed.");
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void loginWithGoogleButton() async {
    setState(() => _isLoading = true);
    UserCredential? userCredential = await signInWithGoogle();

    if (userCredential != null) {
      final uid = userCredential.user!.uid;
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        String role = userDoc.data()!['role'];

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool(KEYLOGIN, true);
        prefs.setString("role", role);

        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AdminMainScreen()),
          );
        } else if (role == 'customer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => CustomerMainScreen()),
          );
        } else {
          showAlertDialog("Error", "Role not recognized.");
        }
      } else {
        showAlertDialog("Error", "User data not found in Firestore.");
      }
    } else {
      showAlertDialog("Error", "Google login failed.");
    }

    setState(() => _isLoading = false);
  }

  void showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              child: Column(
                children: [
                  SizedBox(height: 30),
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.green.shade100,
                    child: Icon(Icons.eco, size: 50, color: Colors.green),
                  ),
                  SizedBox(height: 20),
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            'Welcome Back to AgroBuzz!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: mailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: passw,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(_isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _isLoading ? null : loginAccount,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              minimumSize: Size(double.infinity, 50),
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2)
                                : Text('Login',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white)),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed:
                                _isLoading ? null : loginWithGoogleButton,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(color: Colors.black12),
                              ),
                              minimumSize: Size(double.infinity, 50),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('assets/images/google.png',
                                    height: 24),
                                SizedBox(width: 10),
                                Text('Login with Google',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black)),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MyRegister()),
                                ),
                                child: Text("Sign Up",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ForgotPasswordPage()),
                                ),
                                child: Text("Forgot password",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
