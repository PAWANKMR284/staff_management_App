import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:network_info_plus/network_info_plus.dart';

class AttendanceService {
  static const String baseUrl = 'http://localhost:5000/api/attendance';
  static const String? officeWiFiName = null; //'ShiftMark_Office'; // Example WiFi SSID


  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    return await Geolocator.getCurrentPosition();
  }

  static Future<String?> getConnectedWiFi() async {
    try {
      final info = NetworkInfo();
      return await info.getWifiName(); // Note: Requires location permission on Android
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> checkIn(int userId, double lat, double lon, String type, {String? wifi}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/check-in'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'latitude': lat,
          'longitude': lon,
          'type': type,
          'wifi_name': wifi,
        }),
      );
      final data = jsonDecode(response.body);
      return {'success': response.statusCode == 201, 'message': data['message'], 'data': data};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> checkOut(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/check-out'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );
      final data = jsonDecode(response.body);
      return {'success': response.statusCode == 200, 'message': data['message']};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>?> getTodayStatus(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/status/$userId'));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return null;
    } catch (e) { return null; }
  }
}
