import 'dart:ui' as ui;
import 'dart:isolate';
import 'dart:convert';
import 'dart:typed_data';
import '../../../core/ffi/cubiomes_engine.dart';
import '../../../core/ffi/cubiomes_finders.dart';
import 'dart:async';

class ThumbnailGenerator {
  static Future<String> generateBase64Thumbnail(int seed, int version) async {
    final finders = CubiomesFinders();
    final spawn = finders.getSpawn(seed, version);
    
    // We want a small map around spawn, e.g., 64x64 pixels
    // 1px = 4 blocks, so 64 pixels = 256 blocks
    const int width = 64;
    const int height = 64;
    final int startX = spawn.x - 128;
    final int startZ = spawn.z - 128;

    // Run FFI calculation in a background Isolate
    final pixels = await Isolate.run(() {
      final engine = CubiomesEngine();
      return engine.generateBiomePixelsBox(seed, version, 0, 64, startX, startZ, width, height);
    });

    // Convert pixels to an image and then to a PNG base64 string
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      pixels,
      width,
      height,
      ui.PixelFormat.rgba8888,
      (ui.Image img) => completer.complete(img),
    );
    
    final ui.Image image = await completer.future;
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    if (byteData == null) {
      return '';
    }
    
    return base64Encode(byteData.buffer.asUint8List());
  }
}
