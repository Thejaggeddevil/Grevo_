import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/energy_data_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/enhanced_dashboard_cards.dart';
import '../widgets/multi_line_energy_chart.dart';
import '../widgets/energy_mix_pie_chart.dart';
import '../widgets/ai_forecast_section.dart';
import '../widgets/profile_dialog.dart';
import '../widgets/settings_dialog.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Campus selector state
  String _selectedCampus = 'MNIT Jaipur Campus';
  final List<String> _campuses = [
    'MNIT Jaipur Campus',
    'BITS Pilani Campus',
    'JECRC University Campus',
    'Rajasthan University Campus',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildEnhancedAppBar(),
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

          return _buildEnhancedDashboard();
        },
      ),
    );
  }

  AppBar _buildEnhancedAppBar() {
    return AppBar(
      title: Row(
        children: [
          const Text(
            'Grevo Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          // Campus Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.accentColor.withAlpha(77)),
            ),
            child: DropdownButton<String>(
              value: _selectedCampus,
              items: _campuses.map((campus) {
                return DropdownMenuItem(
                  value: campus,
                  child: Text(
                    campus,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (value) async {
                if (value != null && value != _selectedCampus) {
                  setState(() {
                    _selectedCampus = value;
                  });
                  
                  // Refresh data for new campus
                  final dataProvider = Provider.of<EnergyDataProvider>(context, listen: false);
                  await dataProvider.refreshCurrentData();
                  
                  // Show a brief loading indicator
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Switched to $_selectedCampus'),
                        duration: const Duration(seconds: 2),
                        backgroundColor: AppTheme.accentColor,
                      ),
                    );
                  }
                }
              },
              underline: Container(),
              dropdownColor: AppTheme.cardColor,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: AppTheme.cardColor,
      actions: [
        // Live Status Indicator
        Consumer<EnergyDataProvider>(
          builder: (context, dataProvider, child) {
            return Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: dataProvider.isConnected ? Colors.green.withAlpha(51) : Colors.red.withAlpha(51),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: dataProvider.isConnected ? Colors.green : Colors.red),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: dataProvider.isConnected ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dataProvider.isConnected ? 'LIVE' : 'OFFLINE',
                    style: TextStyle(
                      color: dataProvider.isConnected ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        // Quick Action Icons
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {},
          tooltip: 'Notifications',
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () => _showSettingsDialog(),
          tooltip: 'Settings',
        ),
        IconButton(
          icon: const Icon(Icons.account_circle_outlined, color: Colors.white),
          onPressed: () => _showProfileDialog(),
          tooltip: 'Profile',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildEnhancedDashboard() {
    return RefreshIndicator(
      onRefresh: () => Provider.of<EnergyDataProvider>(context, listen: false).refreshCurrentData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campus Info Banner
            _buildCampusBanner(),
            const SizedBox(height: 16),
            
            // Main Overview Section - Four Enhanced KPI Cards
            const EnhancedDashboardCards(),
            const SizedBox(height: 24),
            
            // Real-time Energy Analytics Graph Section
            _buildAnalyticsSection(),
            const SizedBox(height: 24),
            
            // Energy Source Distribution and AI Forecast Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Energy Mix Pie Chart
                const Expanded(
                  flex: 1,
                  child: EnergyMixPieChart(),
                ),
                const SizedBox(width: 16),
                // AI Forecast & Optimization
                const Expanded(
                  flex: 2,
                  child: AIForecastSection(),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCampusBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.accentColor.withAlpha(51), AppTheme.accentColor.withAlpha(26)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentColor.withAlpha(77)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: AppTheme.accentColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedCampus,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Hybrid Renewable Energy System • Rajasthan, India',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(51),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Active',
              style: TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Real-time Energy Flow (Last 24 Hours)',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.accentColor,
          ),
        ),
        const SizedBox(height: 16),
        const MultiLineEnergyChart(),
      ],
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
  
  void _showProfileDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const ProfileDialog(
        user: UserProfile.defaultUser,
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const SettingsDialog(),
    );
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
