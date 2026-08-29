import 'package:flutter/material.dart';
import '../../app_colors.dart';
import '../../services/payroll_service.dart';

class StaffPay extends StatefulWidget {
  final Map<String, dynamic> user;
  const StaffPay({super.key, required this.user});

  @override
  State<StaffPay> createState() => _StaffPayState();
}

class _StaffPayState extends State<StaffPay> {
  Map<String, dynamic>? _payslip;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPayslip();
  }

  void _loadPayslip() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    final now = DateTime.now();
    final data = await PayrollService.getMyPayslip(widget.user['id'], now.month, now.year);
    
    if (mounted) {
      setState(() {
        _payslip = data;
        _isLoading = false;
      });
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
                Text('August 2026', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                Text('Payslip', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ]),
              if (_payslip != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: AppColors.greenSoft, borderRadius: BorderRadius.circular(999)),
                  child: const Text('PAID', style: TextStyle(color: AppColors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_isLoading) 
            const Center(child: CircularProgressIndicator())
          else if (_payslip == null)
            const Center(child: Text('Payslip not generated yet by admin.', style: TextStyle(color: AppColors.muted)))
          else ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.brand, AppColors.brandD]), borderRadius: BorderRadius.circular(18)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Net salary', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('₹ ${_payslip!['net_salary']}', style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Calculated based on your attendance', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
              ]),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: AppColors.screenCard, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.line)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Breakup', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.muted)),
                const SizedBox(height: 4),
                _RowItem(label: 'Basic Salary', value: '₹ ${_payslip!['basic_salary']}'),
                _RowItem(label: 'Status', value: 'PAID', color: AppColors.green),
              ]),
            ),
          ],
        ],
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  final String label, value; final Color? color;
  const _RowItem({required this.label, required this.value, this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: AppColors.ink2)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color ?? AppColors.ink)),
      ]),
    );
  }
}
