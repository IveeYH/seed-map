import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../worlds/domain/world_model.dart';

class StructureMark {
  final Offset pos;
  final int type;
  StructureMark(this.pos, this.type);
}

class MapPainter extends CustomPainter {
  final Map<String, ui.Image> tiles;
  final double centerOffset;
  final int tileSize;
  
  final List<Waypoint> waypoints;
  final Offset? spawnPos;
  final List<StructureMark> structures;

  MapPainter({
    required this.tiles,
    required this.centerOffset,
    required this.tileSize,
    this.waypoints = const [],
    this.spawnPos,
    this.structures = const [],
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..filterQuality = FilterQuality.none; // Pixel art style, no smoothing
    
    for (var entry in tiles.entries) {
      final parts = entry.key.split('_');
      final int tx = int.parse(parts[0]);
      final int tz = int.parse(parts[1]);
      final ui.Image image = entry.value;
      
      final double x = centerOffset + tx * tileSize;
      final double y = centerOffset + tz * tileSize;
      
      canvas.drawImage(image, Offset(x, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) {
    return true;
  }
}
