import 'package:flutter/material.dart';
import 'package:minecraft_seedwalker_mobile/l10n/app_localizations.dart';
import '../../../core/ffi/cubiomes_finders.dart' show StructureType;

class StructureUiHelper {
  static String getName(BuildContext context, int type) {
    final l10n = AppLocalizations.of(context)!;
    final isEs = l10n.localeName == 'es';
    
    if (type == -1) return l10n.mapScreenSpawn;
    if (type == -2) return l10n.mapScreenFilterWaypoints;
    
    switch (type) {
      case StructureType.Desert_Pyramid: return isEs ? "Pirámide del Desierto" : "Desert Pyramid";
      case StructureType.Jungle_Temple: return isEs ? "Templo de la Jungla" : "Jungle Temple";
      case StructureType.Swamp_Hut: return isEs ? "Cabaña de Bruja" : "Swamp Hut";
      case StructureType.Igloo: return isEs ? "Iglú" : "Igloo";
      case StructureType.Village: return isEs ? "Aldea" : "Village";
      case StructureType.Ocean_Ruin: return isEs ? "Ruinas Oceánicas" : "Ocean Ruin";
      case StructureType.Shipwreck: return isEs ? "Barco Hundido" : "Shipwreck";
      case StructureType.Monument: return isEs ? "Monumento Oceánico" : "Ocean Monument";
      case StructureType.Mansion: return isEs ? "Mansión del Bosque" : "Woodland Mansion";
      case StructureType.Outpost: return isEs ? "Puesto de Saqueadores" : "Pillager Outpost";
      case StructureType.Ruined_Portal: return isEs ? "Portal en Ruinas" : "Ruined Portal";
      case StructureType.Ruined_Portal_N: return isEs ? "Portal del Nether" : "Nether Portal";
      case StructureType.Ancient_City: return isEs ? "Ciudad Antigua" : "Ancient City";
      case StructureType.Treasure: return isEs ? "Tesoro Enterrado" : "Buried Treasure";
      case StructureType.Mineshaft: return isEs ? "Mina Abandonada" : "Mineshaft";
      case StructureType.Desert_Well: return isEs ? "Pozo del Desierto" : "Desert Well";
      case StructureType.Geode: return isEs ? "Geoda de Amatista" : "Amethyst Geode";
      case StructureType.Fortress: return isEs ? "Fortaleza del Nether" : "Nether Fortress";
      case StructureType.Bastion: return isEs ? "Bastión en Ruinas" : "Bastion Remnant";
      case StructureType.End_City: return isEs ? "Ciudad del End" : "End City";
      case StructureType.End_Gateway: return isEs ? "Portal del End" : "End Gateway";
      case StructureType.Trail_Ruins: return isEs ? "Ruinas de Sendero" : "Trail Ruins";
      case StructureType.Trial_Chamber: return isEs ? "Cámara de Pruebas" : "Trial Chamber";
      default: return l10n.mapScreenStructure;
    }
  }

  static IconData getIcon(int type) {
    if (type == -1) return Icons.star;
    if (type == -2) return Icons.flag;
    switch (type) {
      case StructureType.Desert_Pyramid: return Icons.account_balance;
      case StructureType.Jungle_Temple: return Icons.account_balance;
      case StructureType.Swamp_Hut: return Icons.home;
      case StructureType.Igloo: return Icons.ac_unit;
      case StructureType.Village: return Icons.home_work;
      case StructureType.Ocean_Ruin: return Icons.broken_image;
      case StructureType.Shipwreck: return Icons.sailing;
      case StructureType.Monument: return Icons.water;
      case StructureType.Mansion: return Icons.domain;
      case StructureType.Outpost: return Icons.tour;
      case StructureType.Ruined_Portal: return Icons.door_front_door;
      case StructureType.Ruined_Portal_N: return Icons.door_front_door;
      case StructureType.Ancient_City: return Icons.castle;
      case StructureType.Treasure: return Icons.diamond;
      case StructureType.Mineshaft: return Icons.train;
      case StructureType.Desert_Well: return Icons.water_drop;
      case StructureType.Geode: return Icons.diamond_outlined;
      case StructureType.Fortress: return Icons.fort;
      case StructureType.Bastion: return Icons.shield;
      case StructureType.End_City: return Icons.location_city;
      case StructureType.End_Gateway: return Icons.change_history;
      case StructureType.Trail_Ruins: return Icons.search;
      case StructureType.Trial_Chamber: return Icons.key;
      default: return Icons.help_outline;
    }
  }

  static Color getColor(int type) {
    if (type == -1) return Colors.redAccent;
    if (type == -2) return const Color(0xFF00E676);
    switch (type) {
      case StructureType.Desert_Pyramid: return const Color(0xFFEEDB87);
      case StructureType.Jungle_Temple: return const Color(0xFF6C9657);
      case StructureType.Swamp_Hut: return const Color(0xFF42562D);
      case StructureType.Igloo: return const Color(0xFFFFFFFF);
      case StructureType.Village: return const Color(0xFFFF9800);
      case StructureType.Ocean_Ruin: return const Color(0xFF55BDB5);
      case StructureType.Shipwreck: return const Color(0xFF8D6E63);
      case StructureType.Monument: return const Color(0xFF00BCD4);
      case StructureType.Mansion: return const Color(0xFF795548);
      case StructureType.Outpost: return const Color(0xFF424242);
      case StructureType.Ruined_Portal: return const Color(0xFF9C27B0);
      case StructureType.Ruined_Portal_N: return const Color(0xFF9C27B0);
      case StructureType.Ancient_City: return const Color(0xFF0F3E4A);
      case StructureType.Treasure: return const Color(0xFFFFC107);
      case StructureType.Mineshaft: return const Color(0xFF795548);
      case StructureType.Desert_Well: return const Color(0xFFEEDB87);
      case StructureType.Geode: return const Color(0xFFBA68C8);
      case StructureType.Fortress: return const Color(0xFF4E342E);
      case StructureType.Bastion: return const Color(0xFF424242);
      case StructureType.End_City: return const Color(0xFF9C27B0);
      case StructureType.End_Gateway: return const Color(0xFF000000);
      case StructureType.Trail_Ruins: return const Color(0xFF795548);
      case StructureType.Trial_Chamber: return const Color(0xFF607D8B);
      default: return Colors.grey;
    }
  }
}
