import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// Warna yang digunakan dalam aplikasi
const Color lightColor = Color(0xFFF1EFE3);
const Color backgroundColor = Color(0xFFF8F8F8);
const Color primaryColor = Color(0xFFC76E6F);
const Color blackColor = Color(0xFF272727);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _selectedMenu = 'Home';

  void _updateSelectedMenu(String menu) {
    setState(() {
      _selectedMenu = menu;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: lightColor,
        title: IconButton(
          onPressed: () {},
          icon: Image.asset("assets/BookNest.png", height: 40),
        ),
      ),

      // NavBar

      endDrawer: Drawer(
        backgroundColor: backgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              title: Center(
                child: Image.asset("assets/BookNest.png", height: 30), // Ukuran lebih kecil
              ),
            ),
            _buildDrawerItem('Home'),
            _buildDrawerItem('All Books'),
            _buildDrawerItem('Forum'),
            _buildDrawerItem('MyBooks'),
          ],
        ),
      ),

      // Body

      body: Container(color: backgroundColor),
    );
  }

  // Widget untuk membuat ListTile dengan fokus mode
  Widget _buildDrawerItem(String title) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: _selectedMenu == title ? primaryColor : blackColor,
          fontWeight: _selectedMenu == title ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () => _updateSelectedMenu(title),
    );
  }
}
