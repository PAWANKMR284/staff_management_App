import 'dart:convert';
import 'package:http/http.dart' as http;

class TeamService {
  static const String baseUrl = 'http://localhost:5000/api/auth';

  static Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/stats'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'total': 0, 'staff': 0, 'admin': 0};
    } catch (e) {
      return {'total': 0, 'staff': 0, 'admin': 0};
    }
  }

  static Future<List<dynamic>> getMembers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/members'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
