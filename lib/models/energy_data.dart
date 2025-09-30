class EnergyData {
  final String campusId;
  final DateTime timestamp;
  final SolarData solar;
  final WindData wind;
  final BatteryData battery;
  final GridData grid;
  final LoadData load;
  final WeatherData weather;
  final String source;

  EnergyData({
    required this.campusId,
    required this.timestamp,
    required this.solar,
    required this.wind,
    required this.battery,
    required this.grid,
    required this.load,
    required this.weather,
    required this.source,
  });

  factory EnergyData.fromJson(Map<String, dynamic> json) {
    return EnergyData(
      campusId: json['campusId'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
      solar: SolarData.fromJson(json['solar'] ?? {}),
      wind: WindData.fromJson(json['wind'] ?? {}),
      battery: BatteryData.fromJson(json['battery'] ?? {}),
      grid: GridData.fromJson(json['grid'] ?? {}),
      load: LoadData.fromJson(json['load'] ?? {}),
      weather: WeatherData.fromJson(json['weather'] ?? {}),
      source: json['source'] ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'campusId': campusId,
      'timestamp': timestamp.toIso8601String(),
      'solar': solar.toJson(),
      'wind': wind.toJson(),
      'battery': battery.toJson(),
      'grid': grid.toJson(),
      'load': load.toJson(),
      'weather': weather.toJson(),
      'source': source,
    };
  }

  EnergyData copyWith({
    String? campusId,
    DateTime? timestamp,
    SolarData? solar,
    WindData? wind,
    BatteryData? battery,
    GridData? grid,
    LoadData? load,
    WeatherData? weather,
    String? source,
  }) {
    return EnergyData(
      campusId: campusId ?? this.campusId,
      timestamp: timestamp ?? this.timestamp,
      solar: solar ?? this.solar,
      wind: wind ?? this.wind,
      battery: battery ?? this.battery,
      grid: grid ?? this.grid,
      load: load ?? this.load,
      weather: weather ?? this.weather,
      source: source ?? this.source,
    );
  }
}

class SolarData {
  final double generation;
  final double irradiance;
  final double efficiency;
  final double temperature;

  SolarData({
    required this.generation,
    required this.irradiance,
    required this.efficiency,
    required this.temperature,
  });

  factory SolarData.fromJson(Map<String, dynamic> json) {
    return SolarData(
      generation: (json['generation'] ?? 0.0).toDouble(),
      irradiance: (json['irradiance'] ?? 0.0).toDouble(),
      efficiency: (json['efficiency'] ?? 0.0).toDouble(),
      temperature: (json['temperature'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'generation': generation,
      'irradiance': irradiance,
      'efficiency': efficiency,
      'temperature': temperature,
    };
  }
}

class WindData {
  final double generation;
  final double speed;
  final int direction;
  final double temperature;

  WindData({
    required this.generation,
    required this.speed,
    required this.direction,
    required this.temperature,
  });

  factory WindData.fromJson(Map<String, dynamic> json) {
    return WindData(
      generation: (json['generation'] ?? 0.0).toDouble(),
      speed: (json['speed'] ?? 0.0).toDouble(),
      direction: json['direction'] ?? 0,
      temperature: (json['temperature'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'generation': generation,
      'speed': speed,
      'direction': direction,
      'temperature': temperature,
    };
  }
}

class BatteryData {
  final double soc;
  final double power;
  final double voltage;
  final double temperature;
  final double capacity;
  final int cycles;

  BatteryData({
    required this.soc,
    required this.power,
    required this.voltage,
    required this.temperature,
    required this.capacity,
    required this.cycles,
  });

  factory BatteryData.fromJson(Map<String, dynamic> json) {
    return BatteryData(
      soc: (json['soc'] ?? 0.0).toDouble(),
      power: (json['power'] ?? 0.0).toDouble(),
      voltage: (json['voltage'] ?? 0.0).toDouble(),
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      capacity: (json['capacity'] ?? 0.0).toDouble(),
      cycles: json['cycles'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'soc': soc,
      'power': power,
      'voltage': voltage,
      'temperature': temperature,
      'capacity': capacity,
      'cycles': cycles,
    };
  }
}

class GridData {
  final double import;
  final double export;
  final double frequency;
  final double voltage;
  final double powerFactor;

  GridData({
    required this.import,
    required this.export,
    required this.frequency,
    required this.voltage,
    required this.powerFactor,
  });

  factory GridData.fromJson(Map<String, dynamic> json) {
    return GridData(
      import: (json['import'] ?? 0.0).toDouble(),
      export: (json['export'] ?? 0.0).toDouble(),
      frequency: (json['frequency'] ?? 0.0).toDouble(),
      voltage: (json['voltage'] ?? 0.0).toDouble(),
      powerFactor: (json['powerFactor'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'import': import,
      'export': export,
      'frequency': frequency,
      'voltage': voltage,
      'powerFactor': powerFactor,
    };
  }
}

class LoadData {
  final double total;
  final double critical;
  final double nonCritical;

  LoadData({
    required this.total,
    required this.critical,
    required this.nonCritical,
  });

  factory LoadData.fromJson(Map<String, dynamic> json) {
    return LoadData(
      total: (json['total'] ?? 0.0).toDouble(),
      critical: (json['critical'] ?? 0.0).toDouble(),
      nonCritical: (json['nonCritical'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'critical': critical,
      'nonCritical': nonCritical,
    };
  }
}

class WeatherData {
  final double temperature;
  final double humidity;
  final double pressure;
  final double windSpeed;
  final int cloudCover;

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.cloudCover,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      humidity: (json['humidity'] ?? 0.0).toDouble(),
      pressure: (json['pressure'] ?? 0.0).toDouble(),
      windSpeed: (json['windSpeed'] ?? 0.0).toDouble(),
      cloudCover: json['cloudCover'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'pressure': pressure,
      'windSpeed': windSpeed,
      'cloudCover': cloudCover,
    };
  }
}
