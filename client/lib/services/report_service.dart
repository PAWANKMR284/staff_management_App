import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ReportService {
  static const String baseUrl = 'http://localhost:5000/api/reports';

  static Future<Map<String, dynamic>> getAttendanceTrends() async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(Uri.parse('$baseUrl/attendance-trends'), headers: headers);
      return (response.statusCode == 200) ? jsonDecode(response.body) : {'trends': [], 'avgPresent': 0};
    } catch (e) { return {'trends': [], 'avgPresent': 0}; }
  }
}
