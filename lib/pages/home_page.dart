import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/all_books_page.dart';
import '../pages/forum_page.dart';
import '../pages/mybooks_page.dart';
import '../pages/faq_page.dart';
import 'package:booknest/services/auth.dart';

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
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

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

  // Logout Alert
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: lightColor,
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await AuthService().signOut();
                setState(() {
                  _currentUser = null; // Update state setelah logout
                });
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);

                // Show a SnackBar notification upon successful logout
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('You have successfully logged out!')),
                );
              },
              child: const Text("Log Out", style: TextStyle(color: primaryColor)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: lightColor,
        title: Image.asset("assets/BookNest.png", height: 40),
      ),
      endDrawer: buildDrawer(context, _openFaqPage, _showLogoutDialog, _currentUser),
      body: _isFaqPage ? const FaqPage() : _pages[_selectedIndex],

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

      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: _openFaqPage,
        shape: const CircleBorder(),
        child: const Text('?', style: TextStyle(fontSize: 24, color: Colors.white)),
      ),
    );
  }
}

// Widget Drawer yang menyesuaikan dengan status login pengguna
Widget buildDrawer(BuildContext context, Function openFaq, Function showLogoutDialog, User? currentUser) {
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
            children: currentUser == null
                ? [
              _buildDrawerItem(context, 'Sign In', '/sign-in', Icons.login),
              _buildDrawerItem(context, 'Settings', '/settings', Icons.settings),
            ]
                : [
              _buildDrawerItem(context, 'Profile', '/profile', Icons.person),
              ListTile(
                title: const Text('Log Out', style: TextStyle(color: blackColor)),
                leading: Icon(Icons.login, color: blackColor),
                onTap: () {
                  showLogoutDialog(context);
                },
              ),
              _buildDrawerItem(context, 'Settings', '/settings', Icons.settings),
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

Widget _buildDrawerItem(BuildContext context, String title, String route, IconData icon) {
  return ListTile(
    title: Text(title, style: const TextStyle(color: blackColor)),
    leading: Icon(icon, color: blackColor),
    onTap: () {
      Navigator.pop(context);
      Navigator.pushNamed(context, route);
    },
  );
}
