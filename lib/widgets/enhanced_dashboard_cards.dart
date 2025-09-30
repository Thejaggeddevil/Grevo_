import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/energy_data_provider.dart';
import '../theme/app_theme.dart';

class EnhancedDashboardCards extends StatelessWidget {
  const EnhancedDashboardCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EnergyDataProvider>(
      builder: (context, dataProvider, child) {
        final energyData = dataProvider.currentEnergyData;
        final isLoading = dataProvider.isLoading;

        if (isLoading && energyData == null) {
          return _buildLoadingCards();
        }

        return Column(
          children: [
            // First row of cards
            Row(
              children: [
                Expanded(child: _buildTotalEnergyCard(energyData)),
                const SizedBox(width: 16),
                Expanded(child: _buildPowerFlowCard(energyData)),
              ],
            ),
            const SizedBox(height: 16),
            // Second row of cards
            Row(
              children: [
                Expanded(child: _buildFinancialImpactCard(energyData)),
                const SizedBox(width: 16),
                Expanded(child: _buildBatteryStatusCard(energyData)),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildSkeletonCard()),
            const SizedBox(width: 16),
            Expanded(child: _buildSkeletonCard()),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildSkeletonCard()),
            const SizedBox(width: 16),
            Expanded(child: _buildSkeletonCard()),
          ],
        ),
      ],
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentColor.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 80,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const Spacer(),
          Container(
            width: 120,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalEnergyCard(energyData) {
    final solarOutput = energyData?.solar.generation ?? 0.0;
    final windOutput = energyData?.wind.generation ?? 0.0;
    final totalGenerated = solarOutput + windOutput;
    final peakToday = _calculatePeakToday(energyData);
    final efficiency = _calculateEfficiency(energyData);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentColor.withAlpha(38),
            AppTheme.accentColor.withAlpha(26),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentColor.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.energy_savings_leaf,
                color: AppTheme.accentColor,
                size: 28,
              ),
              const SizedBox(width: 8),
              const Text(
                'Total Energy Snapshot',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${totalGenerated.toStringAsFixed(1)} kWh',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.wb_sunny,
                color: Colors.orange[400],
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Solar: ${solarOutput.toStringAsFixed(1)} kWh',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.air,
                color: Colors.lightBlue[400],
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Wind: ${windOutput.toStringAsFixed(1)} kWh',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Peak Today: ${peakToday.toStringAsFixed(1)} kW',
                style: TextStyle(
                  color: AppTheme.accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Efficiency: ${efficiency.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: AppTheme.accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPowerFlowCard(energyData) {
    final campusLoad = energyData?.load.total ?? 0.0;
    final criticalLoad = energyData?.load.critical ?? 0.0;
    final gridPower = (energyData?.grid.import ?? 0.0) - (energyData?.grid.export ?? 0.0);
    final avgLoad = _calculate24hAvg(energyData);
    final loadChange = avgLoad > 0 ? ((campusLoad - avgLoad) / avgLoad * 100) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple[800]!.withAlpha(51),
            Colors.purple[900]!.withAlpha(26),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple[400]!.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.electric_bolt,
                color: Colors.purple[400],
                size: 28,
              ),
              const SizedBox(width: 8),
              const Text(
                'Current Power Flow',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${campusLoad.toStringAsFixed(1)} kW',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Critical Load: ${criticalLoad.toStringAsFixed(1)} kW',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                gridPower >= 0 ? Icons.call_received : Icons.call_made,
                color: gridPower >= 0 ? Colors.red[400] : Colors.green[400],
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${gridPower >= 0 ? "From" : "To"} Grid: ${gridPower.abs().toStringAsFixed(1)} kW',
                style: TextStyle(
                  color: gridPower >= 0 ? Colors.red[300] : Colors.green[300],
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'vs. 24h Avg: ${loadChange >= 0 ? "+" : ""}${loadChange.toStringAsFixed(1)}%',
            style: TextStyle(
              color: Colors.purple[400],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialImpactCard(energyData) {
    final costSavings = _calculateMonthlyCostSavings(energyData);
    final co2Avoided = _calculateCO2Avoided(energyData);
    final todayCost = _calculateTodayCost(energyData);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green[800]!.withAlpha(51),
            Colors.green[900]!.withAlpha(26),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[400]!.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: Colors.green[400],
                size: 28,
              ),
              const SizedBox(width: 8),
              const Text(
                'Financial & Environmental Impact',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '₹${costSavings.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Monthly Savings',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.eco,
                color: Colors.green[400],
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'CO₂ Avoided: ${co2Avoided.toStringAsFixed(0)} kg',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Cost Today: ₹${todayCost.toStringAsFixed(0)}',
            style: TextStyle(
              color: Colors.green[400],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryStatusCard(energyData) {
    final batteryLevel = energyData?.battery.soc ?? 0.0;
    final batteryPower = energyData?.battery.power ?? 0.0;
    final estimatedRuntime = _calculateEstimatedRuntime(energyData);
    String currentState = batteryPower > 0 ? 'Charging' : batteryPower < 0 ? 'Discharging' : 'Idle';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue[800]!.withAlpha(51),
            Colors.blue[900]!.withAlpha(26),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[400]!.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.battery_full,
                color: Colors.blue[400],
                size: 28,
              ),
              const SizedBox(width: 8),
              const Text(
                'Battery & Storage Status',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                '${batteryLevel.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              // Battery level indicator
              Container(
                width: 60,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: batteryLevel / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: batteryLevel > 20 ? Colors.green[400] : Colors.red[400],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                currentState == 'Charging' ? Icons.battery_charging_full :
                currentState == 'Discharging' ? Icons.battery_std : Icons.battery_unknown,
                color: currentState == 'Charging' ? Colors.green[400] :
                       currentState == 'Discharging' ? Colors.orange[400] : Colors.grey[400],
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Current State: $currentState',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Estimated Runtime: ${estimatedRuntime.toStringAsFixed(1)} hours',
            style: TextStyle(
              color: Colors.blue[400],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for calculations
  double _calculatePeakToday(energyData) {
    if (energyData == null) return 0.0;
    // Mock calculation - would use historical data in real implementation
    final current = (energyData.solar.generation + energyData.wind.generation);
    return current * 1.3; // Assume peak is 30% higher than current
  }

  double _calculateEfficiency(energyData) {
    if (energyData == null) return 0.0;
    final generated = energyData.solar.generation + energyData.wind.generation;
    final theoretical = 100.0; // Mock theoretical maximum
    return (generated / theoretical) * 100;
  }

  double _calculate24hAvg(energyData) {
    if (energyData == null) return 0.0;
    // Mock calculation - would use historical data in real implementation
    return energyData.load.total * 0.85;
  }

  double _calculateMonthlyCostSavings(energyData) {
    if (energyData == null) return 0.0;
    // Mock calculation based on energy generated and grid rates
    final generated = energyData.solar.generation + energyData.wind.generation;
    return generated * 30 * 6.5; // 30 days * ₹6.5 per kWh saved
  }

  double _calculateCO2Avoided(energyData) {
    if (energyData == null) return 0.0;
    // Mock calculation: 0.82 kg CO2 per kWh (India grid factor)
    final generated = energyData.solar.generation + energyData.wind.generation;
    return generated * 0.82 * 30; // Monthly CO2 avoided
  }

  double _calculateTodayCost(energyData) {
    if (energyData == null) return 0.0;
    final gridUsed = energyData.grid.import > 0 ? energyData.grid.import : 0;
    return gridUsed * 24 * 6.5; // Mock: 24 hours * ₹6.5 per kWh
  }

  double _calculateEstimatedRuntime(energyData) {
    if (energyData == null) return 0.0;
    final batteryCapacity = 1000.0; // Mock: 1000 kWh total capacity
    final currentCapacity = batteryCapacity * (energyData.battery.soc / 100);
    final currentLoad = energyData.load.total;
    if (currentLoad <= 0) return 0.0;
    return currentCapacity / currentLoad;
  }
}