import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:booknest/pages/home_page.dart';
import 'package:booknest/pages/sign_up_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:booknest/services/auth.dart'; // Import AuthService

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
    print("Sign In button pressed"); // Debug print for button press
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      print("Email or Password is empty");
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
            _statusMessage = 'Login Berhasil!';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_statusMessage)),
          );
          print("User successfully logged in: ${user.email}"); // Debug print
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else {
          print("Login failed: User is null"); // Debug print
          setState(() {
            _isLoading = false;
          });
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
        });
        print("Login failed with error: ${e.message}"); // Debug print
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Gagal! Error: ${e.message}')),
        );
      }
    } else {
      print("Form is not valid or currentState is null"); // Debug print if form is not valid
    }
  }

  // Google Sign In Function
  Future<void> _signInWithGoogle() async {
    print("Sign In with Google button pressed"); // Debug print for button press
    setState(() {
      _isLoading = true;
    });

    try {
      // Create a GoogleSignIn instance
      GoogleSignIn googleSignIn = GoogleSignIn();

      // Attempt to sign in with Google
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // If the user canceled the sign-in process
        setState(() {
          _isLoading = false;
        });
        print("Google Sign-In canceled"); // Debug print
        return;
      }

      // Get the authentication details from the Google account
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential for Firebase authentication
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with the credential
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      User? user = userCredential.user;
      if (user != null) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Login Berhasil dengan Google!';
        });
        print("Google Sign-In successful: ${user.email}"); // Debug print
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_statusMessage)),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        print("Google Sign-In failed: User is null"); // Debug print
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Google Sign-In failed with error: $e"); // Debug print
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login dengan Google Gagal! Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightColor,
      body: SafeArea(
        child: SingleChildScrollView(
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
                      // Email TextField
                      Form(
                        key: _formKey,  // Use the form key here
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
                      _isLoading
                          ? const CircularProgressIndicator()
                          : SizedBox(
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
      ),
    );
  }
}
