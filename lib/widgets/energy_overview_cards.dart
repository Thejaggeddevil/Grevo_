import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/energy_data_provider.dart';
import '../models/energy_data.dart';
import '../utils/formatters.dart';

class EnergyOverviewCards extends StatelessWidget {
  const EnergyOverviewCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EnergyDataProvider>(
      builder: (context, dataProvider, child) {
        if (!dataProvider.hasData) {
          return _buildLoadingCards(context);
        }

        final energyData = dataProvider.currentEnergyData!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Energy Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Top row - Main metrics
            Row(
              children: [
                Expanded(
                  child: _buildEnergyCard(
                    context,
                    'Total Generation',
                    '${Formatters.formatPower(energyData.solar.generation + energyData.wind.generation)}W',
                    Icons.energy_savings_leaf,
                    Colors.green,
                    subtitle: '${dataProvider.getRenewablePercentage().toStringAsFixed(1)}% renewable',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildEnergyCard(
                    context,
                    'Current Load',
                    '${Formatters.formatPower(energyData.load.total)}W',
                    Icons.electrical_services,
                    Colors.orange,
                    subtitle: 'Total consumption',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Second row - Individual sources
            Row(
              children: [
                Expanded(
                  child: _buildSourceCard(
                    context,
                    'Solar',
                    energyData.solar.generation,
                    Icons.wb_sunny,
                    Colors.amber,
                    additionalInfo: '${energyData.solar.irradiance.toStringAsFixed(0)} W/m²',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSourceCard(
                    context,
                    'Wind',
                    energyData.wind.generation,
                    Icons.air,
                    Colors.blue,
                    additionalInfo: '${energyData.wind.speed.toStringAsFixed(1)} m/s',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Third row - Battery and Grid
            Row(
              children: [
                Expanded(
                  child: _buildBatteryCard(context, energyData.battery),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGridCard(context, energyData.grid),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Power balance indicator
            _buildPowerBalanceCard(context, dataProvider.getPowerBalance()),
          ],
        );
      },
    );
  }

  Widget _buildLoadingCards(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Energy Overview',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Loading state
        Row(
          children: [
            Expanded(child: _buildLoadingCard(context)),
            const SizedBox(width: 12),
            Expanded(child: _buildLoadingCard(context)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildLoadingCard(context)),
            const SizedBox(width: 12),
            Expanded(child: _buildLoadingCard(context)),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 8),
            Container(
              width: 80,
              height: 24,
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

  Widget _buildEnergyCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSourceCard(
    BuildContext context,
    String title,
    double power,
    IconData icon,
    Color color, {
    String? additionalInfo,
  }) {
    final theme = Theme.of(context);
    final isActive = power > 0;
    
    return Card(
      elevation: isActive ? 4 : 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isActive ? Border.all(color: color.withValues(alpha: 0.3), width: 1) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isActive ? color.withValues(alpha: 0.2) : theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: isActive ? color : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isActive ? color : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${Formatters.formatPower(power)}W',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isActive ? color : theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
            if (additionalInfo != null) ...[
              const SizedBox(height: 4),
              Text(
                additionalInfo,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBatteryCard(BuildContext context, BatteryData battery) {
    final theme = Theme.of(context);
    final isCharging = battery.power > 0;
    final isDischarging = battery.power < 0;
    
    Color getStatusColor() {
      if (isCharging) return Colors.green;
      if (isDischarging) return Colors.orange;
      return theme.colorScheme.onSurface.withValues(alpha: 0.4);
    }
    
    String getStatusText() {
      if (isCharging) return 'Charging';
      if (isDischarging) return 'Discharging';
      return 'Idle';
    }
    
    return Card(
      elevation: (isCharging || isDischarging) ? 4 : 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: (isCharging || isDischarging) 
              ? Border.all(color: getStatusColor().withValues(alpha: 0.3), width: 1) 
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: getStatusColor().withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isCharging 
                        ? Icons.battery_charging_full
                        : isDischarging 
                            ? Icons.battery_5_bar 
                            : Icons.battery_3_bar,
                    color: getStatusColor(),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Battery',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: getStatusColor(),
                        ),
                      ),
                      Text(
                        getStatusText(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Battery level indicator
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${battery.soc.toStringAsFixed(0)}%',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: getStatusColor(),
                        ),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: battery.soc / 100,
                        backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(getStatusColor()),
                        minHeight: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${Formatters.formatPower(battery.power.abs())}W',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: getStatusColor(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, GridData grid) {
    final theme = Theme.of(context);
    final isImporting = grid.import > 0;
    final isExporting = grid.export > 0;
    
    Color getStatusColor() {
      if (isExporting) return Colors.green;
      if (isImporting) return Colors.orange;
      return theme.colorScheme.onSurface.withValues(alpha: 0.4);
    }
    
    String getStatusText() {
      if (isExporting) return 'Exporting to Grid';
      if (isImporting) return 'Importing from Grid';
      return 'Grid Idle';
    }
    
    double getPrimaryValue() {
      if (isExporting) return grid.export;
      if (isImporting) return grid.import;
      return 0;
    }
    
    return Card(
      elevation: (isImporting || isExporting) ? 4 : 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: (isImporting || isExporting) 
              ? Border.all(color: getStatusColor().withValues(alpha: 0.3), width: 1) 
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: getStatusColor().withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isExporting 
                        ? Icons.upload 
                        : isImporting 
                            ? Icons.download 
                            : Icons.electrical_services,
                    color: getStatusColor(),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Grid',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: getStatusColor(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${Formatters.formatPower(getPrimaryValue())}W',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: getStatusColor(),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              getStatusText(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPowerBalanceCard(BuildContext context, double balance) {
    final theme = Theme.of(context);
    final isPositive = balance > 0;
    final isBalanced = balance.abs() < 100; // Within 100W considered balanced
    
    Color getBalanceColor() {
      if (isBalanced) return Colors.blue;
      return isPositive ? Colors.green : Colors.red;
    }
    
    String getBalanceText() {
      if (isBalanced) return 'Balanced';
      return isPositive ? 'Surplus' : 'Deficit';
    }
    
    IconData getBalanceIcon() {
      if (isBalanced) return Icons.balance;
      return isPositive ? Icons.trending_up : Icons.trending_down;
    }
    
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              getBalanceColor().withValues(alpha: 0.1),
              getBalanceColor().withValues(alpha: 0.05),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          border: Border.all(
            color: getBalanceColor().withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: getBalanceColor().withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                getBalanceIcon(),
                color: getBalanceColor(),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Power Balance',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${isPositive ? '+' : ''}${Formatters.formatPower(balance)}W',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: getBalanceColor(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: getBalanceColor().withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          getBalanceText(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: getBalanceColor(),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
