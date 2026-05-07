import 'dart:convert';
import 'package:connector/models/trip_dto.dart';
import 'package:connector/models/vehicle_dto.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8080";

  // ✅ Login — phone only
  static Future<Map<String, dynamic>> login(String phoneNumber) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/users/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"number": phoneNumber}),
    );
    print("LOGIN STATUS: ${response.statusCode}");
    print("LOGIN BODY: ${response.body}");
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Login failed");
    }
  }

  // Vehicles by phone
  static Future<List<VehicleDto>> getVehiclesByPhone(String phone) async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/vehicle/phone/$phone"),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((j) => VehicleDto.fromJson(j)).toList();
    }
    return [];
  }

  // Owner trips
  static Future<List<TripDto>> getOwnerTrips(String phone) async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/trip/owner/$phone"),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((j) => TripDto.fromJson(j)).toList();
    }
    return [];
  }

  static Future<List<TripDto>> getActiveTrips() async {
    final response = await http.get(Uri.parse("$baseUrl/api/trip/active"));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((j) => TripDto.fromJson(j)).toList();
    } else {
      throw Exception("Failed to load trips");
    }
  }

  // ✅ Profile update — name, age, city, role save பண்ண
  static Future<void> updateProfile({
    required String phone,
    required String name,
    required int age,
    required String city,
    required String role,
  }) async {
    final response = await http.put(
      Uri.parse("$baseUrl/api/users/profile"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "number": phone,
        "name": name,
        "age": age,
        "city": city,
        "role": role,
      }),
    );
    print("PROFILE STATUS: ${response.statusCode}");
    if (response.statusCode != 200) {
      throw Exception("Profile update failed");
    }
  }
}
