import 'dart:ffi';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:ffi/ffi.dart';
import 'cubiomes_engine_bindings_generated.dart';

final class Pos extends Struct {
  @Int32()
  external int x;
  @Int32()
  external int z;
}

typedef _EstimateSpawnNative = Pos Function(Pointer<Generator> g, Pointer<Uint64> rng);
typedef _EstimateSpawnDart = Pos Function(Pointer<Generator> g, Pointer<Uint64> rng);

typedef _GetStructurePosNative = Int32 Function(Int32 structureType, Int32 mc, Uint64 seed, Int32 regX, Int32 regZ, Pointer<Pos> pos);
typedef _GetStructurePosDart = int Function(int structureType, int mc, int seed, int regX, int regZ, Pointer<Pos> pos);

typedef _IsViableStructurePosNative = Int32 Function(Int32 structType, Pointer<Generator> g, Int32 blockX, Int32 blockZ, Uint32 flags);
typedef _IsViableStructurePosDart = int Function(int structType, Pointer<Generator> g, int blockX, int blockZ, int flags);

class CubiomesFinders {
  late final _EstimateSpawnDart _estimateSpawn;
  late final _GetStructurePosDart _getStructurePos;
  late final _IsViableStructurePosDart _isViableStructurePos;
  late final CubiomesBindings _bindings;

  CubiomesFinders() {
    final DynamicLibrary _dylib;
    if (Platform.isIOS || Platform.isMacOS) {
      _dylib = DynamicLibrary.open('cubiomes_ffi.framework/cubiomes_ffi');
    } else {
      _dylib = DynamicLibrary.open('libcubiomes_engine.so');
    }
    
    _estimateSpawn = _dylib.lookupFunction<_EstimateSpawnNative, _EstimateSpawnDart>('wrapper_estimateSpawn');
    _getStructurePos = _dylib.lookupFunction<_GetStructurePosNative, _GetStructurePosDart>('wrapper_getStructurePos');
    _isViableStructurePos = _dylib.lookupFunction<_IsViableStructurePosNative, _IsViableStructurePosDart>('wrapper_isViableStructurePos');
    _bindings = CubiomesBindings(_dylib);
  }

  /// Returns the Biome ID at the given block coordinates.
  int getBiomeAt(int seed, int version, int dimension, int yHeight, int blockX, int blockZ) {
    final genPointer = calloc<Generator>();
    final bindings = CubiomesBindings(DynamicLibrary.process());
    
    bindings.setupGenerator(genPointer, version, dimension);
    bindings.applySeed(genPointer, dimension, seed);
    
    // Scale 1 means 1:1 blocks. Scale 4 means 1:4 blocks (for map rendering).
    // The native function takes (scale, x, y, z).
    final biomeId = bindings.getBiomeAt(genPointer, 1, blockX, yHeight, blockZ);
    
    calloc.free(genPointer);
    return biomeId;
  }

  /// Calculates the spawn point for a given seed and version.
  Pos getSpawn(int seed, int version) {
    final genPointer = calloc<Generator>();
    final bindings = _bindings;
    
    // Setup generator
    bindings.setupGenerator(genPointer, version, 0);
    bindings.applySeed(genPointer, 0, seed);
    
    // Call estimateSpawn (passing nullptr for rng)
    final pos = _estimateSpawn(genPointer, nullptr);
    
    calloc.free(genPointer);
    return pos;
  }

  /// Returns the Offset if a structure was found, otherwise null.
  ui.Offset? getStructurePos(int structureType, int version, int seed, int regX, int regZ) {
    final outPos = calloc<Pos>();
    int result = _getStructurePos(structureType, version, seed, regX, regZ, outPos);
    
    ui.Offset? offset;
    if (result != 0) {
      offset = ui.Offset(outPos.ref.x.toDouble(), outPos.ref.z.toDouble());
    }
    calloc.free(outPos);
    return offset;
  }

  /// Returns true if the structure is viable at the given coordinates.
  bool isViableStructurePos(int version, int dimension, int seed, int structureType, int blockX, int blockZ) {
    final genPointer = calloc<Generator>();
    final bindings = _bindings;
    
    bindings.setupGenerator(genPointer, version, dimension);
    bindings.applySeed(genPointer, dimension, seed);
    
    final result = _isViableStructurePos(structureType, genPointer, blockX, blockZ, 0);
    
    calloc.free(genPointer);
    return result != 0;
  }
}

// Structure Type Constants
class StructureType {
  static const int Feature = 0;
  static const int Desert_Pyramid = 1;
  static const int Jungle_Temple = 2;
  static const int Swamp_Hut = 3;
  static const int Igloo = 4;
  static const int Village = 5;
  static const int Ocean_Ruin = 6;
  static const int Shipwreck = 7;
  static const int Monument = 8;
  static const int Mansion = 9;
  static const int Outpost = 10;
  static const int Ruined_Portal = 11;
  static const int Ruined_Portal_N = 12;
  static const int Ancient_City = 13;
  static const int Treasure = 14;
  static const int Mineshaft = 15;
  static const int Desert_Well = 16;
  static const int Geode = 17;
  static const int Fortress = 18;
  static const int Bastion = 19;
  static const int End_City = 20;
  static const int End_Gateway = 21;
  static const int End_Island = 22;
  static const int Trail_Ruins = 23;
  static const int Trial_Chamber = 24;

  static int getRegionSize(int type) {
    switch (type) {
      case Feature:
      case Desert_Pyramid:
      case Jungle_Temple:
      case Swamp_Hut:
      case Igloo:
      case Monument:
      case Outpost:
        return 32;
      case Village:
      case Trail_Ruins:
      case Trial_Chamber:
        return 34;
      case Ocean_Ruin:
      case End_City:
        return 20;
      case Shipwreck:
      case Ancient_City:
        return 24;
      case Mansion:
        return 80;
      case Ruined_Portal:
      case Ruined_Portal_N:
        return 40;
      case Fortress:
      case Bastion:
        return 27;
      case Treasure:
      case Mineshaft:
      case Desert_Well:
      case Geode:
      case End_Gateway:
      case End_Island:
        return 1;
      default:
        return 32;
    }
  }
}
