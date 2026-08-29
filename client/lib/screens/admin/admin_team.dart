import 'package:flutter/material.dart';
import '../../app_colors.dart';

import '../../services/team_service.dart';
import '../signup_screen.dart';

class AdminTeam extends StatefulWidget {
  const AdminTeam({super.key});

  @override
  State<AdminTeam> createState() => _AdminTeamState();
}

class _AdminTeamState extends State<AdminTeam> {
  List<dynamic> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  void _fetchMembers() async {
    final members = await TeamService.getMembers();
    if (mounted) {
      setState(() {
        _members = members;
        _isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
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
                  Text('${_members.length} staff', style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                  Text(
                    'Team · live',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _fetchMembers,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.brandSoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text('Refresh', style: TextStyle(color: AppColors.brandD, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupScreen()),
                  ).then((_) => _fetchMembers());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brand,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('+ Add', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Map Placeholder
          Container(
            height: 130,
            decoration: BoxDecoration(
              color: AppColors.screenCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: Stack(
              children: [
                _MapPin(left: 0.32, top: 0.40, color: AppColors.brand),
                _MapPin(left: 0.66, top: 0.66, color: AppColors.gold),
                _MapPin(left: 0.78, top: 0.30, color: AppColors.gold),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Team List
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.screenCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.line),
            ),
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: _members.map((m) {
                    final role = m['role'] ?? 'staff';
                    return _TeamListItem(
                      initials: getInitials(m['full_name'] ?? 'U'),
                      name: m['full_name'] ?? 'Unknown',
                      subtitle: m['email'] ?? '',
                      status: role == 'admin' ? 'Admin' : 'Staff',
                      statusColor: role == 'admin' ? AppColors.gold : AppColors.brandD,
                      statusBg: role == 'admin' ? AppColors.goldSoft : AppColors.brandSoft,
                      avatarColor: role == 'admin' ? AppColors.gold : AppColors.brand,
                    );
                  }).toList(),
                ),
          ),
        ],
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final double left;
  final double top;
  final Color color;

  const _MapPin({required this.left, required this.top, required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: MediaQuery.of(context).size.width * left * 0.8, // Rough estimation
      top: 130 * top,
      child: Icon(Icons.location_on, color: color, size: 22),
    );
  }
}

class _TeamListItem extends StatelessWidget {
  final String initials;
  final String name;
  final String subtitle;
  final String status;
  final Color statusColor;
  final Color statusBg;
  final Color avatarColor;

  const _TeamListItem({
    required this.initials,
    required this.name,
    required this.subtitle,
    required this.status,
    required this.statusColor,
    required this.statusBg,
    this.avatarColor = AppColors.brand,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: avatarColor,
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
