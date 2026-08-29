import 'package:flutter/material.dart';
import '../../app_colors.dart';
import '../../services/payroll_service.dart';

class AdminPayroll extends StatefulWidget {
  const AdminPayroll({super.key});

  @override
  State<AdminPayroll> createState() => _AdminPayrollState();
}

class _AdminPayrollState extends State<AdminPayroll> {
  List<dynamic> _payrolls = [];
  bool _isLoading = true;
  int _totalPayout = 0;

  @override
  void initState() {
    super.initState();
    _loadPayroll();
  }

  void _loadPayroll() async {
    final now = DateTime.now();
    final data = await PayrollService.calculateAll(now.month, now.year);
    int total = 0;
    for (var p in data) { total += (p['net_salary'] as num).toInt(); }
    
    if (mounted) {
      setState(() {
        _payrolls = data;
        _totalPayout = total;
        _isLoading = false;
      });
    }
  }

  void _handleApprove() async {
    setState(() => _isLoading = true);
    final res = await PayrollService.approvePayroll(_payrolls);
    setState(() => _isLoading = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message']), backgroundColor: AppColors.green));
    }
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
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('Salary run', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                Text('Payroll · August', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AppColors.goldSoft, borderRadius: BorderRadius.circular(999)),
                child: const Text('DRAFT', style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.brand, AppColors.brandD]), borderRadius: BorderRadius.circular(18)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Total payout', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('₹ $_totalPayout', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('${_payrolls.length} staff · Auto-calculated', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: AppColors.screenCard, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.line)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Review', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.muted)),
              const SizedBox(height: 4),
              if (_isLoading) const Center(child: CircularProgressIndicator())
              else if (_payrolls.isEmpty) const Text('No staff found')
              else ..._payrolls.map((p) => _PayrollItem(name: p['full_name'], sub: '${p['present']} days present', val: '₹ ${p['net_salary']}')),
            ]),
          ),
          const SizedBox(height: 16),
          
          ElevatedButton(
            onPressed: _payrolls.isEmpty || _isLoading ? null : _handleApprove,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.brand, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: const Text('Approve & send payslips', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _PayrollItem extends StatelessWidget {
  final String name, sub, val;
  const _PayrollItem({required this.name, required this.sub, required this.val});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(children: [
        CircleAvatar(backgroundColor: AppColors.brandSoft, child: Text(name[0], style: const TextStyle(color: AppColors.brandD))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(sub, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        ])),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold)),
      ]),
    );
  }
}
