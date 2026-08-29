import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../app_colors.dart';
import '../../services/attendance_service.dart';

class StaffField extends StatefulWidget {
  final Map<String, dynamic> user;
  const StaffField({super.key, required this.user});

  @override
  State<StaffField> createState() => _StaffFieldState();
}

class _StaffFieldState extends State<StaffField> {
  bool _isLoading = false;
  Map<String, dynamic>? _todayStatus;
  Position? _currentPosition;
  String _gpsStatus = 'Fetching GPS...';
  XFile? _capturedImage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    final status = await AttendanceService.getTodayStatus(widget.user['id']);
    if (mounted) setState(() => _todayStatus = status);
    _fetchLocation();
  }

  void _fetchLocation() async {
    try {
      final pos = await AttendanceService.getCurrentLocation();
      if (mounted) {
        setState(() {
          _currentPosition = pos;
          _gpsStatus = pos != null ? 'GPS Locked' : 'GPS Failed';
        });
      }
    } catch (e) {
      if (mounted) setState(() => _gpsStatus = 'GPS Error: $e');
    }
  }

  Future<void> _takeSelfie() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );
    if (image != null) {
      setState(() => _capturedImage = image);
    }
  }

  void _handleFieldCheckIn() async {
    if (_capturedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please take a selfie first'), backgroundColor: AppColors.gold),
      );
      return;
    }

    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_gpsStatus), backgroundColor: AppColors.red),
      );
      _fetchLocation();
      return;
    }

    setState(() => _isLoading = true);
    final res = await AttendanceService.checkIn(
      widget.user['id'],
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      'field',
    );
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (res['success']) {
        _fetchData();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message']), backgroundColor: AppColors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message']), backgroundColor: AppColors.red));
      }
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
    final bool isCurrentlyOnField = hasAnyAttendance && _todayStatus!['type'] == 'field' && _todayStatus!['check_out'] == null;
    final bool isCheckedOut = hasAnyAttendance && _todayStatus!['check_out'] != null;
    final bool isAtOffice = hasAnyAttendance && _todayStatus!['type'] == 'office' && _todayStatus!['check_out'] == null;

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
                children: const [
                  Text('Field Duty', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                  Text('Mark Attendance', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AppColors.goldSoft, borderRadius: BorderRadius.circular(999)),
                child: const Text('FIELD MODE', style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          if (isAtOffice)
            _InfoBox(icon: Icons.business, color: AppColors.brand, title: 'At Office', message: 'You checked in via Office Mode today.')
          else if (isCheckedOut)
            _InfoBox(icon: Icons.task_alt, color: AppColors.green, title: 'Shift Ended', message: 'You have already checked out for today.')
          else if (isCurrentlyOnField)
            Container(
              width: double.infinity, padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(color: AppColors.goldSoft, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.gold.withValues(alpha: 0.3))),
              child: Column(children: [
                const Icon(Icons.map, color: AppColors.gold, size: 60),
                const SizedBox(height: 16),
                const Text('Logged in Field Mode', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
                Text('Started at: ${_formatTime(_todayStatus!['check_in'])}', style: const TextStyle(color: Color(0xFFB45309))),
              ]),
            )
          else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.chip, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: _currentPosition != null ? AppColors.green : AppColors.muted),
                  const SizedBox(width: 8),
                  Text(_gpsStatus, style: TextStyle(fontSize: 12, color: _currentPosition != null ? AppColors.green : AppColors.muted, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Selfie Viewfinder
            GestureDetector(
              onTap: _takeSelfie,
              child: Container(
                height: 200, width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black, 
                  borderRadius: BorderRadius.circular(18),
                  image: _capturedImage != null 
                    ? DecorationImage(
                        image: NetworkImage(_capturedImage!.path), // Works on web
                        fit: BoxFit.cover,
                      )
                    : null,
                ),
                child: _capturedImage == null 
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.camera_alt, color: Colors.white54, size: 50),
                        const SizedBox(height: 8),
                        const Text('Tap to take Selfie', style: TextStyle(color: Colors.white54)),
                      ],
                    )
                  : null,
              ),
            ),
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _handleFieldCheckIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold, foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isLoading 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                : const Text('Capture Selfie & Check-in', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon; final Color color; final String title; final String message;
  const _InfoBox({required this.icon, required this.color, required this.title, required this.message});
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
