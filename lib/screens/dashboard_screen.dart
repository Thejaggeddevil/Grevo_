import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/energy_data_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/campus_selector.dart';
import '../widgets/energy_overview_cards.dart';
import '../widgets/energy_chart_widget.dart';
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
          // Connection Status
          Consumer<EnergyDataProvider>(
            builder: (context, dataProvider, child) {
              return ConnectionStatusWidget(
                isConnected: dataProvider.isConnected,
                hasError: dataProvider.error != null,
                onRetry: () => dataProvider.reconnectSocket(),
              );
            },
          ),
          
          // Theme Toggle
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode 
                      ? Icons.light_mode 
                      : Icons.dark_mode,
                ),
                onPressed: () => themeProvider.toggleTheme(),
                tooltip: 'Toggle theme',
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
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  contentPadding: EdgeInsets.zero,
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
                  // Campus Selector
                  const CampusSelector(),
                  const SizedBox(height: 24),
                  
                  // Error Banner (if any)
                  if (dataProvider.error != null)
                    _buildErrorBanner(dataProvider.error!),
                  
                  // Energy Overview Cards
                  const EnergyOverviewCards(),
                  const SizedBox(height: 24),
                  
                  // Energy Chart
                  const EnergyChartWidget(),
                  const SizedBox(height: 24),
                  
                  // Additional Information
                  _buildAdditionalInfo(dataProvider),
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
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
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
        color: Theme.of(context).colorScheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
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
              color: theme.colorScheme.primary.withOpacity(0.7),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
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
    
    switch (value) {
      case 'refresh':
        dataProvider.refreshCurrentData();
        break;
      case 'settings':
        _showSettingsDialog();
        break;
      case 'about':
        _showAboutDialog();
        break;
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: const Text('Settings functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Grevo',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 Grevo Team',
      children: const [
        Text('Renewable Energy Management System'),
        SizedBox(height: 8),
        Text('Monitor and manage renewable energy sources in real-time.'),
      ],
    );
  }
}