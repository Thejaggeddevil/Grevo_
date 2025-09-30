import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/energy_data_provider.dart';
import '../models/energy_data.dart';

class CombinedAnalyticsChart extends StatelessWidget {
  const CombinedAnalyticsChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EnergyDataProvider>(
      builder: (context, dataProvider, child) {
        final data = dataProvider.historicalData;
        if (data.isEmpty) {
          return _buildNoData(context);
        }

        return Card(
          child: Container(
            height: 320,
            padding: const EdgeInsets.all(16),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
                titlesData: _buildTitles(context, data),
                borderData: FlBorderData(show: true),
                minX: 0,
                maxX: (data.length - 1).toDouble(),
                minY: 0,
                // Max across solar, wind and load
                maxY: _getMaxY(data),
                lineBarsData: [
                  // Solar - yellow
                  LineChartBarData(
                    spots: _spots(data, (e) => e.solar.generation),
                    isCurved: true,
                    color: Colors.amber,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                  // Wind - light blue
                  LineChartBarData(
                    spots: _spots(data, (e) => e.wind.generation),
                    isCurved: true,
                    color: Colors.lightBlueAccent,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                  // Load - purple
                  LineChartBarData(
                    spots: _spots(data, (e) => e.load.total),
                    isCurved: true,
                    color: Colors.purple,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<FlSpot> _spots(List<EnergyData> data, double Function(EnergyData) pick) {
    return data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), pick(e.value))).toList();
  }

  double _getMaxY(List<EnergyData> data) {
    double maxY = 0;
    for (final e in data) {
      maxY = [maxY, e.solar.generation, e.wind.generation, e.load.total].reduce((a, b) => a > b ? a : b);
    }
    return maxY * 1.1; // padding
  }

  FlTitlesData _buildTitles(BuildContext context, List<EnergyData> data) {
    final theme = Theme.of(context);
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 44,
          getTitlesWidget: (value, meta) => Text(
            value.toInt().toString(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitlesWidget: (value, meta) {
            final idx = value.toInt();
            if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
            final t = data[idx].timestamp;
            final label = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
            return Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            );
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  Widget _buildNoData(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Container(
        height: 320,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text(
              'No data for the last 24 hours',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}