import 'package:app_nameit/helpers/game_provider.dart';
import 'package:app_nameit/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectDuration extends StatelessWidget {
  const SelectDuration({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>().game; // listen for current value

     return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Minus Button
        IconButton(
          icon: const Icon(Icons.remove_circle, size: 32, color: AppColors.lightRed),
          onPressed: () {
            if (game.duration > 1) {
              context.read<GameProvider>().setDuration(game.duration - 1);
            }
          },
        ),

        // Current Duration Text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "${game.duration} mins",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
          ),
        ),

        // Plus Button
        IconButton(
          icon: const Icon(Icons.add_circle, size: 32, color: AppColors.secondaryVariant),
          onPressed: () {
            context.read<GameProvider>().setDuration(game.duration + 1);
          },
        ),
      ],
    );
  }
}
