import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/energy_data_provider.dart';
import '../models/energy_data.dart';
import '../utils/formatters.dart';

class EnergyChartWidget extends StatefulWidget {
  const EnergyChartWidget({super.key});

  @override
  State<EnergyChartWidget> createState() => _EnergyChartWidgetState();
}

class _EnergyChartWidgetState extends State<EnergyChartWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeRange = '1H';
  ChartType _chartType = ChartType.line;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EnergyDataProvider>(
      builder: (context, dataProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chart header with controls
            _buildChartHeader(context, dataProvider),
            const SizedBox(height: 16),
            
            // Chart tabs
            _buildChartTabs(context),
            const SizedBox(height: 16),
            
            // Chart content
            _buildChartContent(context, dataProvider),
          ],
        );
      },
    );
  }

  Widget _buildChartHeader(BuildContext context, EnergyDataProvider dataProvider) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Expanded(
          child: Text(
            'Energy Analytics',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // Time range selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedTimeRange,
              items: const [
                DropdownMenuItem(value: '1H', child: Text('1 Hour')),
                DropdownMenuItem(value: '6H', child: Text('6 Hours')),
                DropdownMenuItem(value: '24H', child: Text('24 Hours')),
                DropdownMenuItem(value: '7D', child: Text('7 Days')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedTimeRange = value;
                  });
                  _loadDataForTimeRange(dataProvider, value);
                }
              },
            ),
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Chart type selector
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.show_chart,
                  color: _chartType == ChartType.line 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                onPressed: () => setState(() => _chartType = ChartType.line),
                tooltip: 'Line Chart',
              ),
              IconButton(
                icon: Icon(
                  Icons.bar_chart,
                  color: _chartType == ChartType.bar 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                onPressed: () => setState(() => _chartType = ChartType.bar),
                tooltip: 'Bar Chart',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartTabs(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Generation', icon: Icon(Icons.energy_savings_leaf, size: 16)),
          Tab(text: 'Consumption', icon: Icon(Icons.electrical_services, size: 16)),
          Tab(text: 'Battery', icon: Icon(Icons.battery_charging_full, size: 16)),
          Tab(text: 'Weather', icon: Icon(Icons.wb_sunny, size: 16)),
        ],
        labelStyle: const TextStyle(fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
    );
  }

  Widget _buildChartContent(BuildContext context, EnergyDataProvider dataProvider) {
    return Card(
      child: Container(
        height: 300,
        padding: const EdgeInsets.all(16),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildGenerationChart(context, dataProvider),
            _buildConsumptionChart(context, dataProvider),
            _buildBatteryChart(context, dataProvider),
            _buildWeatherChart(context, dataProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerationChart(BuildContext context, EnergyDataProvider dataProvider) {
    if (dataProvider.historicalData.isEmpty) {
      return _buildNoDataWidget('No generation data available');
    }

    final data = dataProvider.historicalData;
    
    if (_chartType == ChartType.line) {
      return LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          titlesData: _buildTitlesData(context),
          borderData: FlBorderData(show: true),
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          minY: 0,
          maxY: _getMaxGenerationValue(data),
          lineBarsData: [
            // Solar line
            LineChartBarData(
              spots: data.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.solar.generation);
              }).toList(),
              isCurved: true,
              color: Colors.amber,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.amber.withValues(alpha: 0.3),
              ),
            ),
            // Wind line
            LineChartBarData(
              spots: data.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.wind.generation);
              }).toList(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      );
    } else {
      return BarChart(
        BarChartData(
          gridData: FlGridData(show: true),
          titlesData: _buildTitlesData(context),
          borderData: FlBorderData(show: true),
          maxY: _getMaxGenerationValue(data),
          barGroups: data.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.solar.generation,
                  color: Colors.amber,
                  width: 16,
                ),
                BarChartRodData(
                  toY: entry.value.wind.generation,
                  color: Colors.blue,
                  width: 16,
                ),
              ],
            );
          }).toList(),
        ),
      );
    }
  }

  Widget _buildConsumptionChart(BuildContext context, EnergyDataProvider dataProvider) {
    if (dataProvider.historicalData.isEmpty) {
      return _buildNoDataWidget('No consumption data available');
    }

    final data = dataProvider.historicalData;
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: _buildTitlesData(context),
        borderData: FlBorderData(show: true),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: 0,
        maxY: _getMaxConsumptionValue(data),
        lineBarsData: [
          // Total load line
          LineChartBarData(
            spots: data.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.load.total);
            }).toList(),
            isCurved: true,
            color: Colors.orange,
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.orange.withValues(alpha: 0.3),
            ),
          ),
          // Critical load line
          LineChartBarData(
            spots: data.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.load.critical);
            }).toList(),
            isCurved: true,
            color: Colors.red,
            barWidth: 2,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryChart(BuildContext context, EnergyDataProvider dataProvider) {
    if (dataProvider.historicalData.isEmpty) {
      return _buildNoDataWidget('No battery data available');
    }

    final data = dataProvider.historicalData;
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: _buildTitlesData(context, isPercentage: true),
        borderData: FlBorderData(show: true),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          // Battery SOC line
          LineChartBarData(
            spots: data.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.battery.soc);
            }).toList(),
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.green.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherChart(BuildContext context, EnergyDataProvider dataProvider) {
    if (dataProvider.historicalData.isEmpty) {
      return _buildNoDataWidget('No weather data available');
    }

    final data = dataProvider.historicalData;
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: _buildTitlesData(context),
        borderData: FlBorderData(show: true),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: _getMinTemperature(data) - 5,
        maxY: _getMaxTemperature(data) + 5,
        lineBarsData: [
          // Temperature line
          LineChartBarData(
            spots: data.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.weather.temperature);
            }).toList(),
            isCurved: true,
            color: Colors.purple,
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.purple.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataWidget(String message) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 48,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => 
                Provider.of<EnergyDataProvider>(context, listen: false)
                    .refreshCurrentData(),
            child: const Text('Refresh Data'),
          ),
        ],
      ),
    );
  }

  FlTitlesData _buildTitlesData(BuildContext context, {bool isPercentage = false}) {
    final theme = Theme.of(context);
    
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) {
            String text;
            if (isPercentage) {
              text = '${value.toInt()}%';
            } else {
              text = Formatters.formatPower(value);
            }
            return Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitlesWidget: (value, meta) {
            final dataProvider = Provider.of<EnergyDataProvider>(context, listen: false);
            if (value.toInt() >= dataProvider.historicalData.length) {
              return const SizedBox.shrink();
            }
            
            final timestamp = dataProvider.historicalData[value.toInt()].timestamp;
            return Text(
              Formatters.formatTime(timestamp),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            );
          },
        ),
      ),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  double _getMaxGenerationValue(List<EnergyData> data) {
    double max = 0;
    for (final item in data) {
      final total = item.solar.generation + item.wind.generation;
      if (total > max) max = total;
    }
    return max * 1.1; // Add 10% padding
  }

  double _getMaxConsumptionValue(List<EnergyData> data) {
    double max = 0;
    for (final item in data) {
      if (item.load.total > max) max = item.load.total;
    }
    return max * 1.1; // Add 10% padding
  }

  double _getMinTemperature(List<EnergyData> data) {
    if (data.isEmpty) return 0;
    
    double min = data.first.weather.temperature;
    for (final item in data) {
      if (item.weather.temperature < min) min = item.weather.temperature;
    }
    return min;
  }

  double _getMaxTemperature(List<EnergyData> data) {
    if (data.isEmpty) return 0;
    
    double max = data.first.weather.temperature;
    for (final item in data) {
      if (item.weather.temperature > max) max = item.weather.temperature;
    }
    return max;
  }

  void _loadDataForTimeRange(EnergyDataProvider dataProvider, String timeRange) {
    final now = DateTime.now();
    DateTime startTime;

    switch (timeRange) {
      case '1H':
        startTime = now.subtract(const Duration(hours: 1));
        break;
      case '6H':
        startTime = now.subtract(const Duration(hours: 6));
        break;
      case '24H':
        startTime = now.subtract(const Duration(hours: 24));
        break;
      case '7D':
        startTime = now.subtract(const Duration(days: 7));
        break;
      default:
        startTime = now.subtract(const Duration(hours: 1));
    }

    dataProvider.loadHistoricalData(
      startTime: startTime,
      endTime: now,
    );
  }
}

enum ChartType {
  line,
  bar,
}
