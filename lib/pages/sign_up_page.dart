import 'package:flutter/material.dart';
import '../main.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
      ),

      body: const Center(child: Text("This is Sign Up Page")),
    );
  }
}
