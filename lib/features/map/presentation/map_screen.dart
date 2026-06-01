import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minecraft_seedwalker_mobile/l10n/app_localizations.dart';
import 'dart:ui' as ui;
import 'dart:math';

import '../../../core/ffi/biome_colors.dart';
import '../application/map_generator.dart';
import 'map_painter.dart';
import 'map_overlay_painter.dart';
import 'structure_ui_helpers.dart';
import '../../worlds/domain/world_model.dart';
import '../../worlds/data/world_repository.dart';
import '../../worlds/presentation/world_settings_dialog.dart';
import '../../../core/ffi/cubiomes_finders.dart';

class MapScreen extends StatefulWidget {
  final World world;
  final int initialDimension;
  const MapScreen({super.key, required this.world, this.initialDimension = 0});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class MapMarkerInfo {
  final Offset pos;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String? id;
  final int? originDimension;

  MapMarkerInfo(this.pos, this.title, this.subtitle, this.icon, this.color, {this.id, this.originDimension});
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final TransformationController _transformationController = TransformationController();
  final GlobalKey _mapAreaKey = GlobalKey();
  final Map<String, ui.Image> _tiles = {};
  final Map<String, bool> _loadingTiles = {};
  
  late World _currentWorld;
  final WorldRepository _worldRepo = WorldRepository();
  CubiomesFinders? _finders;
  
  ui.Offset? _spawnPos;
  final Map<String, List<StructureMark>> _tileStructures = {};
  
  final ValueNotifier<MapMarkerInfo?> _selectedMarkerNotifier = ValueNotifier(null);
  
  late AnimationController _mapAnimController;
  Animation<Matrix4>? _mapAnimation;
  
  final Set<int> _activeStructures = {-1, -2}; // Enable spawn and waypoints by default instead of a single boolean

  late int _selectedDimension; // 0 = Overworld, -1 = Nether, 1 = End
  int _selectedHeight = 320;  // 320 = Surface, 0 = Underground, -51 = Bottom

  bool _isFiltersExpanded = false;

  static const double worldSize = 100000.0;
  static const double centerOffset = worldSize / 2;
  static const int tileSize = 256;

  late AnimationController _magnetAnimController;
  MapMarkerInfo? _activeMagnetMarker;

  @override
  void initState() {
    super.initState();
    try {
      _currentWorld = widget.world;
      _finders = CubiomesFinders();
      _selectedDimension = widget.initialDimension;
      _activeStructures.addAll(_currentWorld.activeStructures);
      _transformationController.addListener(_onViewChanged);
      
      _mapAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
      _mapAnimController.addListener(() {
        if (_mapAnimation != null) {
          _transformationController.value = _mapAnimation!.value;
        }
      });

      _magnetAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
      _magnetAnimController.addListener(() {
        if (_magnetAnimController.value == 0.0 && _selectedMarkerNotifier.value == null) {
          setState(() {
            _activeMagnetMarker = null;
          });
        }
      });

      _selectedMarkerNotifier.addListener(() {
        if (_selectedMarkerNotifier.value != null) {
          _activeMagnetMarker = _selectedMarkerNotifier.value;
          _magnetAnimController.forward(from: 0);
        } else {
          _magnetAnimController.reverse();
        }
      });
      
      // Load spawn
      final sPos = _finders?.getSpawn(_currentWorld.seed, _currentWorld.mcVersion);
      if (sPos != null) {
        _spawnPos = ui.Offset(sPos.x.toDouble(), sPos.z.toDouble());
      }
      
      // Initial centering
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final RenderBox? renderBox = _mapAreaKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null) {
           final matrix = Matrix4.identity();
           // Center world
           matrix.translate(
             -(centerOffset - renderBox.size.width / 2),
             -(centerOffset - renderBox.size.height / 2)
           );
           _transformationController.value = matrix;
        }
      });
    } catch (e, stack) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("Error Fatal en MapScreen"),
            content: SingleChildScrollView(child: Text("$e\n$stack")),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cerrar"),
              )
            ],
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onViewChanged);
    _transformationController.dispose();
    _selectedMarkerNotifier.dispose();
    _mapAnimController.dispose();
    _magnetAnimController.dispose();
    super.dispose();
  }

  void _showAddWaypointDialog() {
    final RenderBox? renderBox = _mapAreaKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final Size screenSize = renderBox.size;
    final Matrix4 inverse = Matrix4.tryInvert(_transformationController.value) ?? Matrix4.identity();
    final Offset centerScreen = Offset(screenSize.width / 2, screenSize.height / 2);
    final Offset centerLocal = MatrixUtils.transformPoint(inverse, centerScreen);
    
    final int blockX = ((centerLocal.dx - centerOffset) * 4).round();
    final int blockZ = ((centerLocal.dy - centerOffset) * 4).round();
    
    final TextEditingController nameController = TextEditingController();
    int selectedColor = 0xFF10E68A; // Default to Emerald Green
    final List<int> colors = [
      0xFF10E68A, // Emerald Green
      0xFF00E5FF, // Diamond Cyan
      0xFFFF6D00, // Lava Orange
      0xFFB388FF, // Amethyst Purple
      0xFFFFD600, // Gold Yellow
      0xFFFF4081, // Rose Pink
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) {
          return AlertDialog(
            backgroundColor: Theme.of(context).dialogBackgroundColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(AppLocalizations.of(context)!.mapScreenAddWaypoint, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Coordenadas: X: $blockX, Z: $blockZ', style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.mapScreenWaypointName,
                    labelStyle: const TextStyle(color: Colors.white54),
                    enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: colors.map((c) => GestureDetector(
                    onTap: () => setStateModal(() => selectedColor = c),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Color(c),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedColor == c ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.mapScreenCancel, style: const TextStyle(color: Colors.white54)),
              ),
              TextButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isNotEmpty) {
                    final newWaypoint = Waypoint(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: name,
                      x: blockX,
                      z: blockZ,
                      color: selectedColor,
                      dimension: _selectedDimension,
                    );
                    
                    final updatedWaypoints = List<Waypoint>.from(_currentWorld.waypoints)..add(newWaypoint);
                    _currentWorld = _currentWorld.copyWith(waypoints: updatedWaypoints);
                    
                    if (!_activeStructures.contains(-2)) {
                      _activeStructures.add(-2);
                      _saveActiveStructures();
                    }
                    
                    await _worldRepo.saveWorld(_currentWorld);
                    
                    if (mounted) {
                      Navigator.pop(context);
                      setState(() {
                        _onViewChanged();
                      });
                    }
                  }
                },
                child: Text(AppLocalizations.of(context)!.mapScreenSave, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showWaypointsMenu() {
    final Set<int> selectedDimensions = {};

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final waypoints = _currentWorld.waypoints.where((w) {
            if (selectedDimensions.isEmpty) return true;
            return selectedDimensions.contains(w.dimension);
          }).toList();
          
          Widget getDimensionIcon(int dim) {
            if (dim == 0) return const Icon(Icons.public, color: Colors.green, size: 16);
            if (dim == -1) return const Icon(Icons.whatshot, color: Colors.redAccent, size: 16);
            if (dim == 1) return const Icon(Icons.nights_stay, color: Colors.deepPurple, size: 16);
            return const SizedBox.shrink();
          }
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.mapScreenWaypointList,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: Text(AppLocalizations.of(context)!.dimensionOverworld, style: const TextStyle(color: Colors.white)),
                      selected: selectedDimensions.contains(0),
                      onSelected: (val) {
                        setModalState(() {
                          if (val) selectedDimensions.add(0);
                          else selectedDimensions.remove(0);
                        });
                      },
                      selectedColor: Colors.green.withOpacity(0.3),
                      checkmarkColor: Colors.green,
                      backgroundColor: Theme.of(context).cardColor,
                    ),
                    FilterChip(
                      label: Text(AppLocalizations.of(context)!.dimensionNether, style: const TextStyle(color: Colors.white)),
                      selected: selectedDimensions.contains(-1),
                      onSelected: (val) {
                        setModalState(() {
                          if (val) selectedDimensions.add(-1);
                          else selectedDimensions.remove(-1);
                        });
                      },
                      selectedColor: Colors.redAccent.withOpacity(0.3),
                      checkmarkColor: Colors.redAccent,
                      backgroundColor: Theme.of(context).cardColor,
                    ),
                    FilterChip(
                      label: Text(AppLocalizations.of(context)!.dimensionEnd, style: const TextStyle(color: Colors.white)),
                      selected: selectedDimensions.contains(1),
                      onSelected: (val) {
                        setModalState(() {
                          if (val) selectedDimensions.add(1);
                          else selectedDimensions.remove(1);
                        });
                      },
                      selectedColor: Colors.deepPurple.withOpacity(0.3),
                      checkmarkColor: Colors.deepPurple,
                      backgroundColor: Theme.of(context).cardColor,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (waypoints.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      AppLocalizations.of(context)!.mapScreenNoWaypoints,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white54),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: waypoints.length,
                      itemBuilder: (context, index) {
                        final w = waypoints[index];
                        return ListTile(
                          leading: Icon(Icons.flag, color: Color(w.color), size: 32),
                          title: Row(
                            children: [
                              Text(w.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              getDimensionIcon(w.dimension),
                            ],
                          ),
                          subtitle: Text('X: ${w.x}  Z: ${w.z}', style: const TextStyle(color: Colors.white54, fontFamily: 'monospace')),
                          onTap: () {
                            Navigator.pop(context);
                            double targetX = w.x.toDouble();
                            double targetZ = w.z.toDouble();
                            
                            if (_selectedDimension == 0 && w.dimension == -1) {
                              targetX *= 8.0;
                              targetZ *= 8.0;
                            } else if (_selectedDimension == -1 && w.dimension == 0) {
                              targetX /= 8.0;
                              targetZ /= 8.0;
                            }
                            
                            _centerMapOn(Offset(targetX, targetZ));
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () async {
                              final originalIndex = _currentWorld.waypoints.indexWhere((ow) => ow.id == w.id);
                              if (originalIndex >= 0) {
                                final updatedWaypoints = List<Waypoint>.from(_currentWorld.waypoints)..removeAt(originalIndex);
                                _currentWorld = _currentWorld.copyWith(waypoints: updatedWaypoints);
                                await _worldRepo.saveWorld(_currentWorld);
                                
                                setModalState(() {}); // Refresh modal
                                setState(() { // Refresh map
                                  _onViewChanged();
                                });
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        }
      ),
    );
  }

  List<int> _getStructuresForDimension(int dimension) {
    if (dimension == 0) {
      // Overworld
      return [
        -1, // Spawn Point
        -2, // Waypoints
        StructureType.Desert_Pyramid,
        StructureType.Jungle_Temple,
        StructureType.Swamp_Hut,
        StructureType.Igloo,
        StructureType.Village,
        StructureType.Ocean_Ruin,
        StructureType.Shipwreck,
        StructureType.Monument,
        StructureType.Mansion,
        StructureType.Outpost,
        StructureType.Ruined_Portal,
        StructureType.Ancient_City,
        StructureType.Treasure,
        StructureType.Mineshaft,
        StructureType.Desert_Well,
        StructureType.Geode,
        StructureType.Trail_Ruins,
        StructureType.Trial_Chamber,
      ];
    } else if (dimension == -1) {
      // Nether
      return [
        -1, // Spawn Point
        -2, // Waypoints
        StructureType.Ruined_Portal,
        StructureType.Fortress,
        StructureType.Bastion,
      ];
    } else {
      // End
      return [
        -1, // Spawn Point
        -2, // Waypoints
        StructureType.End_City,
        StructureType.End_Gateway,
      ];
    }
  }

  Future<void> _saveActiveStructures() async {
    _currentWorld = _currentWorld.copyWith(activeStructures: _activeStructures.toList());
    await _worldRepo.saveWorld(_currentWorld);
  }

  void _onViewChanged() {
    final RenderBox? renderBox = _mapAreaKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final Size screenSize = renderBox.size;
    final Matrix4 matrix = _transformationController.value;
    final Matrix4 inverse = Matrix4.tryInvert(matrix) ?? Matrix4.identity();
    
    final Offset topLeft = MatrixUtils.transformPoint(inverse, Offset.zero);
    final Offset bottomRight = MatrixUtils.transformPoint(inverse, Offset(screenSize.width, screenSize.height));
    final Offset centerScreen = Offset(screenSize.width / 2, screenSize.height / 2);
    
    _loadVisibleTiles(topLeft, bottomRight);
    
    final double scale = matrix.getMaxScaleOnAxis();
    final Offset centerLocal = MatrixUtils.transformPoint(inverse, centerScreen);
    final double fastCullDist = 100.0 / scale; // 100 screen pixels translated to local
    
    // Magnetic Snap Logic (Screen Coordinates)
    MapMarkerInfo? closestMarker;
    double closestDistSq = double.infinity;
    const double thresholdSq = 900.0; // 30 pixels radius on screen
    
    void checkMarker(Offset pos, String title, String subtitle, IconData icon, Color color, int type, {String? id, int? originDimension}) {
      if (type != -1 && type != -2) {
        final bool isDense = StructureType.getRegionSize(type) <= 1;
        if (isDense && scale < 0.2) return; // Completely culled by LOD
      }
    
      final double pixelX = pos.dx / 4.0;
      final double pixelZ = pos.dy / 4.0;
      final double localX = centerOffset + pixelX;
      final double localZ = centerOffset + pixelZ;
      
      // FAST AABB CULLING: Avoid expensive matrix math for markers far from center
      if ((localX - centerLocal.dx).abs() > fastCullDist || 
          (localZ - centerLocal.dy).abs() > fastCullDist) {
        return;
      }
      
      final Offset localPos = Offset(localX, localZ);
      final Offset screenPos = MatrixUtils.transformPoint(matrix, localPos);
      
      final double dx = screenPos.dx - centerScreen.dx;
      final double dy = screenPos.dy - centerScreen.dy;
      final double distSq = dx * dx + dy * dy;
      
      if (distSq < thresholdSq && distSq < closestDistSq) {
        closestDistSq = distSq;
        closestMarker = MapMarkerInfo(pos, title, subtitle, icon, color, id: id, originDimension: originDimension);
      }
    }

    for (var tileList in _tileStructures.values) {
      for (var s in tileList) {
        if (_activeStructures.contains(s.type)) {
          checkMarker(s.pos, StructureUiHelper.getName(context, s.type), AppLocalizations.of(context)!.mapScreenStructure, StructureUiHelper.getIcon(s.type), StructureUiHelper.getColor(s.type), s.type);
        }
      }
    }
    
    if (_activeStructures.contains(-2)) {
      for (var w in _currentWorld.waypoints.where((w) => w.dimension == _selectedDimension)) {
        checkMarker(Offset(w.x.toDouble(), w.z.toDouble()), w.name, AppLocalizations.of(context)!.mapScreenWaypoint, Icons.flag, Color(w.color), -2, id: w.id);
      }
      for (var w in _getTranslucidWaypoints()) {
        checkMarker(Offset(w.x.toDouble(), w.z.toDouble()), w.name, AppLocalizations.of(context)!.mapScreenWaypoint, Icons.flag, Color(w.color), -2, id: w.id, originDimension: w.dimension);
      }
    }

    // Check Spawn
    if (_activeStructures.contains(-1) && _spawnPos != null) {
      checkMarker(_spawnPos!, AppLocalizations.of(context)!.mapScreenSpawn, AppLocalizations.of(context)!.mapScreenSpawn, Icons.star, Colors.redAccent, -1);
    }

    if (_selectedMarkerNotifier.value?.pos != closestMarker?.pos) {
      // Future.microtask prevents setStates during build phase if any occurs
      Future.microtask(() {
        if (mounted) _selectedMarkerNotifier.value = closestMarker;
      });
    }
  }

  List<String> _tileQueue = [];
  int _activeWorkers = 0;
  static const int _maxWorkers = 16; // Increased to 16 concurrent tile workers

  List<Waypoint> _getTranslucidWaypoints() {
    if (!_activeStructures.contains(-2)) return [];
    
    if (_selectedDimension == 0) {
      // Overworld: show Nether waypoints translated
      return _currentWorld.waypoints
          .where((w) => w.dimension == -1)
          .map((w) => Waypoint(
                id: w.id,
                name: w.name,
                x: w.x * 8,
                z: w.z * 8,
                color: w.color,
                dimension: -1, // Keep original dimension to identify it
              ))
          .toList();
    } else if (_selectedDimension == -1) {
      // Nether: show Overworld waypoints translated
      return _currentWorld.waypoints
          .where((w) => w.dimension == 0)
          .map((w) => Waypoint(
                id: w.id,
                name: w.name,
                x: w.x ~/ 8,
                z: w.z ~/ 8,
                color: w.color,
                dimension: 0, // Keep original dimension to identify it
              ))
          .toList();
    }
    return [];
  }

  void _loadVisibleTiles(Offset topLeft, Offset bottomRight) {
    // Add margin to pre-load tiles just outside the viewport
    final double padding = tileSize * 1.0; 
    
    // Local coords relative to center
    final double startLocalX = (topLeft.dx - padding) - centerOffset;
    final double endLocalX = (bottomRight.dx + padding) - centerOffset;
    final double startLocalZ = (topLeft.dy - padding) - centerOffset;
    final double endLocalZ = (bottomRight.dy + padding) - centerOffset;
    
    final int startTileX = (startLocalX / tileSize).floor();
    final int endTileX = (endLocalX / tileSize).floor();
    final int startTileZ = (startLocalZ / tileSize).floor();
    final int endTileZ = (endLocalZ / tileSize).floor();
    
    // Clear queue of old unstarted tasks so we prioritize current view
    for (var task in _tileQueue) {
      final parts = task.split('|');
      final key = parts[2];
      _loadingTiles.remove(key);
    }
    _tileQueue.clear();
    
    // Determine center of view to prioritize loading center tiles first
    final int centerTileX = (startTileX + endTileX) ~/ 2;
    final int centerTileZ = (startTileZ + endTileZ) ~/ 2;

    // Create a list of required tiles
    final List<Map<String, dynamic>> neededTiles = [];
    for (int tx = startTileX; tx <= endTileX; tx++) {
      for (int tz = startTileZ; tz <= endTileZ; tz++) {
        final key = '${tx}_$tz';
        if (!_tiles.containsKey(key) && _loadingTiles[key] != true) {
          // Calculate distance to center for sorting
          final dist = (tx - centerTileX) * (tx - centerTileX) + (tz - centerTileZ) * (tz - centerTileZ);
          neededTiles.add({'tx': tx, 'tz': tz, 'key': key, 'dist': dist});
        }
        if (!_tileStructures.containsKey(key)) {
          _generateTileStructures(tx, tz, key);
        }
      }
    }

    // Sort by distance (descending) so that when we removeLast(), we get the closest to center
    neededTiles.sort((a, b) => (b['dist'] as int).compareTo(a['dist'] as int));

    for (var t in neededTiles) {
      _loadingTiles[t['key']] = true;
      _tileQueue.add('${t['tx']}|${t['tz']}|${t['key']}');
    }
    
    _processQueue();
  }

  void _processQueue() {
    while (_activeWorkers < _maxWorkers && _tileQueue.isNotEmpty) {
      final task = _tileQueue.removeLast();
      final parts = task.split('|');
      final int tx = int.parse(parts[0]);
      final int tz = int.parse(parts[1]);
      final String key = parts[2];
      
      _activeWorkers++;
      _generateTile(tx, tz, key).then((_) {
        _activeWorkers--;
        _processQueue();
      });
    }
  }

  void _generateTileStructures(int tx, int tz, String key) {
    // 1 tile = 1024 blocks.
    final int minBlockX = tx * 1024;
    final int maxBlockX = tx * 1024 + 1023;
    final int minBlockZ = tz * 1024;
    final int maxBlockZ = tz * 1024 + 1023;
    
    final List<StructureMark> marks = [];
    
    final structuresToGenerate = _activeStructures.where((t) => t != -1 && t != -2).toList();
    
    for (int type in structuresToGenerate) {
      final int searchType = (type == StructureType.Ruined_Portal && _selectedDimension == -1)  
          ? StructureType.Ruined_Portal_N 
          : type;
          
      final int regSizeBlocks = StructureType.getRegionSize(searchType) * 16;
      
      final int minRegX = (minBlockX / regSizeBlocks).floor();
      final int maxRegX = (maxBlockX / regSizeBlocks).floor();
      final int minRegZ = (minBlockZ / regSizeBlocks).floor();
      final int maxRegZ = (maxBlockZ / regSizeBlocks).floor();
      
      for (int rx = minRegX; rx <= maxRegX; rx++) {
        for (int rz = minRegZ; rz <= maxRegZ; rz++) {
          final pos = _finders?.getStructurePos(searchType, _currentWorld.mcVersion, _currentWorld.seed, rx, rz);
          // 0,0 is technically a valid coordinate but getStructurePos usually returns null if not found.
          // In dart we return null.
          if (pos != null && _finders != null) {
             if (_finders!.isViableStructurePos(_currentWorld.mcVersion, _selectedDimension, _currentWorld.seed, searchType, pos.dx.toInt(), pos.dy.toInt())) {
               marks.add(StructureMark(pos, type));
             }
          }
        }
      }
    }
    
    setState(() {
      _tileStructures[key] = marks;
    });
  }

  Future<void> _generateTile(int tx, int tz, String key) async {
    try {
      final ui.Image image = await MapGenerator.generateTileAsync(_currentWorld.seed, _currentWorld.mcVersion, _selectedDimension, _selectedHeight, tx, tz, tileSize);
      if (mounted) {
        setState(() {
          _tiles[key] = image;
          _loadingTiles.remove(key);
        });
      }
    } catch (e) {
      _loadingTiles.remove(key);
      debugPrint("Tile error: $e");
    }
  }

  void _centerMapOn(Offset worldPos) {
    final RenderBox? renderBox = _mapAreaKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final Size screenSize = renderBox.size;
    final Matrix4 matrix = _transformationController.value;
    
    final double pixelX = worldPos.dx / 4.0;
    final double pixelZ = worldPos.dy / 4.0;
    final Offset targetLocal = Offset(centerOffset + pixelX, centerOffset + pixelZ);
    
    final Offset centerScreen = Offset(screenSize.width / 2, screenSize.height / 2);
    final double scale = matrix.getMaxScaleOnAxis();
    
    final Matrix4 goalMatrix = Matrix4.identity()
      ..translate(
        centerScreen.dx - targetLocal.dx * scale,
        centerScreen.dy - targetLocal.dy * scale,
      )
      ..scale(scale);
      
    _mapAnimation = Matrix4Tween(
      begin: _transformationController.value,
      end: goalMatrix,
    ).animate(CurvedAnimation(parent: _mapAnimController, curve: Curves.easeOutCubic));
    
    _mapAnimController.forward(from: 0);
  }

  void _zoom(double factor) {
    final matrix = _transformationController.value.clone();
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final Offset screenCenter = Offset(renderBox.size.width / 2, renderBox.size.height / 2);
    final Offset sceneCenter = _transformationController.toScene(screenCenter);
    
    matrix.translate(sceneCenter.dx, sceneCenter.dy);
    matrix.scale(factor);
    matrix.translate(-sceneCenter.dx, -sceneCenter.dy);
    
    _transformationController.value = matrix;
  }

  void _editWorldSettings() {
    showDialog(
      context: context,
      builder: (context) => WorldSettingsDialog(
        initialWorld: _currentWorld,
        onSave: (updatedWorld) async {
          await _worldRepo.saveWorld(updatedWorld);
          setState(() {
            _currentWorld = updatedWorld;
            _tiles.clear();
            _loadingTiles.clear();
            _tileStructures.clear();
            _tileQueue.clear();
            
            // Reload spawn with new seed/version
            if (_finders != null) {
              final sPos = _finders!.getSpawn(_currentWorld.seed, _currentWorld.mcVersion);
              _spawnPos = ui.Offset(sPos.x.toDouble(), sPos.z.toDouble());
            }
          });
          _onViewChanged(); // Trigger redraw
        },
      ),
    );
  }


  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: DraggableScrollableSheet(
                initialChildSize: 0.6,
                minChildSize: 0.4,
                maxChildSize: 0.9,
                expand: false,
                builder: (context, scrollController) {
                  return ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(AppLocalizations.of(context)!.mapSettingsTitle, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const Divider(color: Colors.white24, height: 32),
                      
                      Text(AppLocalizations.of(context)!.mapSettingsDimension, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: _selectedDimension,
                        dropdownColor: Theme.of(context).cardColor,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          DropdownMenuItem(value: 0, child: Row(children: [const Icon(Icons.public, color: Colors.green, size: 20), const SizedBox(width: 8), Text(AppLocalizations.of(context)!.dimensionOverworld)])),
                          DropdownMenuItem(value: -1, child: Row(children: [const Icon(Icons.whatshot, color: Colors.redAccent, size: 20), const SizedBox(width: 8), Text(AppLocalizations.of(context)!.dimensionNether)])),
                          DropdownMenuItem(value: 1, child: Row(children: [const Icon(Icons.nights_stay, color: Colors.deepPurple, size: 20), const SizedBox(width: 8), Text(AppLocalizations.of(context)!.dimensionEnd)])),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              _selectedDimension = val;
                              // Keep spawn/waypoints active if they were, or just maintain state
                            });
                            setState(() {
                              _selectedDimension = val;
                              _tiles.clear();
                              _tileStructures.clear();
                              _onViewChanged();
                            });
                          }
                        },
                      ),
                      
                      if (_selectedDimension == 0) ...[
                        const SizedBox(height: 16),
                        Text(AppLocalizations.of(context)!.mapSettingsBiomeHeight, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: _selectedHeight,
                          dropdownColor: Theme.of(context).cardColor,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: [
                            DropdownMenuItem(value: 320, child: Text(AppLocalizations.of(context)!.mapSettingsSurface)),
                            DropdownMenuItem(value: 0, child: Text(AppLocalizations.of(context)!.mapSettingsUnderground)),
                            DropdownMenuItem(value: -51, child: Text(AppLocalizations.of(context)!.mapSettingsBottom)),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => _selectedHeight = val);
                              setState(() {
                                _selectedHeight = val;
                                _tiles.clear();
                                _tileStructures.clear();
                                _onViewChanged();
                              });
                            }
                          },
                        ),
                      ],
                      
                      const Divider(color: Colors.white24, height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(AppLocalizations.of(context)!.mapSettingsStructures, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  setModalState(() {
                                    _activeStructures.addAll(_getStructuresForDimension(_selectedDimension));
                                  });
                                  _saveActiveStructures();
                                  setState(() {
                                    _tileStructures.clear();
                                    _onViewChanged();
                                  });
                                },
                                child: Text(AppLocalizations.of(context)!.mapSettingsAll, style: TextStyle(color: Theme.of(context).primaryColor)),
                              ),
                              TextButton(
                                onPressed: () {
                                  setModalState(() {
                                    _activeStructures.removeAll(_getStructuresForDimension(_selectedDimension));
                                  });
                                  _saveActiveStructures();
                                  setState(() {
                                    _tileStructures.clear();
                                    _onViewChanged();
                                  });
                                },
                                child: Text(AppLocalizations.of(context)!.mapSettingsNone, style: const TextStyle(color: Colors.white54)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _getStructuresForDimension(_selectedDimension).map((type) {
                          final isActive = _activeStructures.contains(type);
                          return FilterChip(
                            showCheckmark: false,
                            avatar: Icon(StructureUiHelper.getIcon(type), size: 18, color: isActive ? Colors.black : Colors.white),
                            label: Text(StructureUiHelper.getName(context, type), style: TextStyle(color: isActive ? Colors.black : Colors.white)),
                            selected: isActive,
                            selectedColor: Theme.of(context).primaryColor,
                            backgroundColor: Theme.of(context).cardColor,
                            onSelected: (val) {
                              setModalState(() {
                                if (val) {
                                  _activeStructures.add(type);
                                } else {
                                  _activeStructures.remove(type);
                                }
                              });
                              _saveActiveStructures();
                              setState(() {
                                _tileStructures.clear();
                                _onViewChanged();
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_currentWorld.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            GestureDetector(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: _currentWorld.seed.toString()));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.mapScreenSeedCopied),
                    backgroundColor: Theme.of(context).primaryColor,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Text(
                '${_currentWorld.seed}',
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
        actions: [
          IconButton(
            icon: const Icon(Icons.format_list_bulleted),
            tooltip: AppLocalizations.of(context)!.mapScreenWaypointList,
            onPressed: _showWaypointsMenu,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: AppLocalizations.of(context)!.mapScreenWorldSettings,
            onPressed: _editWorldSettings,
          ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ClipRect(
        child: Stack(
          key: _mapAreaKey,
          children: [
            GestureDetector(
              onTapUp: (details) {
              final RenderBox? renderBox = _mapAreaKey.currentContext?.findRenderObject() as RenderBox?;
              if (renderBox == null) return;
              
              final Size screenSize = renderBox.size;
              final Matrix4 matrix = _transformationController.value;
              
              final Offset tapScreen = details.localPosition;
              
              MapMarkerInfo? closestMarker;
              double closestDistSq = double.infinity;
              const double thresholdSq = 1600.0; // 40 pixels radius on screen
              
              void checkMarker(Offset pos, String title, String subtitle, IconData icon, Color color, {bool isPin = true, String? id, int? originDimension}) {
                final double pixelX = pos.dx / 4.0;
                final double pixelZ = pos.dy / 4.0;
                final Offset localPos = Offset(centerOffset + pixelX, centerOffset + pixelZ);
                final Offset screenPos = MatrixUtils.transformPoint(matrix, localPos);
                
                final double visualY = isPin ? screenPos.dy - 20.4 : screenPos.dy;
                
                final double dx = screenPos.dx - tapScreen.dx;
                final double dy = visualY - tapScreen.dy;
                final double distSq = dx * dx + dy * dy;
                
                if (distSq < thresholdSq && distSq < closestDistSq) {
                  closestDistSq = distSq;
                  closestMarker = MapMarkerInfo(pos, title, subtitle, icon, color, id: id, originDimension: originDimension);
                }
              }

              final allStructures = _tileStructures.values.expand((e) => e).toList();
              for (var s in allStructures) {
                if (_activeStructures.contains(s.type)) {
                  checkMarker(s.pos, StructureUiHelper.getName(context, s.type), AppLocalizations.of(context)!.mapScreenStructure, StructureUiHelper.getIcon(s.type), StructureUiHelper.getColor(s.type));
                }
              }
              
              if (_activeStructures.contains(-2)) {
                for (var w in _currentWorld.waypoints.where((wp) => wp.dimension == _selectedDimension)) {
                  checkMarker(Offset(w.x.toDouble(), w.z.toDouble()), w.name, AppLocalizations.of(context)!.mapScreenWaypoint, Icons.flag, Color(w.color), id: w.id);
                }
                for (var w in _getTranslucidWaypoints()) {
                  checkMarker(Offset(w.x.toDouble(), w.z.toDouble()), w.name, AppLocalizations.of(context)!.mapScreenWaypoint, Icons.flag, Color(w.color), id: w.id, originDimension: w.dimension);
                }
              }
              if (_activeStructures.contains(-1) && _spawnPos != null) {
                checkMarker(_spawnPos!, AppLocalizations.of(context)!.mapScreenSpawn, AppLocalizations.of(context)!.mapScreenSpawn, Icons.star, Colors.redAccent, isPin: false);
              }
              
              if (closestMarker != null) {
                _centerMapOn(closestMarker!.pos);
              }
            },
            child: InteractiveViewer(
              transformationController: _transformationController,
              onInteractionEnd: (ScaleEndDetails details) {
                final selected = _selectedMarkerNotifier.value;
                if (selected != null) {
                  // Only snap if the user isn't flinging the map away quickly
                  if (details.velocity.pixelsPerSecond.distance < 500) {
                    _centerMapOn(selected.pos);
                  }
                }
              },
              constrained: false,
              boundaryMargin: const EdgeInsets.all(worldSize),
              minScale: 0.1,
              maxScale: 4.0,
              child: SizedBox(
                width: worldSize,
                height: worldSize,
                child: CustomPaint(
                  painter: MapPainter(
                    tiles: _tiles,
                    centerOffset: centerOffset,
                    tileSize: tileSize,
                  ),
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: AnimatedBuilder(
              animation: Listenable.merge([_transformationController, _selectedMarkerNotifier, _magnetAnimController]),
              builder: (context, child) {
                final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
                final Size screenSize = renderBox?.size ?? Size.zero;
                return SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: CustomPaint(
                    painter: MapOverlayPainter(
                      transform: _transformationController.value,
                      waypoints: _activeStructures.contains(-2) ? _currentWorld.waypoints.where((w) => w.dimension == _selectedDimension).toList() : [],
                      translucidWaypoints: _getTranslucidWaypoints(),
                      spawnPos: _activeStructures.contains(-1) ? _spawnPos : null,
                      structures: _tileStructures.values.expand((e) => e).where((s) => _activeStructures.contains(s.type)).toList(),
                      centerOffset: centerOffset,
                      selectedMarkerPos: _activeMagnetMarker?.pos,
                      magnetProgress: _magnetAnimController.value,
                    ),
                  ),
                );
              },
            ),
          ),
          // Central Crosshair & Info Overlay
          AnimatedBuilder(
            animation: Listenable.merge([_transformationController, _selectedMarkerNotifier]),
            builder: (context, child) {
              final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
              if (renderBox == null) return const SizedBox.shrink();
              
              final Size screenSize = renderBox.size;
              final Matrix4 matrix = _transformationController.value;
              final Matrix4 inverse = Matrix4.tryInvert(matrix) ?? Matrix4.identity();
              
              final Offset centerScreen = Offset(screenSize.width / 2, screenSize.height / 2);
              final Offset centerLocal = MatrixUtils.transformPoint(inverse, centerScreen);
              
              final int blockX = ((centerLocal.dx - centerOffset) * 4).floor();
              final int blockZ = ((centerLocal.dy - centerOffset) * 4).floor();
              
              final MapMarkerInfo? selected = _selectedMarkerNotifier.value;

              return Stack(
                children: [
                  // Info Card - Independently aligned above center
                  Align(
                    alignment: Alignment.center,
                    child: FractionalTranslation(
                      translation: const Offset(0, -0.85), // Move card closer to the glowing halo
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutBack,
                        child: selected != null
                          ? Material(
                              color: Colors.transparent,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: selected.color, width: 2),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 4))
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(selected.icon, color: selected.color, size: 20),
                                            const SizedBox(width: 8),
                                            Text(
                                              selected.title,
                                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                            if (selected.originDimension != null && selected.originDimension != _selectedDimension) ...[
                                              const SizedBox(width: 8),
                                              Tooltip(
                                                message: '${AppLocalizations.of(context)!.mapScreenWaypointFrom}${selected.originDimension == 0 ? AppLocalizations.of(context)!.dimensionOverworld : AppLocalizations.of(context)!.dimensionNether}',
                                                child: Icon(
                                                  selected.originDimension == 0 ? Icons.public : Icons.whatshot, 
                                                  color: (selected.originDimension == 0 ? Colors.green : Colors.redAccent).withOpacity(0.5), 
                                                  size: 20
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          selected.subtitle,
                                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54), fontSize: 12),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'X: ${selected.pos.dx.round()}  Z: ${selected.pos.dy.round()}',
                                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14, fontFamily: 'monospace'),
                                        ),
                                      ],
                                    ),
                                    if (selected.id != null && selected.subtitle == AppLocalizations.of(context)!.mapScreenWaypoint) ...[
                                      const SizedBox(width: 16),
                                      Container(
                                        height: 40,
                                        width: 1,
                                        color: Theme.of(context).dividerColor,
                                      ),
                                      const SizedBox(width: 4),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                                        tooltip: AppLocalizations.of(context)!.mapScreenDeleteWaypoint,
                                        onPressed: () async {
                                          final updatedWaypoints = _currentWorld.waypoints.where((w) => w.id != selected.id).toList();
                                          _currentWorld = _currentWorld.copyWith(waypoints: updatedWaypoints);
                                          await _worldRepo.saveWorld(_currentWorld);
                                          
                                          _selectedMarkerNotifier.value = null;
                                          setState(() {
                                            _onViewChanged();
                                          });
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            )
                          : IgnorePointer(
                              child: (() {
                                String biomeName;
                                try {
                                  if (_finders != null) {
                                    final int biomeId = _finders!.getBiomeAt(_currentWorld.seed, 35, _selectedDimension, _selectedHeight, blockX, blockZ);
                                    biomeName = biomeNames[biomeId] ?? "Unknown Biome";
                                  } else {
                                    biomeName = "Unknown (FFI missing)";
                                  }
                                } catch (e) {
                                  biomeName = "Unknown Biome";
                                }
                                
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        biomeName,
                                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'X: $blockX  Z: $blockZ',
                                        style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'monospace'),
                                      ),
                                    ],
                                  ),
                                );
                              })(),
                        ),
                      ),
                    ),
                  ),
                  // Round Crosshair - Absolutely locked to center
                  IgnorePointer(
                    child: Align(
                      alignment: Alignment.center,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutBack,
                        width: selected != null ? 42 : 16,
                        height: selected != null ? 42 : 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white, 
                            width: 2
                          ),
                          color: selected != null ? selected.color : Colors.white.withOpacity(0.3),
                          boxShadow: const [
                             BoxShadow(color: Colors.black54, blurRadius: 4, spreadRadius: 1)
                          ]
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 150),
                          transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: FadeTransition(opacity: animation, child: child)),
                          child: selected != null 
                              ? Icon(
                                  selected.icon, 
                                  color: selected.color.computeLuminance() > 0.7 ? Colors.black87 : Colors.white, 
                                  size: 24, 
                                  key: ValueKey(selected.title)
                                )
                              : const SizedBox.shrink(key: ValueKey('empty')),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            left: 16,
            bottom: 32,
            child: FloatingActionButton(
              heroTag: 'settingsMenu',
              backgroundColor: Theme.of(context).cardColor,
              onPressed: _showSettingsMenu,
              child: Icon(Icons.tune, color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 32,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'addWaypoint',
                  backgroundColor: Theme.of(context).primaryColor,
                  mini: true,
                  onPressed: _showAddWaypointDialog,
                  child: Icon(Icons.add_location_alt, color: Theme.of(context).colorScheme.onPrimary),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'centerSpawn',
                  backgroundColor: Theme.of(context).cardColor,
                  mini: true,
                  onPressed: () {
                    if (_spawnPos != null) {
                      _centerMapOn(_spawnPos!);
                    }
                  },
                  child: Icon(Icons.my_location, color: Theme.of(context).colorScheme.onSurface),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'zoomIn',
                  backgroundColor: Theme.of(context).cardColor,
                  mini: true,
                  onPressed: () => _zoom(1.5),
                  child: Icon(Icons.add, color: Theme.of(context).colorScheme.onSurface),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'zoomOut',
                  backgroundColor: Theme.of(context).cardColor,
                  mini: true,
                  onPressed: () => _zoom(1 / 1.5),
                  child: Icon(Icons.remove, color: Theme.of(context).colorScheme.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
