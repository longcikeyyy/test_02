import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/sold_product_stat.dart';
import '../providers/report_provider.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportCubit, ReportState>(
      builder: (context, reportState) {
        return Scaffold(
          appBar: AppBar(
            title: Center(child: const Text('Báo cáo và thống kê')),
            actions: [
              IconButton(
                onPressed: () => context.read<ReportCubit>().loadStats(),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: reportState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : reportState.error != null
                  ? Center(child: Text(reportState.error!))
                  : _buildBody(context, reportState.stats),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, List<SoldProductStat> stats) {
    if (stats.isEmpty) {
      return const Center(child: Text('Chưa có dữ liệu thống kê.'));
    }

    final maxY = stats
      .map((item) => item.totalRevenue)
      .reduce((a, b) => a > b ? a : b)
      .clamp(1, double.infinity);
    final screenWidth = MediaQuery.of(context).size.width;
    final chartWidth = max(screenWidth - 24, stats.length * 90.0);
    final labelStep = stats.length > 8 ? (stats.length / 8).ceil() : 1;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: chartWidth,
            height: 320,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY * 1.2,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 56,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= stats.length) {
                          return const SizedBox.shrink();
                        }
                        if (index % labelStep != 0) {
                          return const SizedBox.shrink();
                        }
                        return SideTitleWidget(
                          meta: meta,
                          child: SizedBox(
                            width: 80,
                            child: Text(
                              stats[index].productName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  for (var i = 0; i < stats.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: stats[i].totalRevenue,
                          width: 24,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
        const Text(
          'Top sản phẩm đã bán',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ...stats.map(
          (item) => Card(
            child: ListTile(
              title: Text(item.productName),
              subtitle: Text('Số lượng bán: ${item.quantitySold}'),
              trailing: Text(formatCurrency(item.totalRevenue)),
            ),
          ),
        ),
      ],
    );
  }
}
