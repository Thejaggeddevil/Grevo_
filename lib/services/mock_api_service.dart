import 'dart:async';
import 'dart:math';

import '../models/campus.dart';
import '../models/energy_data.dart';
import 'api_base.dart';

class MockApiService implements ApiBase {
  // In-memory mock data
  final List<Campus> _campuses = [
    Campus(
      id: 'campus-1',
      name: 'North Valley Campus',
      location: Location(
        address: '100 Greenway Blvd',
        city: 'Springfield',
        state: 'CA',
        country: 'USA',
        zipCode: '94000',
        coordinates: Coordinates(latitude: 37.7749, longitude: -122.4194),
      ),
      energySources: EnergySources(
        solar: SolarConfig(enabled: true, capacity: 8000, panels: 250),
        wind: WindConfig(enabled: true, capacity: 5000, turbines: 4),
        battery: BatteryConfig(enabled: true, capacity: 20000, maxCharge: 4000, maxDischarge: 4000),
      ),
    ),
    Campus(
      id: 'campus-2',
      name: 'Riverside Campus',
      location: Location(
        address: '200 River Rd',
        city: 'Riverton',
        state: 'TX',
        country: 'USA',
        zipCode: '73301',
        coordinates: Coordinates(latitude: 30.2672, longitude: -97.7431),
      ),
      energySources: EnergySources(
        solar: SolarConfig(enabled: true, capacity: 6000, panels: 180),
        wind: WindConfig(enabled: false, capacity: 0, turbines: 0),
        battery: BatteryConfig(enabled: true, capacity: 15000, maxCharge: 3000, maxDischarge: 3000),
      ),
    ),
    Campus(
      id: 'campus-3',
      name: 'Hilltop Campus',
      location: Location(
        address: '300 Summit Ave',
        city: 'Highlands',
        state: 'CO',
        country: 'USA',
        zipCode: '80014',
        coordinates: Coordinates(latitude: 39.7392, longitude: -104.9903),
      ),
      energySources: EnergySources(
        solar: SolarConfig(enabled: false, capacity: 0, panels: 0),
        wind: WindConfig(enabled: true, capacity: 7000, turbines: 6),
        battery: BatteryConfig(enabled: false, capacity: 0),
      ),
    ),
  ];

  final Random _rng = Random(42);

  @override
  Future<List<Campus>> getCampuses() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return _campuses;
  }

  @override
  Future<Campus> getCampusById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _campuses.firstWhere((c) => c.id == id, orElse: () => _campuses.first);
  }

  @override
  Future<List<EnergyData>> getEnergyData({
    String? campusId,
    DateTime? startTime,
    DateTime? endTime,
    int limit = 100,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final id = campusId ?? _campuses.first.id;
    final start = startTime ?? DateTime.now().subtract(const Duration(hours: 1));
    final end = endTime ?? DateTime.now();

    // Generate data points at 5-minute intervals
    final step = const Duration(minutes: 5);
    final points = <EnergyData>[];
    var t = start;
    while (t.isBefore(end) && points.length < limit) {
      points.add(_generateEnergyData(id, t));
      t = t.add(step);
    }

    if (points.isEmpty) {
      points.add(_generateEnergyData(id, end));
    }

    return points;
  }

  @override
  Future<EnergyData?> getLatestEnergyData(String campusId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _generateEnergyData(campusId, DateTime.now());
  }

  @override
  Future<List<Map<String, dynamic>>> getEnergyDataAggregated({
    required String campusId,
    required DateTime startTime,
    required DateTime endTime,
    String interval = 'hour',
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final data = await getEnergyData(
      campusId: campusId,
      startTime: startTime,
      endTime: endTime,
      limit: 500,
    );

    // Very simple aggregation per 1 hour bucket
    final buckets = <int, List<EnergyData>>{};
    for (final d in data) {
      final hourKey = DateTime(d.timestamp.year, d.timestamp.month, d.timestamp.day, d.timestamp.hour)
          .millisecondsSinceEpoch;
      buckets.putIfAbsent(hourKey, () => []).add(d);
    }

    final result = <Map<String, dynamic>>[];
    buckets.forEach((key, values) {
      final avg = _average(values);
      result.add({
        'timestamp': DateTime.fromMillisecondsSinceEpoch(key).toIso8601String(),
        'solar': avg.solar.generation,
        'wind': avg.wind.generation,
        'load': avg.load.total,
        'battery': avg.battery.power,
      });
    });

    result.sort((a, b) => (a['timestamp'] as String).compareTo(b['timestamp'] as String));
    return result;
  }

  @override
  Future<bool> isServerHealthy() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return true;
  }

  @override
  Future<Map<String, dynamic>> getServerStatus() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return {
      'status': 'ok',
      'uptime': 123456,
      'version': 'mock-1.0',
    };
  }

  @override
  void dispose() {}

  EnergyData _generateEnergyData(String campusId, DateTime timestamp) {
    final campus = _campuses.firstWhere((c) => c.id == campusId, orElse: () => _campuses.first);
    final timeOfDay = timestamp.hour + timestamp.minute / 60.0;

    // Solar: peak at midday
    double solarPeak = campus.energySources.solar.enabled ? campus.energySources.solar.capacity : 0;
    final solarGen = max(0.0,
        solarPeak * sin((pi * (timeOfDay - 6)) / 12).clamp(0, 1).toDouble() + _noise(0.05, solarPeak));

    // Wind: random-ish with baseline
    double windCap = campus.energySources.wind.enabled ? campus.energySources.wind.capacity : 0;
    final windGen = max(0.0, (windCap * 0.4 + _noise(0.2, windCap)).clamp(0, windCap));

    // Load: base plus daily cycle
    final baseLoad = 6000 + _rng.nextInt(2000);
    final load = baseLoad + 2000 * sin((pi * (timeOfDay - 8)) / 12).abs() + _rng.nextInt(400);

    // Battery: tries to balance difference
    double balance = (solarGen + windGen) - load;
    double batteryPower = 0;
    if (campus.energySources.battery.enabled) {
      final bdMax = campus.energySources.battery.maxDischarge ?? 3000;
      final bcMax = campus.energySources.battery.maxCharge ?? 3000;
      if (balance < -200) {
        // Discharge
        batteryPower = min(bdMax, -balance.abs());
      } else if (balance > 200) {
        // Charge (negative power denotes charging in our model)
        batteryPower = -min(bcMax, balance);
      }
    }

    final gridExport = max(0.0, (solarGen + windGen + max(0, batteryPower)) - load);
    final gridImport = max(0.0, load - (solarGen + windGen + max(0, batteryPower)));

    return EnergyData(
      campusId: campus.id,
      timestamp: timestamp,
      solar: SolarData(
        generation: solarGen.toDouble(),
        irradiance: max(0.0, 900.0 * sin((pi * (timeOfDay - 6)) / 12)),
        efficiency: 0.18 + _rng.nextDouble() * 0.05,
        temperature: 20.0 + 10.0 * sin((pi * (timeOfDay - 6)) / 12),
      ),
      wind: WindData(
        generation: windGen.toDouble(),
        speed: 3.0 + _rng.nextDouble() * 7.0,
        direction: _rng.nextInt(360),
        temperature: 20.0 + _rng.nextDouble() * 5.0,
      ),
      battery: BatteryData(
        soc: 50.0 + 30.0 * sin(timestamp.millisecondsSinceEpoch / 1e7),
        power: batteryPower,
        voltage: 400.0 + _rng.nextDouble() * 20.0,
        temperature: 25.0 + _rng.nextDouble() * 5.0,
        capacity: campus.energySources.battery.capacity,
        cycles: 500 + _rng.nextInt(100),
      ),
      grid: GridData(
        import: gridImport,
        export: gridExport,
        frequency: 50.0 + _rng.nextDouble() * 0.2,
        voltage: 230.0 + _rng.nextDouble() * 5.0,
        powerFactor: 0.95 + _rng.nextDouble() * 0.05,
      ),
      load: LoadData(
        total: load.toDouble(),
        critical: (load * 0.4).toDouble(),
        nonCritical: (load * 0.6).toDouble(),
      ),
      weather: WeatherData(
        temperature: 20.0 + 10.0 * sin((pi * (timeOfDay - 6)) / 12),
        humidity: 40.0 + _rng.nextDouble() * 40.0,
        pressure: 101325.0 + _rng.nextDouble() * 500.0,
        windSpeed: 3.0 + _rng.nextDouble() * 7.0,
        cloudCover: (100 * (1 - sin((pi * (timeOfDay - 6)) / 12).abs())).toInt(),
      ),
      source: 'mock',
    );
  }

  EnergyData _average(List<EnergyData> items) {
    double solar = 0, wind = 0, load = 0, battery = 0;
    for (final i in items) {
      solar += i.solar.generation;
      wind += i.wind.generation;
      load += i.load.total;
      battery += i.battery.power;
    }
    final n = items.length.toDouble();
    return EnergyData(
      campusId: items.first.campusId,
      timestamp: items.first.timestamp,
      solar: SolarData(
        generation: solar / n,
        irradiance: items.first.solar.irradiance,
        efficiency: items.first.solar.efficiency,
        temperature: items.first.solar.temperature,
      ),
      wind: WindData(
        generation: wind / n,
        speed: items.first.wind.speed,
        direction: items.first.wind.direction,
        temperature: items.first.wind.temperature,
      ),
      battery: BatteryData(
        soc: items.first.battery.soc,
        power: battery / n,
        voltage: items.first.battery.voltage,
        temperature: items.first.battery.temperature,
        capacity: items.first.battery.capacity,
        cycles: items.first.battery.cycles,
      ),
      grid: GridData(
        import: items.first.grid.import,
        export: items.first.grid.export,
        frequency: items.first.grid.frequency,
        voltage: items.first.grid.voltage,
        powerFactor: items.first.grid.powerFactor,
      ),
      load: LoadData(
        total: load / n,
        critical: items.first.load.critical,
        nonCritical: items.first.load.nonCritical,
      ),
      weather: items.first.weather,
      source: 'mock-agg',
    );
  }

  double _noise(double fraction, double base) {
    return (base * fraction) * (_rng.nextDouble() - 0.5);
  }
}

final mockApiService = MockApiService();
