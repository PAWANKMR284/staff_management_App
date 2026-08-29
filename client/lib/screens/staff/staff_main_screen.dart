import 'package:flutter/material.dart';
import '../../app_colors.dart';
import 'staff_home.dart';
import 'staff_attend.dart';
import 'staff_field.dart';
import 'staff_leave.dart';
import 'staff_pay.dart';
import '../shared/profile_screen.dart';

class StaffMainScreen extends StatefulWidget {
  final VoidCallback onLogout;
  final Map<String, dynamic> user;
  const StaffMainScreen({super.key, required this.onLogout, required this.user});

  @override
  State<StaffMainScreen> createState() => _StaffMainScreenState();
}

class _StaffMainScreenState extends State<StaffMainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      StaffHome(user: widget.user),
      StaffAttend(user: widget.user),
      StaffField(user: widget.user),
      StaffLeave(user: widget.user),
      StaffPay(user: widget.user),
      ProfileScreen(user: widget.user, onLogout: widget.onLogout),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _screens[_currentIndex], // Changed from IndexedStack to direct access
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.nav,
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: Row(
          children: [
            _TabItem(
              icon: Icons.home,
              label: 'Home',
              isSelected: _currentIndex == 0,
              onTap: () => setState(() => _currentIndex = 0),
            ),
            _TabItem(
              icon: Icons.check_circle,
              label: 'Attend',
              isSelected: _currentIndex == 1,
              onTap: () => setState(() => _currentIndex = 1),
            ),
            _TabItem(
              icon: Icons.location_on,
              label: 'Field',
              isSelected: _currentIndex == 2,
              onTap: () => setState(() => _currentIndex = 2),
            ),
            _TabItem(
              icon: Icons.calendar_today,
              label: 'Leave',
              isSelected: _currentIndex == 3,
              onTap: () => setState(() => _currentIndex = 3),
            ),
            _TabItem(
              icon: Icons.payments,
              label: 'Payslip',
              isSelected: _currentIndex == 4,
              onTap: () => setState(() => _currentIndex = 4),
            ),
            _TabItem(
              icon: Icons.person,
              label: 'Profile',
              isSelected: _currentIndex == 5,
              onTap: () => setState(() => _currentIndex = 5),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.brand : AppColors.muted,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.brand : AppColors.muted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
