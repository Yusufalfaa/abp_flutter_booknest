import 'package:flutter/material.dart';
import '../main.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

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
      endDrawer: buildDrawer(context, '/faq'), // Sesuaikan route agar ter-highlight di Drawer
      body: const Center(child: Text("This is FAQ Page")),

      // Floating Action Button tetap ada untuk konsistensi
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          if (ModalRoute.of(context)?.settings.name != '/faq') {
            Navigator.pushNamed(context, '/faq');
          }
        },
        child: const Text('?', style: TextStyle(fontSize: 24, color: Colors.white)),
      ),
    );
  }
}
