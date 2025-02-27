import 'package:flutter/material.dart';
import 'package:booknest/services/auth.dart';
import 'package:booknest/pages/sign_in_page.dart';
import 'package:booknest/pages/home_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  String _statusMessage = ''; // For displaying success/error messages

  // Sign Up Function
  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _statusMessage = ''; // Clear previous messages
      });

      try {
        // Call AuthService to create a user
        var authService = AuthService();
        var user = await authService.signUp(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          passwordConfirmation: _confirmPasswordController.text,
        );

        if (user != null) {
          setState(() {
            _isLoading = false;
            _statusMessage = 'Registrasi Berhasil!'; // Success message
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_statusMessage)),
          );

          // Navigate to Home page after successful registration
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Error: $e'; // Display error message
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_statusMessage)),
        );
      }
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
                // Back Button
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, left: 16.0),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const HomePage()),
                      );
                    },
                  ),
                ),

                // Sign Up Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Username, Email, Password, and Password Confirmation fields
                      _buildTextField('Username', 'Username', _usernameController),
                      _buildTextField('Email', 'Email', _emailController),
                      _buildPasswordField('Password', 'Password', _passwordController),
                      _buildPasswordField('Password Confirmation', 'Confirm Password', _confirmPasswordController),

                      const SizedBox(height: 20),

                      // Status message (Success/Error)
                      if (_statusMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            _statusMessage,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _statusMessage.contains('Berhasil') ? Colors.green : Colors.red,
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Sign Up Button
                      _buildSignUpButton(),

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

                      // Sign Up with Google Button
                      SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: ElevatedButton(
                            onPressed: () {
                              print("Sign Up With Google clicked");
                            },
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
                                  "Sign Up With Google",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Already have an account? Sign In link
                      Align(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, "/sign-in");
                          },
                          child: Text(
                            "Already have an account? Sign In",
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

  // Helper function to build text fields
  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          decoration: InputDecoration(
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
            hintText: hint,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // Helper function to build password fields
  Widget _buildPasswordField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: Icon(Icons.visibility_off),
              onPressed: () {},
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
            hintText: hint,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // Helper function to build the Sign Up button
  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: ElevatedButton(
          onPressed: _signUp,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 15),
            backgroundColor: Color(0xFFC8C6BA),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            "Sign Up",
            style: TextStyle(
              fontSize: 15,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
