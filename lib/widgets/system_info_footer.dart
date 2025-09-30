import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/energy_data_provider.dart';
import '../models/energy_data.dart';

class SystemInfoFooter extends StatelessWidget {
  const SystemInfoFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EnergyDataProvider>(
      builder: (context, dataProvider, child) {
        final energyData = dataProvider.currentEnergyData;
        final selectedCampus = dataProvider.selectedCampus;
        
        if (energyData == null || selectedCampus == null) {
          return const SizedBox.shrink();
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'System Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // First row - Last Updated and Weather
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'Last Updated',
                        _formatTimestamp(energyData.timestamp),
                        Icons.access_time,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'Weather',
                        '${energyData.weather.temperature.toStringAsFixed(1)}°C, ${energyData.weather.humidity.toStringAsFixed(0)}% humidity',
                        Icons.wb_sunny,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Second row - Sensor Status and Grid Info
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'Solar Sensors',
                        'Irradiance: ${energyData.solar.irradiance.toStringAsFixed(0)} W/m², Temp: ${energyData.solar.temperature.toStringAsFixed(1)}°C',
                        Icons.sensors,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'Grid Info',
                        'Freq: ${energyData.grid.frequency.toStringAsFixed(2)} Hz, Voltage: ${energyData.grid.voltage.toStringAsFixed(1)}V',
                        Icons.electrical_services,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Third row - Wind and Battery Info
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'Wind Sensors',
                        'Speed: ${energyData.wind.speed.toStringAsFixed(1)} m/s, Direction: ${energyData.wind.direction}°',
                        Icons.air,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'Battery Health',
                        'Voltage: ${energyData.battery.voltage.toStringAsFixed(1)}V, Cycles: ${energyData.battery.cycles}',
                        Icons.battery_full,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(BuildContext context, String title, String value, IconData icon) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: theme.colorScheme.primary.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}