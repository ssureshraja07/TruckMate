// lib/pages/search_page.dart
import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Center(
        child: Text(
          "Search coming soon",
          style: TextStyle(color: Colors.black45),
        ),
      ),
    );
  }
}
