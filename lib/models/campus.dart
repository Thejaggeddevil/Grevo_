class Campus {
  final String id;
  final String name;
  final Location location;
  final EnergySources energySources;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Campus({
    required this.id,
    required this.name,
    required this.location,
    required this.energySources,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Campus.fromJson(Map<String, dynamic> json) {
    return Campus(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      location: Location.fromJson(json['location'] ?? {}),
      energySources: EnergySources.fromJson(json['energySources'] ?? {}),
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString()) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location.toJson(),
      'energySources': energySources.toJson(),
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Campus copyWith({
    String? id,
    String? name,
    Location? location,
    EnergySources? energySources,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Campus(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      energySources: energySources ?? this.energySources,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class Location {
  final Coordinates coordinates;

  Location({required this.coordinates});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      coordinates: Coordinates.fromJson(json['coordinates'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coordinates': coordinates.toJson(),
    };
  }
}

class Coordinates {
  final double latitude;
  final double longitude;

  Coordinates({
    required this.latitude,
    required this.longitude,
  });

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class EnergySources {
  final SolarConfig solar;
  final WindConfig wind;
  final BatteryConfig battery;

  EnergySources({
    required this.solar,
    required this.wind,
    required this.battery,
  });

  factory EnergySources.fromJson(Map<String, dynamic> json) {
    return EnergySources(
      solar: SolarConfig.fromJson(json['solar'] ?? {}),
      wind: WindConfig.fromJson(json['wind'] ?? {}),
      battery: BatteryConfig.fromJson(json['battery'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'solar': solar.toJson(),
      'wind': wind.toJson(),
      'battery': battery.toJson(),
    };
  }
}

class SolarConfig {
  final double capacity;
  final int panels;

  SolarConfig({
    required this.capacity,
    required this.panels,
  });

  factory SolarConfig.fromJson(Map<String, dynamic> json) {
    return SolarConfig(
      capacity: (json['capacity'] ?? 0.0).toDouble(),
      panels: json['panels'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'capacity': capacity,
      'panels': panels,
    };
  }
}

class WindConfig {
  final double capacity;
  final int turbines;

  WindConfig({
    required this.capacity,
    required this.turbines,
  });

  factory WindConfig.fromJson(Map<String, dynamic> json) {
    return WindConfig(
      capacity: (json['capacity'] ?? 0.0).toDouble(),
      turbines: json['turbines'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'capacity': capacity,
      'turbines': turbines,
    };
  }
}

class BatteryConfig {
  final double capacity;
  final double maxCharge;
  final double maxDischarge;

  BatteryConfig({
    required this.capacity,
    required this.maxCharge,
    required this.maxDischarge,
  });

  factory BatteryConfig.fromJson(Map<String, dynamic> json) {
    return BatteryConfig(
      capacity: (json['capacity'] ?? 0.0).toDouble(),
      maxCharge: (json['maxCharge'] ?? 0.0).toDouble(),
      maxDischarge: (json['maxDischarge'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'capacity': capacity,
      'maxCharge': maxCharge,
      'maxDischarge': maxDischarge,
    };
  }
}