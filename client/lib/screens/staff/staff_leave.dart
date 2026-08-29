import 'package:flutter/material.dart';
import '../../app_colors.dart';
import '../../services/leave_service.dart';

class StaffLeave extends StatefulWidget {
  final Map<String, dynamic> user;
  const StaffLeave({super.key, required this.user});

  @override
  State<StaffLeave> createState() => _StaffLeaveState();
}

class _StaffLeaveState extends State<StaffLeave> {
  List<dynamic> _leaves = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyLeaves();
  }

  void _fetchMyLeaves() async {
    final leaves = await LeaveService.getMyLeaves(widget.user['id']);
    if (mounted) {
      setState(() {
        _leaves = leaves;
        _isLoading = false;
      });
    }
  }

  void _showApplyDialog() {
    String type = 'paid';
    DateTime start = DateTime.now();
    DateTime end = DateTime.now();
    final reasonController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Apply for Leave', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.ink)),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: type,
                items: ['paid', 'sick', 'casual'].map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase()))).toList(),
                onChanged: (v) => setDialogState(() => type = v!),
                decoration: const InputDecoration(labelText: 'Leave Type'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final d = await showDatePicker(context: context, initialDate: start, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                        if (d != null) setDialogState(() => start = d);
                      },
                      child: InputDecorator(decoration: const InputDecoration(labelText: 'Start Date'), child: Text('${start.year}-${start.month}-${start.day}')),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final d = await showDatePicker(context: context, initialDate: end, firstDate: start, lastDate: DateTime.now().add(const Duration(days: 365)));
                        if (d != null) setDialogState(() => end = d);
                      },
                      child: InputDecorator(decoration: const InputDecoration(labelText: 'End Date'), child: Text('${end.year}-${end.month}-${end.day}')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(labelText: 'Reason'),
                maxLines: 2,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final res = await LeaveService.applyLeave({
                      'user_id': widget.user['id'],
                      'leave_type': type,
                      'start_date': start.toIso8601String().split('T')[0],
                      'end_date': end.toIso8601String().split('T')[0],
                      'reason': reasonController.text,
                    });
                    if (mounted) {
                      Navigator.pop(context);
                      _fetchMyLeaves();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message']), backgroundColor: res['success'] ? AppColors.green : AppColors.red));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.brand, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: const Text('Submit Request', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  Text('Time off', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                  Text('Leave', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                ],
              ),
              ElevatedButton(
                onPressed: _showApplyDialog,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.brand, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('+ Apply', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stats Row
          Row(
            children: [
              Expanded(child: _LeaveStatCard(label: 'Paid', value: '${_leaves.where((l) => l['leave_type'] == 'paid' && l['status'] == 'approved').length}', subValue: 'approved')),
              const SizedBox(width: 11),
              Expanded(child: _LeaveStatCard(label: 'Sick', value: '${_leaves.where((l) => l['leave_type'] == 'sick' && l['status'] == 'approved').length}', subValue: 'approved')),
            ],
          ),
          const SizedBox(height: 14),
          // Requests List
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: AppColors.screenCard, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.line)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('My Requests', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.muted, letterSpacing: 1)),
                const SizedBox(height: 4),
                if (_isLoading)
                  const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                else if (_leaves.isEmpty)
                  const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No requests yet', style: TextStyle(color: AppColors.muted))))
                else
                  ..._leaves.map((l) => _LeaveItem(
                        type: l['leave_type'],
                        dates: '${l['start_date'].split('T')[0]} to ${l['end_date'].split('T')[0]}',
                        reason: l['reason'] ?? '',
                        status: l['status'],
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaveStatCard extends StatelessWidget {
  final String label, value, subValue;
  const _LeaveStatCard({required this.label, required this.value, required this.subValue});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.screenCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.muted, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -1)),
        Text(subValue, style: const TextStyle(fontSize: 12.5, color: AppColors.muted)),
      ]),
    );
  }
}

class _LeaveItem extends StatelessWidget {
  final String type, dates, reason, status;
  const _LeaveItem({required this.type, required this.dates, required this.reason, required this.status});

  @override
  Widget build(BuildContext context) {
    Color sColor = AppColors.gold;
    Color sBg = AppColors.goldSoft;
    if (status == 'approved') { sColor = AppColors.green; sBg = AppColors.greenSoft; }
    else if (status == 'rejected') { sColor = AppColors.red; sBg = AppColors.redSoft; }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(children: [
        Container(width: 38, height: 38, decoration: BoxDecoration(color: sBg, borderRadius: BorderRadius.circular(11)), child: const Center(child: Icon(Icons.calendar_today, color: Colors.black54, size: 20))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${type.toUpperCase()} · $dates', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(reason, style: const TextStyle(color: AppColors.muted, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: sBg, borderRadius: BorderRadius.circular(999)), child: Text(status.toUpperCase(), style: TextStyle(color: sColor, fontSize: 10, fontWeight: FontWeight.bold))),
      ]),
    );
  }
}
