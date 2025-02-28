import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:booknest/pages/home_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:booknest/services/auth.dart';
import 'package:booknest/models/user.dart' as model;

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final AuthService _authService = AuthService(); // Initialize AuthService
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordObscured = true;
  bool _isLoading = false;
  String _statusMessage = ''; // For displaying success/error messages

  // Sign In Function using email and password
  Future<void> _signIn() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      return;
    }

    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _statusMessage = ''; // Clear previous messages
      });

      try {
        // Sign in using email and password
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        User? user = userCredential.user;
        if (user != null) {
          setState(() {
            _isLoading = false;
            _statusMessage = 'Login Success!';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_statusMessage)),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Failed! Error: ${e.message}')),
        );
      }
    }
  }

  // Google Sign In
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Attempt to sign in with Google using AuthService
      final model.User? googleUser = await _authService.signInWithGoogle();
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        print('Google sign-in failed: User canceled');
        return;
      }

      setState(() {
        _isLoading = false;
        _statusMessage = 'Login Success!';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_statusMessage)),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Google Sign-In failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Failed! Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, left: 16.0),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pushNamed(context, '/home-page');
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Email Label
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              "Email",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Email TextField
                                TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    suffixIcon: Icon(Icons.email),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    fillColor: Color(0xFFE8E8E8),
                                    filled: true,
                                    hintText: 'Email',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                // Password Label
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      "Password",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                // Password TextField
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _isPasswordObscured,
                                  decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordObscured
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordObscured = !_isPasswordObscured;
                                        });
                                      },
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    fillColor: Color(0xFFE8E8E8),
                                    filled: true,
                                    hintText: 'Password',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Forget Password GestureDetector
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                print("Forgot Password clicked!");
                              },
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Colors.grey,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Sign In Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _signIn,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                backgroundColor: Color(0xFFC8C6BA),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                "Sign In",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Divider with "OR" text
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  thickness: 1,
                                  color: blackColor,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "OR",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: blackColor,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Divider(
                                  thickness: 1,
                                  color: blackColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Sign In with Google Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _signInWithGoogle,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                backgroundColor: Color(0xFFC8C6BA),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/google.png",
                                    height: 20,
                                    width: 20,
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    "Sign In With Google",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Don't have an account? Sign Up
                          Align(
                            alignment: Alignment.center,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, "/sign-up");
                              },
                              child: Text(
                                "Don't have an account? Sign Up",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Overlay for loading indicator
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.brown,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
