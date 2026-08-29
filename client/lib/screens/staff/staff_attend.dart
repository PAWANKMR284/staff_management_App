import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../app_colors.dart';
import '../../services/attendance_service.dart';

class StaffAttend extends StatefulWidget {
  final Map<String, dynamic> user;
  const StaffAttend({super.key, required this.user});

  @override
  State<StaffAttend> createState() => _StaffAttendState();
}

class _StaffAttendState extends State<StaffAttend> {
  bool _isLoading = false;
  Map<String, dynamic>? _todayStatus;
  Position? _currentPosition;
  String? _connectedWiFi;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    final status = await AttendanceService.getTodayStatus(widget.user['id']);
    final pos = await AttendanceService.getCurrentLocation();
    final wifi = await AttendanceService.getConnectedWiFi();
    if (mounted) {
      setState(() {
        _todayStatus = status;
        _currentPosition = pos;
        _connectedWiFi = wifi?.replaceAll('"', '');
      });
    }
  }

  void _handleCheckIn() async {
    final bool isOfficeWiFi = _connectedWiFi == AttendanceService.officeWiFiName;
    if (AttendanceService.officeWiFiName != null && !isOfficeWiFi) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Not on Office WiFi!'), backgroundColor: AppColors.red));
      return;
    }

    setState(() => _isLoading = true);
    final res = await AttendanceService.checkIn(widget.user['id'], _currentPosition?.latitude ?? 0, _currentPosition?.longitude ?? 0, 'office', wifi: _connectedWiFi);
    setState(() => _isLoading = false);

    if (res['success']) {
      _fetchData();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message']), backgroundColor: AppColors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message']), backgroundColor: AppColors.red));
    }
  }

  String _formatTime(dynamic dateTimeStr) {
    if (dateTimeStr == null) return '--:--';
    try {
      String str = dateTimeStr.toString();
      String timePart = str.contains('T') ? str.split('T')[1] : str.split(' ')[1];
      return timePart.substring(0, 5);
    } catch (e) { return '--:--'; }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasAnyAttendance = _todayStatus != null;
    final bool isAtOffice = hasAnyAttendance && _todayStatus!['type'] == 'office' && _todayStatus!['check_out'] == null;
    final bool isCheckedOut = hasAnyAttendance && _todayStatus!['check_out'] != null;
    final bool isOnField = hasAnyAttendance && _todayStatus!['type'] == 'field' && _todayStatus!['check_out'] == null;
    
    final bool isOfficeWiFi = _connectedWiFi == AttendanceService.officeWiFiName || AttendanceService.officeWiFiName == null;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Office Attendance', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                  Text(isAtOffice ? 'Status: Present' : 'Check in', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
              if (isAtOffice)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: AppColors.greenSoft, borderRadius: BorderRadius.circular(999)),
                  child: const Text('ON TIME', style: TextStyle(color: AppColors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (isOnField)
             _StatusNotice(icon: Icons.map, color: AppColors.gold, title: 'Field Mode Active', message: 'You are currently logged in via Field Mode.')
          else if (isCheckedOut)
             _StatusNotice(icon: Icons.task_alt, color: AppColors.green, title: 'Shift Completed', message: 'Your duty for today has ended.')
          else if (isAtOffice)
            _SuccessBox(time: _formatTime(_todayStatus!['check_in']))
          else ...[
            _WiFiCard(isOfficeWiFi: isOfficeWiFi),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: (!isOfficeWiFi || _isLoading) ? null : _handleCheckIn,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.brand, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Check-in (Office Mode)', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }
}

class _WiFiCard extends StatelessWidget {
  final bool isOfficeWiFi;
  const _WiFiCard({required this.isOfficeWiFi});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: isOfficeWiFi ? AppColors.greenSoft : AppColors.redSoft, borderRadius: BorderRadius.circular(16), border: Border.all(color: isOfficeWiFi ? AppColors.green : AppColors.red)),
      child: Row(children: [
        Icon(isOfficeWiFi ? Icons.wifi : Icons.wifi_off, color: isOfficeWiFi ? AppColors.green : AppColors.red),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(isOfficeWiFi ? 'Office WiFi Connected' : 'Not on Office WiFi', style: TextStyle(fontWeight: FontWeight.bold, color: isOfficeWiFi ? AppColors.green : AppColors.red)),
          const Text('Attendance only allowed on company WiFi', style: TextStyle(fontSize: 12)),
        ])),
      ]),
    );
  }
}

class _SuccessBox extends StatelessWidget {
  final String time;
  const _SuccessBox({required this.time});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: AppColors.brandSoft, borderRadius: BorderRadius.circular(18)),
      child: Column(children: [
        const Icon(Icons.check_circle, color: AppColors.brand, size: 60),
        const SizedBox(height: 16),
        const Text('Logged in Office Mode', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.brandD)),
        Text('Checked in at: $time', style: const TextStyle(color: AppColors.brandD)),
      ]),
    );
  }
}

class _StatusNotice extends StatelessWidget {
  final IconData icon; final Color color; final String title; final String message;
  const _StatusNotice({required this.icon, required this.color, required this.title, required this.message});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(18), border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Column(children: [
        Icon(icon, color: color, size: 40),
        const SizedBox(height: 12),
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(message, textAlign: TextAlign.center, style: TextStyle(color: color.withValues(alpha: 0.8))),
      ]),
    );
  }
}
