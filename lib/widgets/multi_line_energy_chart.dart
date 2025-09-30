import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/energy_data_provider.dart';
import '../theme/app_theme.dart';

class MultiLineEnergyChart extends StatelessWidget {
  const MultiLineEnergyChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EnergyDataProvider>(
      builder: (context, dataProvider, child) {
        final historicalData = dataProvider.historicalData;

        if (historicalData.isEmpty) {
          return _buildLoadingChart();
        }

        return Container(
          height: 420,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.accentColor.withAlpha(77)),
          ),
          child: Column(
            children: [
              // Chart Legend
              _buildChartLegend(),
              const SizedBox(height: 16),
              // Chart with proper constraints
              SizedBox(
                height: 320,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12, top: 8),
                  child: LineChart(
                    _buildLineChartData(historicalData),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingChart() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentColor.withAlpha(77)),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading energy data...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem('Solar Generation', Colors.orange[400]!, Icons.wb_sunny),
        _buildLegendItem('Wind Generation', Colors.lightBlue[400]!, Icons.air),
        _buildLegendItem('Campus Load', Colors.purple[400]!, Icons.electric_bolt),
        _buildLegendItem('Battery Flow', Colors.green[400]!, Icons.battery_full),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  LineChartData _buildLineChartData(List<dynamic> historicalData) {
    // Process historical data into chart spots
    final solarSpots = <FlSpot>[];
    final windSpots = <FlSpot>[];
    final loadSpots = <FlSpot>[];
    final batterySpots = <FlSpot>[];

    // Generate 24 hours of realistic mock data points
    for (int i = 0; i < 24; i++) {
      final hour = i.toDouble();
      
      // Mock solar generation (realistic bell curve around noon)
      final solarBase = 35.0;
      final solarPeak = i >= 6 && i <= 18 
          ? solarBase * (1 + 0.7 * (1 - ((i - 12).abs() / 6).clamp(0, 1)))
          : 0.0;
      final solarNoise = (i % 3 - 1) * 2.0; // Reduced noise
      final solar = (solarPeak + solarNoise).clamp(0, double.infinity);
      
      // Mock wind generation (more consistent, slight evening peak)
      final windBase = 20.0;
      final windPeak = windBase * (1 + 0.4 * (1 - ((i - 18).abs() / 8).clamp(0, 1)));
      final windNoise = (i % 4 - 2) * 3.0; // Reduced noise
      final wind = (windPeak + windNoise).clamp(0, double.infinity);
      
      // Mock campus load (realistic daily pattern)
      final loadBase = 25.0;
      double loadMultiplier = 1.0;
      if (i >= 6 && i <= 22) {
        // Day time load pattern
        loadMultiplier = 1.2 + 0.5 * (1 - ((i - 14).abs() / 8).clamp(0, 1));
      } else {
        // Night time reduced load
        loadMultiplier = 0.6;
      }
      final loadNoise = (i % 2 - 1) * 1.5; // Reduced noise
      final load = (loadBase * loadMultiplier + loadNoise).clamp(5, double.infinity);
      
      // Mock battery flow (more realistic charging/discharging)
      final totalGeneration = solar + wind;
      final batteryFlow = (load - totalGeneration) * 0.8; // More balanced
      
      solarSpots.add(FlSpot(hour, solar.toDouble()));
      windSpots.add(FlSpot(hour, wind.toDouble()));
      loadSpots.add(FlSpot(hour, load.toDouble()));
      batterySpots.add(FlSpot(hour, batteryFlow.clamp(-35.0, 25.0)));
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 15,
        verticalInterval: 4,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.white.withAlpha(26),
            strokeWidth: 1,
            dashArray: [5, 5],
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.white.withAlpha(26),
            strokeWidth: 1,
            dashArray: [5, 5],
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 6,
            getTitlesWidget: (double value, TitleMeta meta) {
              const style = TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              );
              String text;
              if (value.toInt() == 0) text = '12 AM';
              else if (value.toInt() == 6) text = '6 AM';
              else if (value.toInt() == 12) text = '12 PM';
              else if (value.toInt() == 18) text = '6 PM';
              else return Container();
              
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(text, style: style),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 15,
            getTitlesWidget: (double value, TitleMeta meta) {
              const style = TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              );
              return Text('${value.toInt()} kW', style: style);
            },
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.white.withAlpha(77)),
      ),
      minX: 0,
      maxX: 23,
      minY: -40,
      maxY: 80,
      lineBarsData: [
        // Solar Generation Line (Yellow/Orange)
        LineChartBarData(
          spots: solarSpots,
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              Colors.orange[300]!,
              Colors.orange[500]!,
            ],
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.orange[400]!.withAlpha(77),
                Colors.orange[400]!.withAlpha(26),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        // Wind Generation Line (Light Blue)
        LineChartBarData(
          spots: windSpots,
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              Colors.lightBlue[300]!,
              Colors.lightBlue[500]!,
            ],
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.lightBlue[400]!.withAlpha(77),
                Colors.lightBlue[400]!.withAlpha(26),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        // Campus Load Line (Purple)
        LineChartBarData(
          spots: loadSpots,
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              Colors.purple[300]!,
              Colors.purple[500]!,
            ],
          ),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
        ),
        // Battery Flow Line (Green, dotted style)
        LineChartBarData(
          spots: batterySpots,
          isCurved: true,
          color: Colors.green[400],
          barWidth: 3,
          isStrokeCapRound: true,
          dashArray: [10, 5],
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 2,
                color: Colors.green[400]!,
                strokeWidth: 0,
              );
            },
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: AppTheme.cardColor,
          tooltipRoundedRadius: 8,
          tooltipPadding: const EdgeInsets.all(8),
          tooltipMargin: 8,
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final yValue = barSpot.y;
              String label;
              Color color;
              
              switch (barSpot.barIndex) {
                case 0:
                  label = 'Solar: ${yValue.toStringAsFixed(1)} kW';
                  color = Colors.orange[400]!;
                  break;
                case 1:
                  label = 'Wind: ${yValue.toStringAsFixed(1)} kW';
                  color = Colors.lightBlue[400]!;
                  break;
                case 2:
                  label = 'Load: ${yValue.toStringAsFixed(1)} kW';
                  color = Colors.purple[400]!;
                  break;
                case 3:
                  final batteryText = yValue >= 0 ? 'Discharging' : 'Charging';
                  label = 'Battery $batteryText: ${yValue.abs().toStringAsFixed(1)} kW';
                  color = Colors.green[400]!;
                  break;
                default:
                  label = 'Unknown';
                  color = Colors.white;
              }
              
              return LineTooltipItem(
                label,
                TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
        touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
          // Add haptic feedback or other interactions here if needed
        },
        handleBuiltInTouches: true,
      ),
    );
  }
}