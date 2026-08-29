import 'dart:convert';
import 'package:http/http.dart' as http;

class ReportService {
  static const String baseUrl = 'http://localhost:5000/api/reports';

  static Future<Map<String, dynamic>> getAttendanceTrends() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/attendance-trends'));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return {'trends': [], 'avgPresent': 0};
    } catch (e) { return {'trends': [], 'avgPresent': 0}; }
  }
}
