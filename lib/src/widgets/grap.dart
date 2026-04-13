import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/smart_home_models.dart';

class UsageLineChart extends StatelessWidget {
  const UsageLineChart({
    super.key,
    required this.points,
  });

  final List<UsagePoint> points;

  @override
  Widget build(BuildContext context) {
    final maxY = points
            .map((point) => point.value)
            .fold<double>(0, (max, value) => value > max ? value : max) +
        2;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (points.length - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withValues(alpha: 0.25),
              width: 2,
            ),
            left: const BorderSide(color: Colors.transparent),
            top: const BorderSide(color: Colors.transparent),
            right: const BorderSide(color: Colors.transparent),
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              interval: 5,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= points.length) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    points[index].label,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xCCFFFFFF),
            getTooltipItems: (spots) => spots
                .map(
                  (spot) => LineTooltipItem(
                    '${points[spot.x.toInt()].label}\n${spot.y.toStringAsFixed(1)} kWh',
                    const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: Colors.white,
            barWidth: 4,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.white.withValues(alpha: 0.15),
            ),
            spots: [
              for (var i = 0; i < points.length; i++)
                FlSpot(i.toDouble(), points[i].value),
            ],
          ),
        ],
      ),
      duration: const Duration(milliseconds: 250),
    );
  }
}
