import 'dart:math';

class Formatters {
  // Private constructor to prevent instantiation
  Formatters._();

  /// Format power values with appropriate units (W, kW, MW)
  static String formatPower(double watts) {
    if (watts.isNaN || watts.isInfinite) return '0';
    
    final absWatts = watts.abs();
    final sign = watts < 0 ? '-' : '';
    
    if (absWatts >= 1000000) {
      return '$sign${(absWatts / 1000000).toStringAsFixed(2)}M';
    } else if (absWatts >= 1000) {
      return '$sign${(absWatts / 1000).toStringAsFixed(1)}k';
    } else {
      return '$sign${absWatts.toStringAsFixed(0)}';
    }
  }

  /// Format energy values with appropriate units (Wh, kWh, MWh)
  static String formatEnergy(double wattHours) {
    if (wattHours.isNaN || wattHours.isInfinite) return '0';
    
    final absWh = wattHours.abs();
    final sign = wattHours < 0 ? '-' : '';
    
    if (absWh >= 1000000) {
      return '$sign${(absWh / 1000000).toStringAsFixed(2)} MWh';
    } else if (absWh >= 1000) {
      return '$sign${(absWh / 1000).toStringAsFixed(1)} kWh';
    } else {
      return '$sign${absWh.toStringAsFixed(0)} Wh';
    }
  }

  /// Format percentage values
  static String formatPercentage(double percentage, {int decimals = 1}) {
    if (percentage.isNaN || percentage.isInfinite) return '0%';
    return '${percentage.toStringAsFixed(decimals)}%';
  }

  /// Format temperature values
  static String formatTemperature(double celsius, {bool showUnit = true}) {
    if (celsius.isNaN || celsius.isInfinite) return '0${showUnit ? '°C' : ''}';
    return '${celsius.toStringAsFixed(1)}${showUnit ? '°C' : ''}';
  }

  /// Format voltage values
  static String formatVoltage(double volts) {
    if (volts.isNaN || volts.isInfinite) return '0V';
    
    if (volts >= 1000) {
      return '${(volts / 1000).toStringAsFixed(2)} kV';
    } else {
      return '${volts.toStringAsFixed(1)} V';
    }
  }

  /// Format frequency values
  static String formatFrequency(double hertz) {
    if (hertz.isNaN || hertz.isInfinite) return '0 Hz';
    return '${hertz.toStringAsFixed(2)} Hz';
  }

  /// Format wind speed values
  static String formatWindSpeed(double metersPerSecond) {
    if (metersPerSecond.isNaN || metersPerSecond.isInfinite) return '0 m/s';
    return '${metersPerSecond.toStringAsFixed(1)} m/s';
  }

  /// Format irradiance values
  static String formatIrradiance(double wattsPerSquareMeter) {
    if (wattsPerSquareMeter.isNaN || wattsPerSquareMeter.isInfinite) return '0 W/m²';
    return '${wattsPerSquareMeter.toStringAsFixed(0)} W/m²';
  }

  /// Format pressure values
  static String formatPressure(double pascals) {
    if (pascals.isNaN || pascals.isInfinite) return '0 Pa';
    
    if (pascals >= 100000) {
      return '${(pascals / 100000).toStringAsFixed(2)} bar';
    } else if (pascals >= 1000) {
      return '${(pascals / 1000).toStringAsFixed(1)} kPa';
    } else {
      return '${pascals.toStringAsFixed(0)} Pa';
    }
  }

  /// Format humidity values
  static String formatHumidity(double percentage) {
    if (percentage.isNaN || percentage.isInfinite) return '0%';
    return '${percentage.toStringAsFixed(0)}%';
  }

  /// Format large numbers with appropriate suffixes
  static String formatNumber(double number) {
    if (number.isNaN || number.isInfinite) return '0';
    
    final absNumber = number.abs();
    final sign = number < 0 ? '-' : '';
    
    if (absNumber >= 1000000000) {
      return '$sign${(absNumber / 1000000000).toStringAsFixed(1)}B';
    } else if (absNumber >= 1000000) {
      return '$sign${(absNumber / 1000000).toStringAsFixed(1)}M';
    } else if (absNumber >= 1000) {
      return '$sign${(absNumber / 1000).toStringAsFixed(1)}K';
    } else {
      return '$sign${absNumber.toStringAsFixed(0)}';
    }
  }

  /// Format duration in human-readable format
  static String formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (days > 0) {
      return '${days}d ${hours}h';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Format timestamp relative to now
  static String formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  /// Format date and time
  static String formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
           '${dateTime.month.toString().padLeft(2, '0')}/'
           '${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Format time only
  static String formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}:'
           '${dateTime.second.toString().padLeft(2, '0')}';
  }

  /// Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Format coordinates
  static String formatCoordinates(double latitude, double longitude) {
    final latDirection = latitude >= 0 ? 'N' : 'S';
    final lonDirection = longitude >= 0 ? 'E' : 'W';
    
    return '${latitude.abs().toStringAsFixed(4)}°$latDirection, '
           '${longitude.abs().toStringAsFixed(4)}°$lonDirection';
  }

  /// Format wind direction from degrees to compass
  static String formatWindDirection(int degrees) {
    const directions = [
      'N', 'NNE', 'NE', 'ENE',
      'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW',
      'W', 'WNW', 'NW', 'NNW'
    ];
    
    final index = ((degrees + 11.25) / 22.5).floor() % 16;
    return directions[index];
  }

  /// Format efficiency as percentage with color coding info
  static String formatEfficiency(double efficiency) {
    if (efficiency.isNaN || efficiency.isInfinite) return '0%';
    return '${efficiency.toStringAsFixed(1)}%';
  }

  /// Get efficiency status based on percentage
  static String getEfficiencyStatus(double efficiency) {
    if (efficiency >= 90) return 'Excellent';
    if (efficiency >= 75) return 'Good';
    if (efficiency >= 60) return 'Fair';
    if (efficiency >= 40) return 'Poor';
    return 'Critical';
  }

  /// Format currency (assuming USD for now)
  static String formatCurrency(double amount, {String symbol = '\$'}) {
    if (amount.isNaN || amount.isInfinite) return '$symbol 0.00';
    return '$symbol ${amount.toStringAsFixed(2)}';
  }

  /// Round to significant figures
  static double roundToSignificantFigures(double value, int significantFigures) {
    if (value == 0) return 0;
    
    final magnitude = pow(10, significantFigures - (log(value.abs()) / ln10).floor() - 1);
    return (value * magnitude).round() / magnitude;
  }
}

/// Extension methods for convenient formatting
extension NumberFormatting on double {
  String get formatPower => Formatters.formatPower(this);
  String get formatEnergy => Formatters.formatEnergy(this);
  String get formatPercentage => Formatters.formatPercentage(this);
  String get formatTemperature => Formatters.formatTemperature(this);
  String get formatVoltage => Formatters.formatVoltage(this);
  String get formatFrequency => Formatters.formatFrequency(this);
  String get formatWindSpeed => Formatters.formatWindSpeed(this);
  String get formatIrradiance => Formatters.formatIrradiance(this);
  String get formatPressure => Formatters.formatPressure(this);
  String get formatHumidity => Formatters.formatHumidity(this);
  String get formatNumber => Formatters.formatNumber(this);
}

extension DateTimeFormatting on DateTime {
  String get formatTimeAgo => Formatters.formatTimeAgo(this);
  String get formatDateTime => Formatters.formatDateTime(this);
  String get formatTime => Formatters.formatTime(this);
}
