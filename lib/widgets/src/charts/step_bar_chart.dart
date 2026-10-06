import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:colabhealth/core/core.dart';

class StepBarChart extends StatelessWidget {
  const StepBarChart({
    super.key,
    required this.values,
    required this.labels,
    this.height = 180,
  });

  final List<double> values;
  final List<String> labels;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    final maxVal = (values.isEmpty ? 1.0 : values.reduce((a, b) => a > b ? a : b));
    final safeMax = maxVal <= 0 ? 1.0 : maxVal;

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: safeMax * 1.2,
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => colors.primary,
              getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                rod.toY.round().toString(),
                AppTextStyles.semiBold12.copyWith(color: Colors.white),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (value, _) {
                  final i = value.toInt();
                  if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(labels[i],
                        style: AppTextStyles.regular10.copyWith(color: colors.textSecondary)),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (int i = 0; i < values.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: values[i],
                    width: 10,
                    borderRadius: BorderRadius.circular(6),
                    gradient: LinearGradient(
                      colors: [colors.primary.withValues(alpha: 0.6), colors.primary],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
