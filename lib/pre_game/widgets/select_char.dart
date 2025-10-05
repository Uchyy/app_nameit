import 'dart:math';
import 'package:app_nameit/misc/game_provider.dart';
import 'package:app_nameit/styles/sub_button.dart';
import 'package:app_nameit/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectChar extends StatelessWidget {
  const SelectChar({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>().game;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Row 1: Previous / Current / Next
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle, size: 32, color: AppColors.lightRed),
              onPressed: () {
                final current = game.selectedChar.isNotEmpty
                    ? game.selectedChar.codeUnitAt(0)
                    : 'A'.codeUnitAt(0);

                final prev = current > 'A'.codeUnitAt(0)
                    ? current - 1
                    : 'Z'.codeUnitAt(0);

                context.read<GameProvider>().setSelectedChar(String.fromCharCode(prev));
              },
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                game.selectedChar.isNotEmpty ? game.selectedChar : "A",
                style: const TextStyle(
                  fontSize: 30, 
                  color: AppColors.primaryVariant,
                  fontWeight: FontWeight.bold, 
                  decoration: TextDecoration.none
                ),
              ),
            ),

            IconButton(
              icon: const Icon(Icons.add_circle, size: 32, color: AppColors.secondaryVariant),
              onPressed: () {
                final current = game.selectedChar.isNotEmpty
                    ? game.selectedChar.codeUnitAt(0)
                    : 'A'.codeUnitAt(0);

                final next = current < 'Z'.codeUnitAt(0)
                    ? current + 1
                    : 'A'.codeUnitAt(0);

                context.read<GameProvider>().setSelectedChar(String.fromCharCode(next));
              },
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Row 2: Random button
        ElevatedButton.icon(
          onPressed: () {
            final random = Random().nextInt(26); // 0–25
            final char = String.fromCharCode('A'.codeUnitAt(0) + random);
            context.read<GameProvider>().setSelectedChar(char);
          },
          style: subelevatedButtonStyle(),
          icon: const Icon(Icons.shuffle),
          label: const Text("Random Letter", style: TextStyle(fontSize: 30),),
        ),
      ],
    );
  }
}
