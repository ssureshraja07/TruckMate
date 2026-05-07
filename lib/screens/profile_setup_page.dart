import 'package:connector/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'profile.dart';

class ProfileSetupPage extends StatefulWidget {
  final String phone;
  const ProfileSetupPage({super.key, required this.phone});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _cityController = TextEditingController();
  String _selectedRole = "OWNER";
  bool _isLoading = false;

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final age = _ageController.text.trim();
    final city = _cityController.text.trim();

    if (name.isEmpty || age.isEmpty || city.isEmpty) {
      _showSnack("Please fill all fields", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Spring Boot-க்கு profile update பண்ணு
      await ApiService.updateProfile(
        phone: widget.phone,
        name: name,
        age: int.parse(age),
        city: city,
        role: _selectedRole,
      );

      // SharedPreferences update
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', name);
      await prefs.setString('role', _selectedRole);
      await prefs.setString('city', city);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      _showSnack("Failed to save profile!", isError: true);
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
            // Header
            Container(
              width: double.infinity,
              color: const Color(0xFF1a1a2e),
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Setup your profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Tell us a bit about yourself",
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
                  // Name
                  _buildLabel("Full name"),
                  _buildInput(_nameController, ""),
                  const SizedBox(height: 16),

                  // Age
                  _buildLabel("Age"),
                  _buildInput(_ageController, "", type: TextInputType.number),
                  const SizedBox(height: 16),

                  // City
                  _buildLabel("City"),
                  _buildInput(_cityController, ""),
                  const SizedBox(height: 16),

                  // Role
                  _buildLabel("Your role"),
                  const SizedBox(height: 8),
                  Row(
                    children: ["OWNER", "DRIVER", "MECHANIC"].map((role) {
                      final isSelected = _selectedRole == role;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedRole = role),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF1a1a2e)
                                  : Colors.white,
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF1a1a2e)
                                    : const Color(0xFFE0E0E0),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                role[0] + role.substring(1).toLowerCase(),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 28),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
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
                              "Save & Continue →",
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Colors.black54,
      ),
    );
  }

  Widget _buildInput(
    TextEditingController controller,
    String hint, {
    TextInputType type = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        hintText: hint,
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
          borderSide: const BorderSide(color: Color(0xFF1a1a2e), width: 1.5),
        ),
      ),
    );
  }
}
