import 'package:flutter/material.dart';
import '../../app_colors.dart';
import 'admin_dashboard.dart';
import 'admin_team.dart';
import 'admin_reports.dart';
import 'admin_payroll.dart';
import '../shared/profile_screen.dart';

class AdminMainScreen extends StatefulWidget {
  final VoidCallback onLogout;
  final Map<String, dynamic> user;
  const AdminMainScreen({super.key, required this.onLogout, required this.user});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      AdminDashboard(user: widget.user),
      const AdminTeam(),
      const AdminReports(),
      const AdminPayroll(),
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
              icon: Icons.dashboard,
              label: 'Overview',
              isSelected: _currentIndex == 0,
              onTap: () => setState(() => _currentIndex = 0),
            ),
            _TabItem(
              icon: Icons.people,
              label: 'Team',
              isSelected: _currentIndex == 1,
              onTap: () => setState(() => _currentIndex = 1),
            ),
            _TabItem(
              icon: Icons.bar_chart,
              label: 'Reports',
              isSelected: _currentIndex == 2,
              onTap: () => setState(() => _currentIndex = 2),
            ),
            _TabItem(
              icon: Icons.payments,
              label: 'Payroll',
              isSelected: _currentIndex == 3,
              onTap: () => setState(() => _currentIndex = 3),
            ),
            _TabItem(
              icon: Icons.person,
              label: 'Profile',
              isSelected: _currentIndex == 4,
              onTap: () => setState(() => _currentIndex = 4),
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
