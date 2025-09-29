import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/energy_data_provider.dart';
import '../providers/theme_provider.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    // Wait for theme to load
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    while (themeProvider.isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Wait minimum splash time and for data provider to initialize
    await Future.wait([
      Future.delayed(const Duration(seconds: 3)),
      _waitForDataInitialization(),
    ]);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    }
  }

  Future<void> _waitForDataInitialization() async {
    final dataProvider = Provider.of<EnergyDataProvider>(context, listen: false);
    
    // Wait for initial data loading to complete (either success or error)
    int attempts = 0;
    while (dataProvider.isLoading && attempts < 30) { // Max 15 seconds
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Consumer<EnergyDataProvider>(
        builder: (context, dataProvider, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo and App Name
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          children: [
                            // App Icon
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.secondary,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.energy_savings_leaf,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // App Name
                            Text(
                              'Grevo',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Tagline
                            Text(
                              'Renewable Energy Management',
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 80),
                
                // Loading Indicator and Status
                Column(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Status Text
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _getStatusText(dataProvider),
                        key: ValueKey(_getStatusText(dataProvider)),
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                
                // Error Message (if any)
                if (dataProvider.error != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.error.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_rounded,
                          color: theme.colorScheme.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Connection issue: ${dataProvider.error}',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _getStatusText(EnergyDataProvider dataProvider) {
    if (dataProvider.error != null) {
      return 'Connecting to server...';
    } else if (dataProvider.isLoading) {
      return 'Loading campus data...';
    } else if (!dataProvider.isConnected) {
      return 'Establishing real-time connection...';
    } else {
      return 'Initializing dashboard...';
    }
  }
}