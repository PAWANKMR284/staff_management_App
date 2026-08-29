import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../app_colors.dart';
import '../../services/report_service.dart';

class AdminReports extends StatefulWidget {
  const AdminReports({super.key});

  @override
  State<AdminReports> createState() => _AdminReportsState();
}

class _AdminReportsState extends State<AdminReports> {
  bool _isLoading = true;
  List<dynamic> _trends = [];
  int _avgPresent = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    final data = await ReportService.getAttendanceTrends();
    if (mounted) {
      setState(() {
        _trends = data['trends'];
        _avgPresent = data['avgPresent'];
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
                Text('Attendance report', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AppColors.brandSoft, borderRadius: BorderRadius.circular(999)),
                child: const Text('Export', style: TextStyle(color: AppColors.brandD, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Chart Section
          Container(
            padding: const EdgeInsets.all(20),
            height: 250,
            decoration: BoxDecoration(color: AppColors.screenCard, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.line)),
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Present rate · by week', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.muted, letterSpacing: 1)),
                    const SizedBox(height: 20),
                    Expanded(
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 100,
                          barTouchData: BarTouchData(enabled: true),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (val, meta) => Text(_trends[val.toInt()]['week'], style: const TextStyle(fontSize: 10, color: AppColors.muted)),
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: false),
                          barGroups: _trends.asMap().entries.map((e) => BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                toY: e.value['rate'].toDouble(),
                                gradient: const LinearGradient(colors: [AppColors.brand, AppColors.brandD], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                                width: 35,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                              )
                            ],
                          )).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
          ),
          const SizedBox(height: 14),

          // Stats
          Row(
            children: [
              Expanded(child: _StatBox(label: 'Avg present', value: '$_avgPresent%')),
              const SizedBox(width: 11),
              Expanded(child: _StatBox(label: 'Trend', value: '+4%', color: AppColors.green)),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(children: [
            Expanded(child: _ExportBtn(icon: Icons.bar_chart, label: 'Excel')),
            const SizedBox(width: 12),
            Expanded(child: _ExportBtn(icon: Icons.picture_as_pdf, label: 'PDF')),
          ]),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label, value; final Color? color;
  const _StatBox({required this.label, required this.value, this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.screenCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.muted)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color ?? AppColors.ink)),
      ]),
    );
  }
}

class _ExportBtn extends StatelessWidget {
  final IconData icon; final String label;
  const _ExportBtn({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.chip, foregroundColor: AppColors.ink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(label, style: const TextStyle(fontWeight: FontWeight.bold))]),
    );
  }
}
