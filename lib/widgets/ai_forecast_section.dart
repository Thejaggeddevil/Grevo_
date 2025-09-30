import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/energy_data_provider.dart';
import '../theme/app_theme.dart';

class AIForecastSection extends StatelessWidget {
  const AIForecastSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EnergyDataProvider>(
      builder: (context, dataProvider, child) {
        final energyData = dataProvider.currentEnergyData;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.accentColor.withAlpha(77)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: AppTheme.accentColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI Forecast & Optimization',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 7-Day Energy Forecast
              _buildEnergyForecast(),
              const SizedBox(height: 20),

              // Weather Impact
              _buildWeatherImpact(energyData),
              const SizedBox(height: 20),

              // AI Optimization Suggestions
              _buildOptimizationSuggestions(energyData),
              const SizedBox(height: 16),

              // Performance Alerts
              _buildPerformanceAlerts(energyData),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEnergyForecast() {
    final days = ['Today', 'Tomorrow', 'Sat', 'Sun', 'Mon', 'Tue', 'Wed'];
    final forecasts = [145.2, 168.5, 134.8, 156.3, 172.1, 149.7, 163.4]; // Mock data

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '7-Day Energy Forecast',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withAlpha(51)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.asMap().entries.map((entry) {
              final index = entry.key;
              final day = entry.value;
              final forecast = forecasts[index];
              final isToday = index == 0;

              return Expanded(
                child: Column(
                  children: [
                    Text(
                      day,
                      style: TextStyle(
                        color: isToday ? AppTheme.accentColor : Colors.white70,
                        fontSize: 11,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                      decoration: BoxDecoration(
                        color: isToday ? AppTheme.accentColor.withAlpha(51) : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${forecast.toStringAsFixed(1)}',
                        style: TextStyle(
                          color: isToday ? AppTheme.accentColor : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'kWh',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherImpact(energyData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weather Impact',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Today's Weather
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange[700]!.withAlpha(77),
                      Colors.orange[800]!.withAlpha(51),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.wb_sunny,
                      color: Colors.orange[400],
                      size: 28,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Today',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Text(
                      'Sunny',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+25% Solar',
                      style: TextStyle(
                        color: Colors.orange[400],
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Tomorrow's Weather
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.lightBlue[700]!.withAlpha(77),
                      Colors.lightBlue[800]!.withAlpha(51),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.air,
                      color: Colors.lightBlue[400],
                      size: 28,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tomorrow',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Text(
                      'High Wind',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+35% Wind',
                      style: TextStyle(
                        color: Colors.lightBlue[400],
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptimizationSuggestions(energyData) {
    final suggestions = [
      {
        'icon': Icons.battery_charging_full,
        'title': 'Battery Charging Optimization',
        'description': 'Schedule battery charging during peak solar hours (11 AM - 3 PM) for maximum efficiency.',
        'priority': 'high',
        'color': Colors.green[400]!,
      },
      {
        'icon': Icons.ac_unit,
        'title': 'Pre-cooling Strategy',
        'description': 'Consider pre-cooling campus blocks between 9-10 AM if solar forecast is high to reduce evening peak load.',
        'priority': 'medium',
        'color': Colors.blue[400]!,
      },
      {
        'icon': Icons.settings,
        'title': 'Wind Power Optimization',
        'description': 'With tomorrow\'s high wind forecast, prioritize battery charging from wind power.',
        'priority': 'medium',
        'color': Colors.lightBlue[400]!,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Optimization Suggestions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...suggestions.map((suggestion) => _buildSuggestionCard(suggestion)),
      ],
    );
  }

  Widget _buildSuggestionCard(Map<String, dynamic> suggestion) {
    final isPriorityHigh = suggestion['priority'] == 'high';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isPriorityHigh ? Colors.orange.withAlpha(77) : Colors.white.withAlpha(51),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: suggestion['color'].withAlpha(51),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              suggestion['icon'],
              color: suggestion['color'],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        suggestion['title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isPriorityHigh)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withAlpha(51),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'HIGH',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  suggestion['description'],
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceAlerts(energyData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performance Alerts',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[900]!.withAlpha(51),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.orange.withAlpha(77)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: Colors.orange[400],
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Solar Panel Bank 3 performance slightly below prediction. Suggest maintenance check.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: Colors.orange[400],
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                child: const Text(
                  'View Details',
                  style: TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}