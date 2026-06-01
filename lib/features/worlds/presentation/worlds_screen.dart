import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/world_model.dart';
import '../data/world_repository.dart';
import 'world_settings_dialog.dart';
import 'tutorial_dialog.dart';
import '../../map/presentation/map_screen.dart';
import '../../../main.dart';
import 'package:minecraft_seedwalker_mobile/l10n/app_localizations.dart';
import '../../settings/presentation/settings_screen.dart';

class WorldsScreen extends StatefulWidget {
  const WorldsScreen({super.key});

  @override
  State<WorldsScreen> createState() => _WorldsScreenState();
}

class _WorldsScreenState extends State<WorldsScreen> {
  final WorldRepository _repository = WorldRepository();
  List<World> _worlds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorlds();
    _checkFirstLaunch();
  }
  
  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenTutorial = prefs.getBool('has_seen_tutorial') ?? false;
    
    if (!hasSeenTutorial) {
      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const TutorialDialog(),
      );
      await prefs.setBool('has_seen_tutorial', true);
    }
  }

  Future<void> _loadWorlds() async {
    final worlds = await _repository.getWorlds();
    
    // Add default world if list is empty
    if (worlds.isEmpty) {
      final defaultWorld = World(
        id: 'default_world_1',
        name: 'Mi Mundo Principal',
        seed: 795381847902972960,
        lastPlayed: DateTime.now(),
      );
      await _repository.saveWorld(defaultWorld);
      worlds.add(defaultWorld);
    }
    
    setState(() {
      _worlds = worlds;
      _isLoading = false;
    });
  }

  void _openWorld(World world, int dimension) async {
    // Update last played time
    final updatedWorld = world.copyWith(lastPlayed: DateTime.now());
    await _repository.saveWorld(updatedWorld);
    
    if (!mounted) return;
    
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(world: updatedWorld, initialDimension: dimension),
      ),
    );
    
    if (mounted) {
      _loadWorlds();
    }
  }

  void _showDimensionPicker(World world) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E222D),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        final theme = Theme.of(context);
        final l10n = AppLocalizations.of(context)!;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.selectDimension,
                style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.public, color: Colors.green),
                title: Text(l10n.dimensionOverworld, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 18)),
                onTap: () {
                  Navigator.pop(context);
                  _openWorld(world, 0);
                },
              ),
              ListTile(
                leading: const Icon(Icons.whatshot, color: Colors.redAccent),
                title: Text(l10n.dimensionNether, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 18)),
                onTap: () {
                  Navigator.pop(context);
                  _openWorld(world, -1);
                },
              ),
              ListTile(
                leading: const Icon(Icons.nights_stay, color: Colors.deepPurple),
                title: Text(l10n.dimensionEnd, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 18)),
                onTap: () {
                  Navigator.pop(context);
                  _openWorld(world, 1);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _editWorld(World world) {
    showDialog(
      context: context,
      builder: (context) => WorldSettingsDialog(
        initialWorld: world,
        onSave: (updatedWorld) async {
          await _repository.saveWorld(updatedWorld);
          _loadWorlds();
        },
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.language, style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.languageSystem, style: TextStyle(color: theme.colorScheme.onSurface)),
              onTap: () {
                languageManager.setLocale(null);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(l10n.languageEnglish, style: TextStyle(color: theme.colorScheme.onSurface)),
              onTap: () {
                languageManager.setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(l10n.languageSpanish, style: TextStyle(color: theme.colorScheme.onSurface)),
              onTap: () {
                languageManager.setLocale(const Locale('es'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _createNewWorld() {
    showDialog(
      context: context,
      builder: (context) => WorldSettingsDialog(
        onSave: (newWorld) async {
          await _repository.saveWorld(newWorld);
          _loadWorlds();
        },
      ),
    );
  }

  void _deleteWorld(String id) async {
    setState(() {
      _worlds.removeWhere((w) => w.id == id);
    });
    await _repository.deleteWorld(id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.worldsScreenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: l10n.worldsScreenViewTutorial,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const TutorialDialog(),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _worlds.length,
              itemBuilder: (context, index) {
                final world = _worlds[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Dismissible(
                    key: Key(world.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) => _deleteWorld(world.id),
                    child: Card(
                      margin: EdgeInsets.zero,
                      color: theme.cardColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        onTap: () => _showDimensionPicker(world),
                        onLongPress: () {
                          Clipboard.setData(ClipboardData(text: world.seed.toString()));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.worldsScreenSeedCopied, style: const TextStyle(color: Colors.white)),
                              backgroundColor: theme.primaryColor,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: theme.primaryColor.withOpacity(0.5), width: 2),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: world.thumbnailBase64 != null && world.thumbnailBase64!.isNotEmpty
                                      ? Image.memory(
                                          base64Decode(world.thumbnailBase64!),
                                          fit: BoxFit.cover,
                                          gaplessPlayback: true,
                                        )
                                      : Container(
                                          color: Colors.black26,
                                          child: Icon(Icons.public, color: theme.primaryColor, size: 32),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      world.name,
                                      style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${world.seed}',
                                      style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.54), fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, color: theme.colorScheme.onSurface.withOpacity(0.54)),
                                onPressed: () => _editWorld(world),
                                tooltip: l10n.worldsScreenEditSettings,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: theme.primaryColor,
        onPressed: _createNewWorld,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(l10n.worldsScreenNewWorld, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
