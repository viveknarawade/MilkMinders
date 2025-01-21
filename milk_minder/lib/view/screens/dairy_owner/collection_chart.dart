import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class CollectionTrendChart extends StatelessWidget {
  final List<MapEntry<String, double>> trendData;
  final String period;

  const CollectionTrendChart({
    Key? key,
    required this.trendData,
    required this.period,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (trendData.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < trendData.length) {
                  final date = DateTime.parse(trendData[value.toInt()].key);
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _formatDate(date, period),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
              interval: _getInterval(),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toStringAsFixed(1)}L',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        minX: 0,
        maxX: (trendData.length - 1).toDouble(),
        minY: _getMinY(),
        maxY: _getMaxY(),
        lineBarsData: [
          LineChartBarData(
            spots: _createSpots(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date, String period) {
    switch (period.toLowerCase()) {
      case 'week':
        return DateFormat('EEE').format(date); // Mon, Tue, etc.
      case 'month':
        return DateFormat('dd/MM').format(date); // 01/01
      case 'year':
        return DateFormat('MMM').format(date); // Jan, Feb, etc.
      default:
        return DateFormat('dd/MM').format(date);
    }
  }

  double _getInterval() {
    if (trendData.length <= 7) return 1;
    if (trendData.length <= 14) return 2;
    return (trendData.length / 7).ceil().toDouble();
  }

  List<FlSpot> _createSpots() {
    return List.generate(trendData.length, (index) {
      return FlSpot(index.toDouble(), trendData[index].value);
    });
  }

  double _getMinY() {
    if (trendData.isEmpty) return 0;
    double minValue = trendData.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    return (minValue * 0.9).floorToDouble();
  }

  double _getMaxY() {
    if (trendData.isEmpty) return 100;
    double maxValue = trendData.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    return (maxValue * 1.1).ceilToDouble();
  }
}