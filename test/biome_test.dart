import 'package:flutter_test/flutter_test.dart';
import 'package:minecraft_seedwalker_mobile/core/ffi/cubiomes_finders.dart';
import 'package:minecraft_seedwalker_mobile/core/ffi/biome_colors.dart';

void main() {
  test('Test biome at X=-3684, Z=479 for various Y heights', () {
    final finders = CubiomesFinders();
    final int seed = 795381847902972960;
    final int version = 35; // MC_1_21
    final int dim = 0; // Overworld
    final int bx = -3684;
    final int bz = 479;
    
    final y128 = finders.getBiomeAt(seed, version, dim, 128, bx, bz);
    final y64 = finders.getBiomeAt(seed, version, dim, 64, bx, bz);
    final y320 = finders.getBiomeAt(seed, version, dim, 320, bx, bz);
    final y0 = finders.getBiomeAt(seed, version, dim, 0, bx, bz);
    final y_51 = finders.getBiomeAt(seed, version, dim, -51, bx, bz);
    
    print('Biome at Y=128: $y128 (${biomeNames[y128]})');
    print('Biome at Y=64: $y64 (${biomeNames[y64]})');
    print('Biome at Y=320: $y320 (${biomeNames[y320]})');
    print('Biome at Y=0: $y0 (${biomeNames[y0]})');
    print('Biome at Y=-51: $y_51 (${biomeNames[y_51]})');
  });
}
