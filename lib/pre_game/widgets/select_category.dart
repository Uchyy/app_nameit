import 'package:app_nameit/misc/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectCategories extends StatelessWidget {
  const SelectCategories({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<GameProvider>().game.categories;

    if (categories.isEmpty) {
      return const Text("No categories available"); // fallback
    }

    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.white, // 👈 white background
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "You can select up to 6 categories",
              style: TextStyle(
                decoration: TextDecoration.none,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 153, 140, 80), // 👈 match border color
              ),
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 8,
              children: categories.map((cat) {
                return FilterChip(
                  label: Text(cat.name),
                  selected: cat.isSelected,
                  selectedColor: const Color.fromARGB(80, 153, 140, 80), // 👈 faint fill
                  checkmarkColor: Colors.white,
                  onSelected: (_) {
                    context.read<GameProvider>().toggleCategory(cat);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );

  }
}
