import 'package:connector/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'package:connector/screens/profile_setup_page.dart';
import 'package:connector/screens/profile.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    final phone = _phoneController.text.trim();

    if (phone.length != 10 || !RegExp(r'^\d{10}$').hasMatch(phone)) {
      _showSnack("Enter a valid 10-digit number", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.login(phone);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('phone', phone);
      await prefs.setString('name', response['name'] ?? '');
      await prefs.setString('role', response['role'] ?? '');
      await prefs.setString('city', response['city'] ?? '');

      if (!mounted) return;

      final name = response['name'];

      if (!mounted) return;

      if (name == null || name.toString().isEmpty) {
        // Profile not completed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ProfileSetupPage(phone: phone)),
        );
      } else {
        // Already completed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } catch (e) {
      print(e);
      _showSnack("Login failed. Check your number!", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero header
            Container(
              width: double.infinity,
              color: const Color(0xFF1a1a2e),
              padding: const EdgeInsets.fromLTRB(24, 80, 24, 40),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2d2d4e),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.local_shipping,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "TruckMate",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Enter your phone number to continue",
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Phone number",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: InputDecoration(
                      prefixText: "+91  ",
                      hintText: "9876543210",
                      counterText: "",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF1a1a2e),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1a1a2e),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Continue →",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
