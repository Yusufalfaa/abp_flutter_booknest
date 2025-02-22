import 'package:flutter/material.dart';
import '../main.dart';

class ForumPage extends StatelessWidget {
  const ForumPage({super.key});

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
      endDrawer: buildDrawer(context, '/forum'),
      body: const Center(child: Text("This is Forum Page")),

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
