import 'package:booknest/pages/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

import 'pages/home_page.dart';
import 'pages/all_books_page.dart';
import 'pages/forum_page.dart';
import 'pages/mybooks_page.dart';
import 'pages/faq_page.dart';
import 'pages/sign_in_page.dart';
import 'pages/book_detail_page.dart';

// Warna yang digunakan dalam aplikasi
const Color lightColor = Color(0xFFF1EFE3);
const Color backgroundColor = Color(0xFFF8F8F8);
const Color primaryColor = Color(0xFFC76E6F);
const Color blackColor = Color(0xFF272727);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "BookNest",
      debugShowCheckedModeBanner: false,
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
          case '/faq':
            page = const FaqPage();
            break;
          case '/sign-in':
            page = const SignInPage();
            break;
          case '/sign-up':
            page = const SignUpPage();
            break;
          case '/bookdetail':
            page = const BookDetailPage();
          case '/':
          default:
            page = const HomePage();
        }
        return MaterialPageRoute(
          builder: (context) => page,
          settings: RouteSettings(name: settings.name),
        );
      },
    );
  }
}
