import 'package:flutter/material.dart';
import 'login.dart'; // Import the Login widget

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Appssss',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Login(), // Set Login as the home screen
    );
  }
}
