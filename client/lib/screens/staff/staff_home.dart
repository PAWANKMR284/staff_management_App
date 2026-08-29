import 'package:flutter/material.dart';
import '../../app_colors.dart';
import '../../services/attendance_service.dart';

class StaffHome extends StatefulWidget {
  final Map<String, dynamic> user;
  const StaffHome({super.key, required this.user});

  @override
  State<StaffHome> createState() => _StaffHomeState();
}

class _StaffHomeState extends State<StaffHome> with RouteAware {
  Map<String, dynamic>? _todayStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTodayStatus();
  }

  // This will reload data whenever the user switches back to this tab
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchTodayStatus();
  }

  void _fetchTodayStatus() async {
    final status = await AttendanceService.getTodayStatus(widget.user['id']);
    if (mounted) {
      setState(() {
        _todayStatus = status;
        _isLoading = false;
      });
    }
  }

  void _handleCheckOut() async {
    setState(() => _isLoading = true);
    final res = await AttendanceService.checkOut(widget.user['id']);
    setState(() => _isLoading = false);

    if (res['success']) {
      _fetchTodayStatus();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message']), backgroundColor: AppColors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message']), backgroundColor: AppColors.red));
    }
  }

  String getInitials(String name) {
    List<String> names = name.split(" ");
    String initials = "";
    int numWords = names.length > 2 ? 2 : names.length;
    for (var i = 0; i < numWords; i++) {
      if (names[i].isNotEmpty) initials += names[i][0];
    }
    return initials.toUpperCase();
  }

  String _formatTime(dynamic dateTimeStr) {
    if (dateTimeStr == null) return '--:--';
    try {
      String str = dateTimeStr.toString();
      // Handle both '2026-08-28T20:34:16' and '2026-08-28 20:34:16'
      String timePart = str.contains('T') ? str.split('T')[1] : str.split(' ')[1];
      return timePart.substring(0, 5);
    } catch (e) {
      return '--:--';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String fullName = widget.user['full_name'] ?? 'User';
    final String initials = getInitials(fullName);
    final bool isCheckedIn = _todayStatus != null;
    final bool isCheckedOut = isCheckedIn && _todayStatus!['check_out'] != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Good morning', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                  Text(fullName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                ],
              ),
              Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [AppColors.brand, AppColors.brandD], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                child: Center(child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15))),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Main Shift Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.brand, AppColors.brandD], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(18)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Today · General shift', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    if (isCheckedIn)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(999)),
                        child: Text(_todayStatus!['status'].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Checked in', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
                        Text(_formatTime(isCheckedIn ? _todayStatus!['check_in'] : null), style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -1)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Checked out', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
                        Text(_formatTime(isCheckedOut ? _todayStatus!['check_out'] : null), style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -1)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (isCheckedIn && !isCheckedOut)
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleCheckOut,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.brandD, minimumSize: const Size(double.infinity, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.logout, size: 18), SizedBox(width: 8), Text('Check out', style: TextStyle(fontWeight: FontWeight.bold))]),
                  )
                else if (isCheckedOut)
                  const Text('Shift Completed', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                else
                  const Text('Not Checked In Yet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Rest of the UI...
          Row(
            children: [
              Expanded(child: _StatCard(label: 'Today Status', value: isCheckedIn ? 'Present' : 'Absent', subValue: isCheckedIn ? _todayStatus!['status'] : 'Not marked')),
              const SizedBox(width: 11),
              Expanded(child: _StatCard(label: 'Total Days', value: '21', subValue: 'this month')),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, subValue;
  const _StatCard({required this.label, required this.value, required this.subValue});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.screenCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.muted, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -1)),
        Text(subValue, style: const TextStyle(fontSize: 12.5, color: AppColors.muted)),
      ]),
    );
  }
}
