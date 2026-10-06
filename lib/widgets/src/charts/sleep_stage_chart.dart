import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:colabhealth/core/core.dart';

class SleepStageChart extends StatelessWidget {
  const SleepStageChart({super.key, required this.points, this.height = 160});

  final List<double> points;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.current;
    const stageLabels = ['Deep', 'Light', 'REM', 'Awake'];

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 3,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: colors.divider, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                interval: 1,
                getTitlesWidget: (value, _) {
                  final i = value.toInt();
                  if (i < 0 || i >= stageLabels.length) return const SizedBox.shrink();
                  return Text(stageLabels[i],
                      style: AppTextStyles.regular10.copyWith(color: colors.textSecondary));
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (int i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i]),
              ],
              isCurved: true,
              curveSmoothness: 0.35,
              barWidth: 2.5,
              color: colors.sleep,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [colors.sleep.withValues(alpha: 0.3), colors.sleep.withValues(alpha: 0.02)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
