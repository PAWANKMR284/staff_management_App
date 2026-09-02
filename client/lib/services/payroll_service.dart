import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class PayrollService {
  static const String baseUrl = 'http://localhost:5000/api/payroll';

  static Future<List<dynamic>> calculateAll(int month, int year) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(Uri.parse('$baseUrl/calculate/$month/$year'), headers: headers);
      return (response.statusCode == 200) ? jsonDecode(response.body) : [];
    } catch (e) { return []; }
  }

  static Future<Map<String, dynamic>> approvePayroll(List<dynamic> payrolls) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.post(Uri.parse('$baseUrl/approve'), headers: headers, body: jsonEncode({'payrolls': payrolls}));
      return {'success': response.statusCode == 200, 'message': jsonDecode(response.body)['message']};
    } catch (e) { return {'success': false, 'message': 'Error'}; }
  }

  static Future<Map<String, dynamic>?> getMyPayslip(int userId, int month, int year) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(Uri.parse('$baseUrl/my-payslip/$userId/$month/$year'), headers: headers);
      return (response.statusCode == 200) ? jsonDecode(response.body) : null;
    } catch (e) { return null; }
  }
}
