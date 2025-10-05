import 'package:flutter/material.dart';

class GameCategory {
  final String name;
  bool isSelected;

  GameCategory({required this.name, this.isSelected = false});
}

List<GameCategory> getCategories() {
  return [
    GameCategory(name: "animal",  isSelected: true),
    GameCategory(name: "place", isSelected: true),  
    GameCategory(name: "thing",  isSelected: true),
    GameCategory(name: "food",  isSelected: true),
    GameCategory(name: "song"),
    GameCategory(name: "movies/shows"),
    GameCategory(name: "holidays"),
    GameCategory(name: "brands"),
    GameCategory(name: "emotion"),
    GameCategory(name: "colour", isSelected: true),
    GameCategory(name: "profession"),
    GameCategory(name: "body part"),
    GameCategory(name: "name", isSelected: true),    
  ];
}

IconData getIconForCategory(String name) {
  switch (name.toLowerCase()) {
    case "animal": return Icons.pets;
    case "place": return Icons.location_on;
    case "food": return Icons.fastfood;
    case "song": return Icons.music_note;
    case "movies/shows": return Icons.movie;
    case "holidays": return Icons.beach_access;
    case "brands": return Icons.shopping_bag;
    case "emotion": return Icons.mood;
    case "colour": return Icons.palette;
    case "profession": return Icons.work;
    case "body part": return Icons.accessibility_new;
    case "name": return Icons.badge;
    default: return Icons.help; // fallback
  }
}

