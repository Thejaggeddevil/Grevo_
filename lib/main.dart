import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/energy_data_provider.dart';
import 'screens/splash_screen.dart';
import 'services/logging_service.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logging service
  await LoggingService.instance.initialize();
  await logInfo('Main', 'Application starting...');

  // Set up global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    logError(
      'FlutterError',
      'Unhandled Flutter error: ${details.exception}',
      details.exception,
      details.stack,
    );
    
    // In debug mode, also use the default error handler
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  };

  // Handle platform-specific errors
  PlatformDispatcher.instance.onError = (error, stack) {
    logFatal('Platform', 'Unhandled platform error: $error', error, stack);
    return true;
  };

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const GrevoApp());
}

class GrevoApp extends StatelessWidget {
  const GrevoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => EnergyDataProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Grevo - Renewable Energy Management',
            debugShowCheckedModeBanner: false,
            theme: ThemeProvider.lightTheme,
            darkTheme: ThemeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
            builder: (context, child) {
              final textScaleFactor = MediaQuery.textScalerOf(context).scale(1.0);
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(textScaleFactor.clamp(0.8, 1.2)),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
