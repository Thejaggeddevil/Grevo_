import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/energy_data_provider.dart';
import '../models/campus.dart';

class CampusSelector extends StatelessWidget {
  const CampusSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EnergyDataProvider>(
      builder: (context, dataProvider, child) {
        if (dataProvider.campuses.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Campus',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                DropdownButtonFormField<String>(
                  initialValue: dataProvider.selectedCampus?.id,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.location_on),
                    hintText: 'Choose a campus to monitor',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: dataProvider.campuses.map((campus) {
                    return DropdownMenuItem<String>(
                      value: campus.id,
                      child: _buildCampusItem(context, campus),
                    );
                  }).toList(),
                  onChanged: dataProvider.isLoading ? null : (String? value) {
                    if (value != null) {
                      dataProvider.selectCampus(value);
                    }
                  },
                ),
                
                // Selected campus details
                if (dataProvider.selectedCampus != null) ...[
                  const SizedBox(height: 16),
                  _buildCampusDetails(context, dataProvider.selectedCampus!),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCampusItem(BuildContext context, Campus campus) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                campus.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              if (campus.location.city.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  '${campus.location.city}, ${campus.location.country}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
        _buildEnergySourceIcons(context, campus),
      ],
    );
  }

  Widget _buildEnergySourceIcons(BuildContext context, Campus campus) {
    final sources = <Widget>[];
    
    if (campus.energySources.solar.enabled) {
      sources.add(Icon(
        Icons.wb_sunny,
        size: 16,
        color: Colors.amber[600],
      ));
    }
    
    if (campus.energySources.wind.enabled) {
      sources.add(Icon(
        Icons.air,
        size: 16,
        color: Colors.blue[600],
      ));
    }
    
    if (campus.energySources.battery.enabled) {
      sources.add(Icon(
        Icons.battery_charging_full,
        size: 16,
        color: Colors.green[600],
      ));
    }

    if (sources.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 4,
      children: sources,
    );
  }

  Widget _buildCampusDetails(BuildContext context, Campus campus) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campus info header
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Campus Information',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Location details
          _buildDetailRow(
            context,
            Icons.location_city,
            'Location',
            '${campus.location.address}, ${campus.location.city}',
          ),
          
          if (campus.location.coordinates.latitude != 0.0) ...[
            const SizedBox(height: 6),
            _buildDetailRow(
              context,
              Icons.gps_fixed,
              'Coordinates',
              '${campus.location.coordinates.latitude.toStringAsFixed(4)}, ${campus.location.coordinates.longitude.toStringAsFixed(4)}',
            ),
          ],
          
          // Energy sources summary
          const SizedBox(height: 8),
          _buildEnergySourcesSummary(context, campus),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 14,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodySmall,
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnergySourcesSummary(BuildContext context, Campus campus) {
    final theme = Theme.of(context);
    final sources = <Widget>[];

    if (campus.energySources.solar.enabled) {
      sources.add(_buildSourceChip(
        context,
        Icons.wb_sunny,
        'Solar',
        '${campus.energySources.solar.capacity}kW',
        Colors.amber,
      ));
    }

    if (campus.energySources.wind.enabled) {
      sources.add(_buildSourceChip(
        context,
        Icons.air,
        'Wind',
        '${campus.energySources.wind.capacity}kW',
        Colors.blue,
      ));
    }

    if (campus.energySources.battery.enabled) {
      sources.add(_buildSourceChip(
        context,
        Icons.battery_charging_full,
        'Battery',
        '${campus.energySources.battery.capacity}kWh',
        Colors.green,
      ));
    }

    if (sources.isEmpty) {
      return Text(
        'No energy sources configured',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.5),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.energy_savings_leaf,
              size: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 8),
            Text(
              'Energy Sources:',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: sources,
        ),
      ],
    );
  }

  Widget _buildSourceChip(
    BuildContext context,
    IconData icon,
    String label,
    String capacity,
    Color color,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            capacity,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 10,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}