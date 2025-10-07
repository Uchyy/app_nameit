import 'package:app_nameit/helpers/game_provider.dart';
import 'package:app_nameit/styles/sub_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class SelectGameMode extends StatefulWidget {
  final VoidCallback onNext;

  const SelectGameMode({super.key, required this.onNext,});

  @override
  SelectGameModeState createState() => SelectGameModeState();
}

class SelectGameModeState extends State<SelectGameMode> {
  @override
  Widget build(BuildContext context) {
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ElevatedButton(
            style: subelevatedButtonStyle(),
            onPressed: () => {
              context.read<GameProvider>().setMode("solo"),
              widget.onNext()
            }, 
            child: const Text(
              "SOLO",
              style: TextStyle(fontSize: 18), // 👈 overrides just for this button
            ),
          ),

          const SizedBox(height: 15,),
          ElevatedButton(
            style: subelevatedButtonStyle(),
            onPressed: () => {
              context.read<GameProvider>().setMode("multiplayer"),
              widget.onNext()
            }, 
            child: const Text(
              "MULTIPLAYER",
              style: TextStyle(fontSize: 18), // 👈 overrides just for this button
            ),
          )
        ],
      ),
    );
  }

}