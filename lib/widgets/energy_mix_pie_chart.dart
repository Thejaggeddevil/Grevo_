import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/energy_data_provider.dart';
import '../theme/app_theme.dart';

class EnergyMixPieChart extends StatelessWidget {
  const EnergyMixPieChart({super.key});

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
              Text(
                'Energy Mix (Current Hour)',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentColor,
                ),
              ),
              const SizedBox(height: 20),
              // Pie Chart
              SizedBox(
                height: 180,
                width: double.infinity,
                child: energyData != null
                    ? PieChart(
                        _buildPieChartData(energyData),
                        swapAnimationDuration: Duration.zero,
                      )
                    : _buildLoadingChart(),
              ),
              const SizedBox(height: 20),
              // Legend
              _buildLegend(energyData),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingChart() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 12),
          Text(
            'Loading energy mix...',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  PieChartData _buildPieChartData(energyData) {
    final solarGeneration = energyData.solar.generation;
    final windGeneration = energyData.wind.generation;
    final batteryOutput = energyData.battery.power < 0 ? energyData.battery.power.abs() : 0.0;
    final gridPower = energyData.grid.import > 0 ? energyData.grid.import : 0.0;
    
    final total = solarGeneration + windGeneration + batteryOutput + gridPower;
    
    if (total <= 0) {
      return PieChartData(
        sections: [
          PieChartSectionData(
            color: Colors.grey[600]!,
            value: 100,
            title: 'No Data',
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      );
    }

    final solarPercentage = (solarGeneration / total) * 100;
    final windPercentage = (windGeneration / total) * 100;
    final batteryPercentage = (batteryOutput / total) * 100;
    final gridPercentage = (gridPower / total) * 100;

    return PieChartData(
      sections: [
        if (solarPercentage > 0)
          PieChartSectionData(
            color: Colors.orange[400]!,
            value: solarPercentage,
            title: '${solarPercentage.toStringAsFixed(1)}%',
            radius: 65,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        if (windPercentage > 0)
          PieChartSectionData(
            color: Colors.lightBlue[400]!,
            value: windPercentage,
            title: '${windPercentage.toStringAsFixed(1)}%',
            radius: 65,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        if (batteryPercentage > 0)
          PieChartSectionData(
            color: Colors.green[400]!,
            value: batteryPercentage,
            title: '${batteryPercentage.toStringAsFixed(1)}%',
            radius: 65,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        if (gridPercentage > 0)
          PieChartSectionData(
            color: Colors.red[400]!,
            value: gridPercentage,
            title: '${gridPercentage.toStringAsFixed(1)}%',
            radius: 65,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
      ],
      sectionsSpace: 1,
      centerSpaceRadius: 25,
      pieTouchData: PieTouchData(
        enabled: false,
      ),
    );
  }

  Widget _buildLegend(energyData) {
    if (energyData == null) {
      return const SizedBox.shrink();
    }

    final solarGeneration = energyData.solar.generation;
    final windGeneration = energyData.wind.generation;
    final batteryOutput = energyData.battery.power < 0 ? energyData.battery.power.abs() : 0.0;
    final gridPower = energyData.grid.import > 0 ? energyData.grid.import : 0.0;
    
    final total = solarGeneration + windGeneration + batteryOutput + gridPower;

    return Column(
      children: [
        if (solarGeneration > 0)
          _buildLegendItem(
            'Solar Power',
            Colors.orange[400]!,
            Icons.wb_sunny,
            solarGeneration,
            total > 0 ? (solarGeneration / total) * 100 : 0,
          ),
        if (windGeneration > 0)
          _buildLegendItem(
            'Wind Power',
            Colors.lightBlue[400]!,
            Icons.air,
            windGeneration,
            total > 0 ? (windGeneration / total) * 100 : 0,
          ),
        if (batteryOutput > 0)
          _buildLegendItem(
            'Battery Power',
            Colors.green[400]!,
            Icons.battery_full,
            batteryOutput,
            total > 0 ? (batteryOutput / total) * 100 : 0,
          ),
        if (gridPower > 0)
          _buildLegendItem(
            'Grid Power',
            Colors.red[400]!,
            Icons.electric_bolt,
            gridPower,
            total > 0 ? (gridPower / total) * 100 : 0,
          ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, IconData icon, double value, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${value.toStringAsFixed(1)} kW',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withAlpha(51),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}