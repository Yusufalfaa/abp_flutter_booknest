import 'package:flutter/material.dart';
import 'pages/all_books_page.dart';
import 'pages/forum_page.dart';
import 'pages/mybooks_page.dart';

// Warna yang digunakan dalam aplikasi
const Color lightColor = Color(0xFFF1EFE3);
const Color backgroundColor = Color(0xFFF8F8F8);
const Color primaryColor = Color(0xFFC76E6F);
const Color blackColor = Color(0xFF272727);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "BookNest",
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColor,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/all-books':
            page = const AllBooksPage();
            break;
          case '/forum':
            page = const ForumPage();
            break;
          case '/my-books':
            page = const MyBooksPage();
            break;
          case '/':
          default:
            page = const MyHomePage();
        }
        return MaterialPageRoute(
          builder: (context) => page,
          settings: RouteSettings(name: settings.name),
        );
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

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
      endDrawer: buildDrawer(context, '/'),
      body: const Center(child: Text("Welcome to Home Page")),
    );
  }
}

// Widget Drawer untuk semua halaman
Widget buildDrawer(BuildContext context, String currentRoute) {
  return Drawer(
    backgroundColor: backgroundColor,
    child: ListView(
      children: [
        ListTile(
          title: Center(child: Image.asset("assets/BookNest.png", height: 30)),
        ),
        _buildDrawerItem(context, 'Home', '/', currentRoute),
        _buildDrawerItem(context, 'All Books', '/all-books', currentRoute),
        _buildDrawerItem(context, 'Forum', '/forum', currentRoute),
        _buildDrawerItem(context, 'MyBooks', '/my-books', currentRoute),
      ],
    ),
  );
}

// Fungsi untuk membuat ListTile dengan focus mode
Widget _buildDrawerItem(BuildContext context, String title, String route, String currentRoute) {
  bool isSelected = (route == currentRoute);

  return ListTile(
    title: Text(
      title,
      style: TextStyle(
        color: isSelected ? primaryColor : blackColor,
      ),
    ),
    selected: isSelected,
    selectedTileColor: backgroundColor.withOpacity(0.5),
    onTap: () {
      Navigator.pop(context);
      if (!isSelected) {
        Navigator.pushReplacementNamed(context, route);
      }
    },
  );
}
