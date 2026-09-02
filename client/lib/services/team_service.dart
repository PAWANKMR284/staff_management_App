import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class TeamService {
  static const String baseUrl = 'http://localhost:5000/api/auth';

  static Future<Map<String, dynamic>> getStats() async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(Uri.parse('$baseUrl/stats'), headers: headers);
      return (response.statusCode == 200) ? jsonDecode(response.body) : {'total': 0, 'staff': 0, 'admin': 0};
    } catch (e) { return {'total': 0, 'staff': 0, 'admin': 0}; }
  }

  static Future<List<dynamic>> getMembers() async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(Uri.parse('$baseUrl/members'), headers: headers);
      return (response.statusCode == 200) ? jsonDecode(response.body) : [];
    } catch (e) { return []; }
  }
}
