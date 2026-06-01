import 'package:flutter/material.dart';

import '../../worlds/domain/world_model.dart';
import '../../../core/ffi/cubiomes_finders.dart' show StructureType;
import 'map_painter.dart' show StructureMark;

import 'structure_ui_helpers.dart';

class MapOverlayPainter extends CustomPainter {
  final Matrix4 transform;
  final double centerOffset;
  
  final List<Waypoint> waypoints;
  final List<Waypoint> translucidWaypoints;
  final Offset? spawnPos;
  final List<StructureMark> structures;

  // --- STATIC CACHES FOR PERFORMANCE ---
  static final Map<int, TextPainter> _iconPainterCache = {};
  
  static TextPainter _getIconPainter(IconData icon, Color iconColor, double fontSize) {
    // Hash key based on icon codepoint, color value, and font size
    final int hash = Object.hash(icon.codePoint, iconColor.value, fontSize);
    if (!_iconPainterCache.containsKey(hash)) {
      final painter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            color: iconColor,
            fontSize: fontSize,
            fontFamily: icon.fontFamily,
            package: icon.fontPackage,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      painter.layout();
      _iconPainterCache[hash] = painter;
    }
    return _iconPainterCache[hash]!;
  }
  // ------------------------------------

  MapOverlayPainter({
    required this.transform,
    required this.centerOffset,
    this.waypoints = const [],
    this.translucidWaypoints = const [],
    this.spawnPos,
    this.structures = const [],
    this.selectedMarkerPos,
    this.magnetProgress = 0.0,
  });

  final Offset? selectedMarkerPos;
  final double magnetProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect screenRect = Offset.zero & size;
    final Offset centerScreen = Offset(size.width / 2, size.height / 2);

    // Coordinate conversions
    Offset toScreen(double worldX, double worldY) {
      // worldX and worldY are block coordinates
      worldX = centerOffset + (worldX / 4.0);
      worldY = centerOffset + (worldY / 4.0);
      return MatrixUtils.transformPoint(transform, Offset(worldX, worldY));
    }

    // Helper to draw a perfectly centered bubble marker
    void drawMarker(Offset screenPos, Color color, IconData icon, {double size = 28.0, double iconSize = 18.0, double borderWidth = 0.0, bool isTranslucid = false}) {
      canvas.save();
      canvas.translate(screenPos.dx, screenPos.dy);

      final double opacity = isTranslucid ? 0.4 : 1.0;

      // Shadow
      final shadowPaint = Paint()..color = Colors.black45.withOpacity(isTranslucid ? 0.2 : 0.45)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
      canvas.drawCircle(const Offset(1, 2), size / 2, shadowPaint);

      // Border
      if (borderWidth > 0) {
         final borderPaint = Paint()..color = Colors.white.withOpacity(opacity)..style = PaintingStyle.fill;
         canvas.drawCircle(Offset.zero, (size / 2) + borderWidth, borderPaint);
      }

      // Background
      final bgPaint = Paint()..color = color.withOpacity(opacity)..style = PaintingStyle.fill;
      canvas.drawCircle(Offset.zero, size / 2, bgPaint);
      
      // Icon
      final Color baseIconColor = color.computeLuminance() > 0.7 ? Colors.black87 : Colors.white;
      final Color iconColor = baseIconColor.withOpacity(opacity);
      
      final fgPainter = _getIconPainter(icon, iconColor, iconSize);
      fgPainter.paint(canvas, Offset(-fgPainter.width / 2, -fgPainter.height / 2));
      
      canvas.restore();
    }

    final double scale = transform.getMaxScaleOnAxis();

    // 1. Draw Structures
    for (var struct in structures) {
      final screenPos = toScreen(struct.pos.dx, struct.pos.dy);
      
      if (selectedMarkerPos != null && struct.pos == selectedMarkerPos) {
        if (magnetProgress < 1.0) {
           final double t = Curves.easeInOut.transform(magnetProgress);
           final Offset animatedPos = Offset.lerp(screenPos, centerScreen, t)!;
           final Color color = StructureUiHelper.getColor(struct.type);
           final IconData icon = StructureUiHelper.getIcon(struct.type);
           
           drawMarker(animatedPos, color, icon);
        }
        continue;
      }
      if (!screenRect.inflate(50).contains(screenPos)) continue;
      
      final bool isDense = StructureType.getRegionSize(struct.type) <= 1;
      
      // LOD Level 2: Complete Culling
      if (isDense && scale < 0.2) continue;

      final Color color = StructureUiHelper.getColor(struct.type);

      // LOD Level 1: Simple Dot Rendering
      if (isDense && scale < 0.8) {
        final Paint dotPaint = Paint()..color = color..style = PaintingStyle.fill;
        canvas.drawCircle(screenPos, 4.0 * scale.clamp(0.5, 1.0), dotPaint);
        continue;
      }
      
      final IconData icon = StructureUiHelper.getIcon(struct.type);
      drawMarker(screenPos, color, icon);
    }

    // 2. Draw Translucid Waypoints (behind normal waypoints)
    for (var wp in translucidWaypoints) {
      final Offset wpPos = Offset(wp.x.toDouble(), wp.z.toDouble());
      final screenPos = toScreen(wpPos.dx, wpPos.dy);

      if (!screenRect.inflate(50).contains(screenPos)) continue;
      
      drawMarker(screenPos, Color(wp.color), Icons.flag, isTranslucid: true);
    }

    // 3. Draw Normal Waypoints
    for (var wp in waypoints) {
      final Offset wpPos = Offset(wp.x.toDouble(), wp.z.toDouble());
      final screenPos = toScreen(wpPos.dx, wpPos.dy);

      if (selectedMarkerPos != null && wpPos == selectedMarkerPos) {
        if (magnetProgress < 1.0) {
           final double t = Curves.easeInOut.transform(magnetProgress);
           final Offset animatedPos = Offset.lerp(screenPos, centerScreen, t)!;
           
           drawMarker(animatedPos, Color(wp.color), Icons.flag);
        }
        continue;
      }

      if (!screenRect.inflate(50).contains(screenPos)) continue;
      
      drawMarker(screenPos, Color(wp.color), Icons.flag);
    }

    // 4. Draw Spawn (Highest priority, draw last so it's on top)
    if (spawnPos != null) {
      final screenPos = toScreen(spawnPos!.dx, spawnPos!.dy);
      
      if (selectedMarkerPos != null && spawnPos == selectedMarkerPos) {
        if (magnetProgress < 1.0) {
           final double t = Curves.easeInOut.transform(magnetProgress);
           final Offset animatedPos = Offset.lerp(screenPos, centerScreen, t)!;
           
           drawMarker(animatedPos, Colors.redAccent, Icons.star);
        }
      } else if (screenRect.inflate(50).contains(screenPos)) {
        drawMarker(screenPos, Colors.redAccent, Icons.star);
      }
    }
  }

  @override
  bool shouldRepaint(covariant MapOverlayPainter oldDelegate) {
    return oldDelegate.transform != transform ||
           oldDelegate.waypoints != waypoints ||
           oldDelegate.translucidWaypoints != translucidWaypoints ||
           oldDelegate.spawnPos != spawnPos ||
           oldDelegate.structures != structures;
  }
}
