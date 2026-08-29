import 'dart:convert';
import 'package:http/http.dart' as http;

class LeaveService {
  static const String baseUrl = 'http://localhost:5000/api/leave';

  static Future<List<dynamic>> getMyLeaves(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/my-leaves/$userId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> applyLeave(Map<String, dynamic> leaveData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/apply'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(leaveData),
      );
      final data = jsonDecode(response.body);
      return {'success': response.statusCode == 201, 'message': data['message']};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<List<dynamic>> getPendingLeaves() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/admin/pending'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> updateStatus(int leaveId, String status) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/update-status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'leave_id': leaveId, 'status': status}),
      );
      final data = jsonDecode(response.body);
      return {'success': response.statusCode == 200, 'message': data['message']};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
