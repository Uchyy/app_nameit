import 'package:nomino/helpers/game_provider.dart';
import 'package:nomino/styles/sub_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectGameMode extends StatelessWidget {
  final VoidCallback onNext;

  const SelectGameMode({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final selectedMode = gameProvider.game.mode;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // 🟣 SOLO BUTTON
          const SizedBox(height: 10),
          ElevatedButton(
            style: subelevatedButtonStyle().copyWith(
              backgroundColor: WidgetStatePropertyAll(
                selectedMode == "solo"
                    ? const Color(0xFF8A6FB3) // selected purple
                    : const Color(0xFFF5F4F0), // unselected light
              ),
              foregroundColor: WidgetStatePropertyAll(
                selectedMode == "solo" ? Colors.white : const Color(0xFF2C2C2C),
              ),
              side: const WidgetStatePropertyAll(
                BorderSide(color: Color(0xFF8A6FB3), width: 2),
              ),
              shadowColor: const WidgetStatePropertyAll(Color(0x668A6FB3)),
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

          // 🟠 MULTIPLAYER BUTTON
          ElevatedButton(
            style: subelevatedButtonStyle().copyWith(
              backgroundColor: WidgetStatePropertyAll(
                selectedMode == "multiplayer"
                    ?  Color(0xFF8A6FB3) // selected coral
                    : const Color(0xFFF5F4F0), // unselected light
              ),
              foregroundColor: WidgetStatePropertyAll(
                selectedMode == "multiplayer"
                    ? Colors.white
                    :  Color(0xFF8A6FB3),
              ),
              side: const WidgetStatePropertyAll(
                BorderSide(color:  Color(0xFF8A6FB3), width: 2),
              ),
              shadowColor: const WidgetStatePropertyAll( Color(0xFF8A6FB3)),
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
