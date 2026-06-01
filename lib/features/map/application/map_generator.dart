import 'dart:ui' as ui;
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:io';
import '../../../core/ffi/cubiomes_engine.dart';

class MapGenerator {
  static Future<ui.Image> generateTileAsync(int seed, int version, int dimension, int yHeight, int tileX, int tileY, int tileSize) async {
    final int startX = tileX * tileSize;
    final int startZ = tileY * tileSize;
    
    // Run the heavy FFI calculation in a background Isolate
    final pixels = await Isolate.run(() => _generatePixelsSync(seed, version, dimension, yHeight, startX, startZ, tileSize, tileSize));
    
    // Create UI image from the pixels
    final ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(pixels);
    final ui.ImageDescriptor descriptor = ui.ImageDescriptor.raw(
      buffer,
      width: tileSize,
      height: tileSize,
      pixelFormat: ui.PixelFormat.rgba8888,
    );
    final ui.Codec codec = await descriptor.instantiateCodec();
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  static Future<Uint8List> _generatePixelsSync(int seed, int version, int dimension, int yHeight, int startX, int startZ, int width, int height) async {
    try {
      final engine = CubiomesEngine();
      return await engine.generateBiomePixelsBox(seed, version, dimension, yHeight, startX, startZ, width, height);
    } catch (e) {
      print("Isolate FFI Error: $e");
      return Uint8List(width * height * 4); // Return empty transparent pixels on error
    }
  }
}
