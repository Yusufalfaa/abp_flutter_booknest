import 'package:flutter/material.dart';
import '../main.dart';

class AllBooksPage extends StatelessWidget {
  const AllBooksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: lightColor,
        title: IconButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          icon: Image.asset("assets/BookNest.png", height: 40),
        ),
      ),
      endDrawer: buildDrawer(context, '/all-books'),
      body: const Center(child: Text("This is All Books Page")),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () => Navigator.pushNamed(context, '/faq'),
        shape: const CircleBorder(),
        child: const Text('?', style: TextStyle(fontSize: 24, color: Colors.white)),
      ),
    );
  }
}
