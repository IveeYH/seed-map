import 'package:shared_preferences/shared_preferences.dart';
import '../domain/world_model.dart';

class WorldRepository {
  static const String _worldsKey = 'saved_worlds';

  Future<List<World>> getWorlds() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? worldsJson = prefs.getStringList(_worldsKey);
    
    if (worldsJson == null) {
      return [];
    }

    return worldsJson.map((json) => World.fromJson(json)).toList()
      ..sort((a, b) => b.lastPlayed.compareTo(a.lastPlayed));
  }

  Future<void> saveWorld(World world) async {
    final prefs = await SharedPreferences.getInstance();
    final List<World> worlds = await getWorlds();
    
    final index = worlds.indexWhere((w) => w.id == world.id);
    if (index >= 0) {
      worlds[index] = world;
    } else {
      worlds.add(world);
    }
    
    final List<String> worldsJson = worlds.map((w) => w.toJson()).toList();
    await prefs.setStringList(_worldsKey, worldsJson);
  }

  Future<void> deleteWorld(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<World> worlds = await getWorlds();
    
    worlds.removeWhere((w) => w.id == id);
    
    final List<String> worldsJson = worlds.map((w) => w.toJson()).toList();
    await prefs.setStringList(_worldsKey, worldsJson);
  }
}
