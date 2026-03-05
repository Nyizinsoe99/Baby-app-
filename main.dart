import 'package:flutter/material.dart';
import 'LoginPage.dart';
import 'AddNotePage.dart';
import 'NotePage.dart';
import 'SharePage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/note': (context) => NotePage(),
        '/share': (context) => SharePage(),
        '/addnote': (context) => AddNotePage(),
      },
    );
  }
}