import 'package:flutter/material.dart';
import '../../app_colors.dart';

import '../../services/team_service.dart';
import '../../services/leave_service.dart';

class AdminDashboard extends StatefulWidget {
  final Map<String, dynamic> user;
  const AdminDashboard({super.key, required this.user});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Map<String, dynamic> _stats = {'total': 0, 'staff': 0, 'admin': 0};
  List<dynamic> _pendingLeaves = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    final stats = await TeamService.getStats();
    final leaves = await LeaveService.getPendingLeaves();
    if (mounted) {
      setState(() {
        _stats = stats;
        _pendingLeaves = leaves;
        _isLoading = false;
      });
    }
  }

  void _updateLeave(int id, String status) async {
    final res = await LeaveService.updateStatus(id, status);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message']), backgroundColor: res['success'] ? AppColors.green : AppColors.red));
      _fetchData();
    }
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
                  const Text('Barza Holidays', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                  Text(
                    'Hello, ${widget.user['full_name']?.split(' ')[0] ?? 'Admin'}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                  ),
                ],
              ),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF28455E), Color(0xFF0F2233)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.notifications, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Donut Chart & Summary
          Row(
            children: [
              // Simple Donut Placeholder
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.green, width: 12),
                ),
                child: Center(
                  child: Text(
                    _isLoading ? '--' : '${_stats['total']}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    _DashboardMiniCard(icon: Icons.check_circle, label: 'Staff', value: '${_stats['staff']}', color: AppColors.green),
                    const SizedBox(height: 8),
                    _DashboardMiniCard(icon: Icons.admin_panel_settings, label: 'Admins', value: '${_stats['admin']}', color: AppColors.gold),
                    const SizedBox(height: 8),
                    _DashboardMiniCard(icon: Icons.people, label: 'Total', value: '${_stats['total']}', color: AppColors.ink2),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Grid
          Row(
            children: [
              Expanded(
                child: _AdminStatCard(
                  label: 'On field',
                  value: '5',
                  subValue: 'sales team out',
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: _AdminStatCard(
                  label: 'On leave',
                  value: '2',
                  subValue: 'approved',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Pending Approvals
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.screenCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Pending approvals', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.muted, letterSpacing: 1)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.goldSoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text('${_pendingLeaves.length} new', style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (_pendingLeaves.isEmpty)
                  const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No pending requests', style: TextStyle(color: AppColors.muted))))
                else
                  ..._pendingLeaves.map((l) => _ApprovalItem(
                        initials: l['full_name'][0],
                        name: '${l['full_name']} · ${l['leave_type']}',
                        details: '${l['start_date'].toString().split('T')[0]} · ${l['reason']}',
                        onApprove: () => _updateLeave(l['id'], 'approved'),
                        onReject: () => _updateLeave(l['id'], 'rejected'),
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardMiniCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DashboardMiniCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.screenCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subValue;

  const _AdminStatCard({required this.label, required this.value, required this.subValue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.screenCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.muted, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -1)),
          Text(subValue, style: const TextStyle(fontSize: 12.5, color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _ApprovalItem extends StatelessWidget {
  final String initials;
  final Color avatarColor;
  final String name;
  final String details;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ApprovalItem({
    required this.initials,
    this.avatarColor = AppColors.brand,
    required this.name,
    required this.details,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: avatarColor,
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(details, style: const TextStyle(color: AppColors.muted, fontSize: 12.5), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(onPressed: onReject, icon: const Icon(Icons.close, color: AppColors.red, size: 20)),
              IconButton(onPressed: onApprove, icon: const Icon(Icons.check, color: AppColors.green, size: 20)),
            ],
          ),
        ],
      ),
    );
  }
}
