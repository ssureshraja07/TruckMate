import 'package:flutter/material.dart';
import 'package:connector/logins/login_page.dart';

void main() => runApp(const TruckMateApp());

class TruckMateApp extends StatelessWidget {
  const TruckMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TruckMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Roboto'),
      home: const LoginPage(),
    );
  }
}
