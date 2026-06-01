import 'dart:convert';

class Waypoint {
  final String id;
  final String name;
  final int x;
  final int z;
  final int color;
  final int dimension; // 0 = Overworld, -1 = Nether, 1 = End

  Waypoint({
    required this.id,
    required this.name,
    required this.x,
    required this.z,
    required this.color,
    this.dimension = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'x': x,
      'z': z,
      'color': color,
      'dimension': dimension,
    };
  }

  factory Waypoint.fromMap(Map<String, dynamic> map) {
    return Waypoint(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      x: map['x']?.toInt() ?? 0,
      z: map['z']?.toInt() ?? 0,
      color: map['color']?.toInt() ?? 0xFF00E676,
      dimension: map['dimension']?.toInt() ?? 0,
    );
  }
}

class World {
  final String id;
  final String name;
  final int seed;
  final int mcVersion; // Cubiomes MCVersion enum value
  final String? versionLabel; // Store user-selected label (e.g. "26.1 (Tiny Takeover)")
  final DateTime lastPlayed;
  final List<Waypoint> waypoints;
  final List<int> activeStructures;
  final String? thumbnailBase64;

  World({
    required this.id,
    required this.name,
    required this.seed,
    this.mcVersion = 26, // Default to 1.21
    this.versionLabel,
    required this.lastPlayed,
    this.waypoints = const [],
    this.activeStructures = const [],
    this.thumbnailBase64,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'seed': seed,
      'mcVersion': mcVersion,
      'versionLabel': versionLabel,
      'lastPlayed': lastPlayed.toIso8601String(),
      'waypoints': waypoints.map((x) => x.toMap()).toList(),
      'activeStructures': activeStructures,
      'thumbnailBase64': thumbnailBase64,
    };
  }

  factory World.fromMap(Map<String, dynamic> map) {
    return World(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      seed: map['seed']?.toInt() ?? 0,
      mcVersion: map['mcVersion']?.toInt() ?? 26, // Default to 1.21
      versionLabel: map['versionLabel'],
      lastPlayed: DateTime.parse(map['lastPlayed'] ?? DateTime.now().toIso8601String()),
      waypoints: map['waypoints'] != null 
          ? List<Waypoint>.from(map['waypoints']?.map((x) => Waypoint.fromMap(x)))
          : [],
      activeStructures: map['activeStructures'] != null 
          ? List<int>.from(map['activeStructures'])
          : [],
      thumbnailBase64: map['thumbnailBase64'],
    );
  }

  String toJson() => json.encode(toMap());

  factory World.fromJson(String source) => World.fromMap(json.decode(source));

  World copyWith({
    String? id,
    String? name,
    int? seed,
    int? mcVersion,
    String? versionLabel,
    DateTime? lastPlayed,
    List<Waypoint>? waypoints,
    List<int>? activeStructures,
    String? thumbnailBase64,
  }) {
    return World(
      id: id ?? this.id,
      name: name ?? this.name,
      seed: seed ?? this.seed,
      mcVersion: mcVersion ?? this.mcVersion,
      versionLabel: versionLabel ?? this.versionLabel,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      waypoints: waypoints ?? this.waypoints,
      activeStructures: activeStructures ?? this.activeStructures,
      thumbnailBase64: thumbnailBase64 ?? this.thumbnailBase64,
    );
  }
}
