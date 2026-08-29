import 'dart:convert';
import 'package:http/http.dart' as http;

class PayrollService {
  static const String baseUrl = 'http://localhost:5000/api/payroll';

  static Future<List<dynamic>> calculateAll(int month, int year) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/calculate/$month/$year'));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) { return []; }
  }

  static Future<Map<String, dynamic>> approvePayroll(List<dynamic> payrolls) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/approve'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'payrolls': payrolls}),
      );
      return {'success': response.statusCode == 200, 'message': jsonDecode(response.body)['message']};
    } catch (e) { return {'success': false, 'message': e.toString()}; }
  }

  static Future<Map<String, dynamic>?> getMyPayslip(int userId, int month, int year) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/my-payslip/$userId/$month/$year'));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return null;
    } catch (e) { return null; }
  }
}
