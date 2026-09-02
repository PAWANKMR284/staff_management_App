import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class LeaveService {
  static const String baseUrl = 'http://localhost:5000/api/leave';

  static Future<List<dynamic>> getMyLeaves(int userId) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(Uri.parse('$baseUrl/my-leaves/$userId'), headers: headers);
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) { return []; }
  }

  static Future<Map<String, dynamic>> applyLeave(Map<String, dynamic> leaveData) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.post(Uri.parse('$baseUrl/apply'), headers: headers, body: jsonEncode(leaveData));
      return {'success': response.statusCode == 201, 'message': jsonDecode(response.body)['message']};
    } catch (e) { return {'success': false, 'message': 'Error'}; }
  }

  static Future<List<dynamic>> getPendingLeaves() async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(Uri.parse('$baseUrl/admin/pending'), headers: headers);
      return (response.statusCode == 200) ? jsonDecode(response.body) : [];
    } catch (e) { return []; }
  }

  static Future<Map<String, dynamic>> updateStatus(int leaveId, String status) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/update-status'),
        headers: headers,
        body: jsonEncode({'leave_id': leaveId, 'status': status}),
      );
      return {'success': response.statusCode == 200, 'message': jsonDecode(response.body)['message']};
    } catch (e) { return {'success': false, 'message': 'Error'}; }
  }
}
