import 'package:flutter/material.dart';
import '../main.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
      ),

      body: const Center(child: Text("This is Sign in Page")),
    );
  }
}
