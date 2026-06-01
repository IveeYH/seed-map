import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'cubiomes_engine_bindings_generated.dart';
import 'biome_colors.dart';

class CubiomesEngine {
  late CubiomesBindings _bindings;

  CubiomesEngine() {
    final DynamicLibrary dylib;
    if (Platform.isIOS || Platform.isMacOS) {
      dylib = DynamicLibrary.open('cubiomes_ffi.framework/cubiomes_ffi');
    } else {
      dylib = DynamicLibrary.open('libcubiomes_engine.so');
    }
    _bindings = CubiomesBindings(dylib);
  }

  Future<Uint8List> generateBiomePixelsBox(int seed, int version, int dimension, int yHeight, int startX, int startZ, int width, int height) async {
    final genPointer = calloc<Generator>();
    _bindings.setupGenerator(genPointer, version, dimension); 
    _bindings.applySeed(genPointer, dimension, seed);
    
    final Uint32List pixels = Uint32List(width * height);
    
    const int step = 3; // Query biome every 3 pixels for a great balance of sharp detail and speed
    for (int z = 0; z < height; z += step) {
      for (int x = 0; x < width; x += step) {
        // Map exactly like web: 1px = 4 blocks
        int bx = (startX + x) * 4;
        int bz = (startZ + z) * 4;
        
        int biomeId = _bindings.getBiomeAt(genPointer, 1, bx, yHeight, bz);
        int color = biomeColors[biomeId] ?? 0xFF000000;
        
        // Fill the step x step square with the same color
        for (int dy = 0; dy < step && (z + dy) < height; dy++) {
          for (int dx = 0; dx < step && (x + dx) < width; dx++) {
             pixels[(z + dy) * width + (x + dx)] = color;
          }
        }
      }
    }
    
    calloc.free(genPointer);
    return pixels.buffer.asUint8List();
  }
}
