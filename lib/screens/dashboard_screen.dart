import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/energy_data_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/dashboard_overview_cards.dart';
import '../widgets/combined_analytics_chart.dart';
import '../widgets/chart_legend.dart';
import '../widgets/system_info_footer.dart';
import '../widgets/connection_status_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Grevo Dashboard'),
        actions: [
          // Campus Selector Dropdown
          Consumer<EnergyDataProvider>(
            builder: (context, dataProvider, child) {
              if (dataProvider.campuses.isEmpty) {
                return const SizedBox.shrink();
              }
              return Container(
                margin: const EdgeInsets.only(right: 16),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: dataProvider.selectedCampus?.id,
                    hint: const Text('Select Campus', style: TextStyle(color: Colors.white70)),
                    dropdownColor: Theme.of(context).appBarTheme.backgroundColor,
                    items: dataProvider.campuses.map((campus) {
                      return DropdownMenuItem<String>(
                        value: campus.id,
                        child: Text(
                          campus.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        dataProvider.selectCampus(value);
                      }
                    },
                  ),
                ),
              );
            },
          ),
          
          // Live Status Indicator
          Consumer<EnergyDataProvider>(
            builder: (context, dataProvider, child) {
              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: dataProvider.isConnected ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      dataProvider.isConnected ? 'LIVE' : 'OFFLINE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Settings Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => _handleMenuSelection(value),
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Refresh Data'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'theme',
                child: Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return ListTile(
                      leading: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                      title: Text(themeProvider.isDarkMode ? 'Light Theme' : 'Dark Theme'),
                      contentPadding: EdgeInsets.zero,
                    );
                  }
                ),
              ),
              const PopupMenuItem(
                value: 'about',
                child: ListTile(
                  leading: Icon(Icons.info),
                  title: Text('About'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<EnergyDataProvider>(
        builder: (context, dataProvider, child) {
          if (dataProvider.isLoading && dataProvider.campuses.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading campus data...'),
                ],
              ),
            );
          }

          if (dataProvider.error != null && dataProvider.campuses.isEmpty) {
            return _buildErrorState(dataProvider);
          }

          if (dataProvider.campuses.isEmpty) {
            return _buildNoCampusesState();
          }

          return RefreshIndicator(
            onRefresh: () => dataProvider.refreshCurrentData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Error Banner (if any)
                  if (dataProvider.error != null)
                    _buildErrorBanner(dataProvider.error!),
                  
                  // Main Overview Section - Four large cards
                  const DashboardOverviewCards(),
                  const SizedBox(height: 24),
                  
                  // Analytics Graph Section Header
                  Text(
                    'Analytics - Last 24 Hours',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Chart Legend
                  const ChartLegend(),
                  const SizedBox(height: 16),
                  
                  // Combined Analytics Chart
                  const CombinedAnalyticsChart(),
                  const SizedBox(height: 24),
                  
                  // System Information Footer
                  const SystemInfoFooter(),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Consumer<EnergyDataProvider>(
        builder: (context, dataProvider, child) {
          return FloatingActionButton(
            onPressed: () => dataProvider.refreshCurrentData(),
            tooltip: 'Refresh Data',
            child: const Icon(Icons.refresh),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(EnergyDataProvider dataProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to Load Data',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              dataProvider.error ?? 'Unknown error occurred',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => dataProvider.refreshCampuses(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
                OutlinedButton.icon(
                  onPressed: () => dataProvider.checkServerConnection(),
                  icon: const Icon(Icons.network_check),
                  label: const Text('Check Connection'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoCampusesState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Campuses Found',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'No renewable energy campuses are currently configured.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => 
                  Provider.of<EnergyDataProvider>(context, listen: false)
                      .refreshCampuses(),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_rounded,
            color: Theme.of(context).colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 13,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () {
              // Clear error temporarily
              Provider.of<EnergyDataProvider>(context, listen: false);
            },
            color: Theme.of(context).colorScheme.error,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo(EnergyDataProvider dataProvider) {
    if (dataProvider.currentEnergyData == null) {
      return const SizedBox.shrink();
    }

    final energyData = dataProvider.currentEnergyData!;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Last Updated',
                    _formatTimestamp(energyData.timestamp),
                    Icons.update,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Data Source',
                    energyData.source.toUpperCase(),
                    Icons.source,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Campus ID',
                    energyData.campusId,
                    Icons.location_on,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Weather Temp',
                    '${energyData.weather.temperature.toStringAsFixed(1)}°C',
                    Icons.thermostat,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
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
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _handleMenuSelection(String value) {
    final dataProvider = Provider.of<EnergyDataProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    switch (value) {
      case 'refresh':
        dataProvider.refreshCurrentData();
        break;
      case 'theme':
        themeProvider.toggleTheme();
        break;
      case 'about':
        _showAboutDialog();
        break;
    }
  }
  
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Grevo'),
        content: const Text(
          'Grevo is a smart, hybrid renewable energy management system for university campuses in Rajasthan, India.\n\n'
          'The system intelligently manages power from Solar and Wind sources, battery storage, and the public grid.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

}
