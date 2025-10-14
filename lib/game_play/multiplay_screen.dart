// play_multiplayer.dart

import 'package:app_nameit/game_play/widgets/game_base.dart';
import 'package:app_nameit/model/multiplayer.dart';
import 'package:flutter/material.dart';
import '../model/games.dart';
import '../service/store_impl.dart';
//import '../game_play/result_screen.dart';
//import '../misc/page_loading.dart';

class PlayMultiplayerScreen extends StatelessWidget {
  final String gameCode;
  const PlayMultiplayerScreen({super.key, required this.gameCode});

  @override
  Widget build(BuildContext context) {
    final _store = StoreImpl();

    return StreamBuilder<FirestoreGame?>(
      stream: _store.streamGame(gameCode),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final game = snapshot.data!;
        final categories = game.selectedCategories;

        return GamePlayBase(
          letter: game.selectedChar,
          minutes: game.duration,
          categories: categories,
          onSubmit: (answers) async {
            //await _store.updateGameFields("answers.${_auth.currentUser!.uid}", answers, gameCode);
            Multiplay multiplay = Multiplay(
              totalScore: 0, 
              answers: answers, 
              gameCode: gameCode, 
              markedBy: "", 
              markedWho: ""
            );

            try {
              _store.createMultiplayer(multiplay);
              debugPrint("cCreating multiplay");
            } on Exception catch (e) {
              debugPrint("Error creating multiplay doc: $e");
            }

            /*
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PageLoading(
                  first: "Checking dictionary...",
                  second: "Validating group...",
                  third: "Calculating scores...",
                  nextPage: ResultsScreen(),
                ),
              ),
            );
            */
          },
        );
      },
    );
  }
}
