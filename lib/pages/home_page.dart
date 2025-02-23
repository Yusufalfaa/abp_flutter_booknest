import 'package:flutter/material.dart';
import '../pages/all_books_page.dart';
import '../pages/forum_page.dart';
import '../pages/mybooks_page.dart';
import '../pages/faq_page.dart';
import 'package:http/http.dart';

const Color lightColor = Color(0xFFF1EFE3);
const Color backgroundColor = Color(0xFFF8F8F8);
const Color primaryColor = Color(0xFFC76E6F);
const Color blackColor = Color(0xFF272727);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isFaqPage = false;

  final List<Widget> _pages = [
    Center(child: Text("Welcome to Home Page")),
    const AllBooksPage(),
    const ForumPage(),
    const MyBooksPage(),
  ];

  void _openFaqPage() {
    setState(() {
      _isFaqPage = true;
    });
  }

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
      endDrawer: buildDrawer(context),
      body: _isFaqPage ? const FaqPage() : _pages[_selectedIndex],

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'All Books'),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Forum'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'MyBooks'),
        ],
        currentIndex: _isFaqPage ? _selectedIndex : _selectedIndex,
        backgroundColor: lightColor,
        selectedItemColor: _isFaqPage ? blackColor : primaryColor,
        unselectedItemColor: blackColor,
        selectedFontSize: 14,
        unselectedFontSize: 14,
        onTap: (index) {
          setState(() {
            _isFaqPage = false;
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
      ),


      // Floating Action Button untuk membuka FAQ
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: _openFaqPage,
        shape: const CircleBorder(),
        child: const Text('?', style: TextStyle(fontSize: 24, color: Colors.white)),
      ),
    );
  }
}

// Widget Drawer hanya untuk Sign In
Widget buildDrawer(BuildContext context) {
  return Drawer(
    backgroundColor: backgroundColor,
    child: Column(
      children: [
        ListTile(
          title: Center(child: Image.asset("assets/BookNest.png", height: 30)),
        ),
        const Divider(thickness: 1, color: Colors.grey),
        Expanded(
          child: ListView(
            children: [
              _buildDrawerItem(context, 'Sign In', '/sign-in'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Text('© 2025 BookNest',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        ),
      ],
    ),
  );
}

Widget _buildDrawerItem(BuildContext context, String title, String route) {
  return ListTile(
    title: Text(title, style: const TextStyle(color: blackColor)),
    onTap: () {
      Navigator.pop(context);
      Navigator.pushNamed(context, route);
    },
  );
}
