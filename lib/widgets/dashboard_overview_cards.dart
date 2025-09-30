import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/energy_data_provider.dart';
import '../models/energy_data.dart';
import '../utils/formatters.dart';

class DashboardOverviewCards extends StatelessWidget {
  const DashboardOverviewCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EnergyDataProvider>(
      builder: (context, dataProvider, child) {
        final energyData = dataProvider.currentEnergyData;
        
        if (energyData == null) {
          return _buildLoadingCards(context);
        }

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: [
            _buildTotalGenerationCard(context, energyData),
            _buildCampusLoadCard(context, energyData),
            _buildGridStatusCard(context, energyData),
            _buildBatteryStatusCard(context, energyData),
          ],
        );
      },
    );
  }

  Widget _buildTotalGenerationCard(BuildContext context, EnergyData data) {
    final theme = Theme.of(context);
    final totalGeneration = data.solar.generation + data.wind.generation;

    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.green.withValues(alpha: 0.1), Colors.green.withValues(alpha: 0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.energy_savings_leaf, color: Colors.green, size: 28),
                const SizedBox(width: 8),
                Text(
                  'Total Generation',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${Formatters.formatPower(totalGeneration)}W',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('☀️ Solar: ', style: theme.textTheme.bodyMedium),
                Text(
                  '${Formatters.formatPower(data.solar.generation)}W',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('💨 Wind: ', style: theme.textTheme.bodyMedium),
                Text(
                  '${Formatters.formatPower(data.wind.generation)}W',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.lightBlueAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampusLoadCard(BuildContext context, EnergyData data) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.orange.withValues(alpha: 0.1), Colors.orange.withValues(alpha: 0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.electrical_services, color: Colors.orange, size: 28),
                const SizedBox(width: 8),
                Text(
                  'Campus Load',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${Formatters.formatPower(data.load.total)}W',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Total campus consumption',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Critical: ${Formatters.formatPower(data.load.critical)}W',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridStatusCard(BuildContext context, EnergyData data) {
    final theme = Theme.of(context);
    final netGridPower = data.grid.import - data.grid.export;
    final isImporting = netGridPower > 0;
    final isExporting = netGridPower < 0;
    
    Color statusColor;
    String statusLabel;
    String statusValue;
    IconData statusIcon;
    
    if (isImporting) {
      statusColor = Colors.red;
      statusLabel = 'Deficit';
      statusValue = '+${Formatters.formatPower(netGridPower)}W';
      statusIcon = Icons.download;
    } else if (isExporting) {
      statusColor = Colors.green;
      statusLabel = 'Surplus';
      statusValue = '${Formatters.formatPower(netGridPower)}W';
      statusIcon = Icons.upload;
    } else {
      statusColor = Colors.blue;
      statusLabel = 'Balanced';
      statusValue = '0W';
      statusIcon = Icons.balance;
    }

    return Card(
      elevation: 6, // More prominent
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [statusColor.withValues(alpha: 0.15), statusColor.withValues(alpha: 0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 28),
                const SizedBox(width: 8),
                Text(
                  'Grid Status',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              statusValue,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                statusLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isImporting ? 'Importing from Grid' : isExporting ? 'Exporting to Grid' : 'Grid Balanced',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatteryStatusCard(BuildContext context, EnergyData data) {
    final theme = Theme.of(context);
    final batteryLevel = data.battery.soc;
    final isCharging = data.battery.power > 0;
    final isDischarging = data.battery.power < 0;
    
    Color batteryColor;
    String statusText;
    IconData batteryIcon;
    
    if (batteryLevel > 80) {
      batteryColor = Colors.green;
    } else if (batteryLevel > 20) {
      batteryColor = Colors.orange;
    } else {
      batteryColor = Colors.red;
    }
    
    if (isCharging) {
      statusText = 'Charging';
      batteryIcon = Icons.battery_charging_full;
    } else if (isDischarging) {
      statusText = 'Discharging';
      batteryIcon = Icons.battery_5_bar;
    } else {
      statusText = 'Idle';
      batteryIcon = Icons.battery_3_bar;
    }

    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [batteryColor.withValues(alpha: 0.1), batteryColor.withValues(alpha: 0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(batteryIcon, color: batteryColor, size: 28),
                const SizedBox(width: 8),
                Text(
                  'Battery Status',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: batteryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${batteryLevel.toStringAsFixed(0)}%',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: batteryColor,
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: batteryLevel / 100,
              backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(batteryColor),
              minHeight: 6,
            ),
            const SizedBox(height: 8),
            Text(
              statusText,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: batteryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCards(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: List.generate(4, (index) => _buildLoadingCard(context)),
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 16,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 100,
              height: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}