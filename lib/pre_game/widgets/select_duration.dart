import 'package:google_fonts/google_fonts.dart';
import 'package:nomino/helpers/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectDuration extends StatelessWidget {
  const SelectDuration({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>().game; // listen for current value

    return Center (
      child:  Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // ➖ Minus Button
          IconButton(
            icon: const Icon(
              Icons.remove_circle_rounded,
              size: 55,
              color: Color(0xFFE46C5D), // 🔴 coral tone for decrease
            ),
            onPressed: () {
              if (game.duration > 1) {
                context.read<GameProvider>().setDuration(game.duration - 1);
              }
            },
          ),

          // ⏱️ Duration Text
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              "${game.duration} mins",
              style: TextStyle(
                fontSize: 30,
                fontFamily: GoogleFonts.playfair().fontFamily,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4C3A75), // deep purple text
                decoration: TextDecoration.none,
              ),
            ),
          ),

          // ➕ Plus Button
          IconButton(
            icon: const Icon(
              Icons.add_circle_rounded,
              size: 55,
              color: Color(0xFF4FC7C0), // 🟢 teal tone for increase
            ),
            onPressed: () {
              context.read<GameProvider>().setDuration(game.duration + 1);
            },
          ),
        ],
      ),
     );
  }
}
