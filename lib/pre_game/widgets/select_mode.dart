import 'package:app_nameit/helpers/game_provider.dart';
import 'package:app_nameit/styles/sub_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectGameMode extends StatelessWidget {
  final VoidCallback onNext;

  const SelectGameMode({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final selectedMode = gameProvider.game.mode;
    final selectedColor = const Color(0xFF717744);
    final unselectedColor = Colors.grey.shade300;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ElevatedButton(
            style: subelevatedButtonStyle().copyWith(
              backgroundColor: WidgetStatePropertyAll(
                selectedMode == "solo" ? selectedColor : unselectedColor,
              ),
              foregroundColor: WidgetStatePropertyAll(
                selectedMode == "solo" ? Colors.white : Colors.black,
              ),
            ),
            onPressed: () {
              context.read<GameProvider>().setMode("solo");
              onNext();
            },
            child: const Text(
              "SOLO",
              style: TextStyle(fontSize: 20, letterSpacing: 2),
            ),
          ),

          const SizedBox(height: 15),

          ElevatedButton(
            style: subelevatedButtonStyle().copyWith(
              backgroundColor: WidgetStatePropertyAll(
                selectedMode == "multiplayer" ? selectedColor : unselectedColor,
              ),
              foregroundColor: WidgetStatePropertyAll(
                selectedMode == "multiplayer" ? Colors.white : Colors.black,
              ),
            ),
            onPressed: () {
              context.read<GameProvider>().setMode("multiplayer");
              onNext();
            },
            child: const Text(
              "MULTIPLAYER",
              style: TextStyle(fontSize: 20, letterSpacing: 2),
            ),
          ),
        ],
      ),
    );
  }
}
