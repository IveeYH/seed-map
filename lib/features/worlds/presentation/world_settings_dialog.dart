import 'package:flutter/material.dart';
import 'dart:math';
import '../domain/world_model.dart';
import '../../map/application/thumbnail_generator.dart';
import 'package:minecraft_seedwalker_mobile/l10n/app_localizations.dart';

class WorldSettingsDialog extends StatefulWidget {
  final World? initialWorld;
  final Function(World) onSave;

  const WorldSettingsDialog({
    super.key,
    this.initialWorld,
    required this.onSave,
  });

  @override
  State<WorldSettingsDialog> createState() => _WorldSettingsDialogState();
}

class _WorldSettingsDialogState extends State<WorldSettingsDialog> {
  late TextEditingController _nameController;
  late TextEditingController _seedController;
  late String _selectedVersionKey;
  bool _isSaving = false;

  // Map of display name to MCVersion enum value as per Cubiomes bindings
  // For 25.x and 26.x we use the latest available engine (28 = 1.21.WinterDrop)
  final Map<String, int> _versions = {
    '26.2 (Chaos Cubed)': 28,
    '26.1 (Tiny Takeover)': 28,
    '25.4 (Mounts of Mayhem)': 28,
    '25.3 (The Copper Age)': 28,
    '25.2 (Chase the Skies)': 28,
    '25.1 (Spring to Life)': 28,
    '1.21.WinterDrop': 28,
    '1.21.3': 27,
    '1.21.1': 26,
    '1.20.6': 25,
    '1.19.4': 24,
    '1.18.2': 22,
    '1.17.1': 21,
    '1.16.5': 20,
    '1.15.2': 18,
    '1.14.4': 17,
    '1.12.2': 15,
    '1.8.9': 11,
    '1.7.10': 10,
    '1.0.0': 3,
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialWorld?.name ?? '');
    _seedController = TextEditingController(text: widget.initialWorld?.seed.toString() ?? '');
    
    final String? label = widget.initialWorld?.versionLabel;
    
    if (label != null && _versions.containsKey(label)) {
      _selectedVersionKey = label;
    } else {
      final int mcV = widget.initialWorld?.mcVersion ?? 26;
      // Find the first key that maps to this mcVersion as fallback
      String? foundKey;
      for (var entry in _versions.entries) {
        if (entry.value == mcV) {
          foundKey = entry.key;
          break;
        }
      }
      _selectedVersionKey = foundKey ?? '1.21.1';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _seedController.dispose();
    super.dispose();
  }

  void _generateRandomSeed() {
    final random = Random();
    // Generate random seed (signed 64-bit integer range roughly)
    final randomSeed = (random.nextInt(99999999) * 1000000) + random.nextInt(999999);
    setState(() {
      _seedController.text = randomSeed.toString();
    });
  }

  void _save() async {
    if (_nameController.text.isEmpty) return;
    
    setState(() {
      _isSaving = true;
    });

    int seed;
    if (_seedController.text.isEmpty) {
      seed = Random().nextInt(4294967296) - 2147483648; // Full 32-bit signed range
    } else {
      seed = int.tryParse(_seedController.text) ?? 0;
    }

    String? thumbnail = widget.initialWorld?.thumbnailBase64;
    // Regenerate thumbnail if it's a new world or the seed/version changed
    if (widget.initialWorld == null || 
        widget.initialWorld!.seed != seed || 
        widget.initialWorld!.mcVersion != (_versions[_selectedVersionKey] ?? 26)) {
      try {
        thumbnail = await ThumbnailGenerator.generateBase64Thumbnail(seed, _versions[_selectedVersionKey] ?? 26);
      } catch (e) {
        // Fallback gracefully if FFI fails
        thumbnail = null;
      }
    }

    final world = World(
      id: widget.initialWorld?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      seed: seed,
      mcVersion: _versions[_selectedVersionKey] ?? 26,
      versionLabel: _selectedVersionKey,
      lastPlayed: DateTime.now(),
      thumbnailBase64: thumbnail,
      waypoints: widget.initialWorld?.waypoints ?? const [],
      activeStructures: widget.initialWorld?.activeStructures ?? const [],
    );
    
    widget.onSave(world);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialWorld != null;
    final l10n = AppLocalizations.of(context)!;
    
    return AlertDialog(
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      title: Text(isEditing ? l10n.worldSettingsTitleEdit : l10n.worldSettingsTitleNew, style: const TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: l10n.worldSettingsName,
                labelStyle: const TextStyle(color: Colors.white54),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _seedController,
              keyboardType: const TextInputType.numberWithOptions(signed: true),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: l10n.worldSettingsSeed,
                labelStyle: const TextStyle(color: Colors.white54),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
                suffixIcon: IconButton(
                  icon: Icon(Icons.casino, color: Theme.of(context).primaryColor),
                  onPressed: _generateRandomSeed,
                ),
              ),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _selectedVersionKey,
              dropdownColor: Theme.of(context).cardColor,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: l10n.worldSettingsVersion,
                labelStyle: const TextStyle(color: Colors.white54),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
              ),
              items: _versions.keys.map((key) {
                return DropdownMenuItem<String>(
                  value: key,
                  child: Text(key),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedVersionKey = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.worldSettingsCancel, style: const TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
          onPressed: _isSaving ? null : _save,
          child: _isSaving 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(isEditing ? l10n.worldSettingsSave : l10n.worldSettingsCreate, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
