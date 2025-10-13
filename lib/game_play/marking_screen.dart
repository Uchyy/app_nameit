import 'package:app_nameit/game_play/multiplay_Result.dart';
import 'package:app_nameit/misc/curved_button.dart';
import 'package:app_nameit/misc/page_loading.dart';
import 'package:app_nameit/model/games.dart';
import 'package:app_nameit/service/store_impl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MarkingScreen extends StatefulWidget {
  final String code;
  const MarkingScreen({super.key, required this.code});

  @override
  State<MarkingScreen> createState() => _MarkingScreenState();
}

class _MarkingScreenState extends State<MarkingScreen> {
  final _db = FirebaseFirestore.instance;
  final _store = StoreImpl();

  Map<String, String>? _answersToMark;
  Map<String, double> _marks = {};
  String? uidMarked;
  bool _loading = true;
  String? selectedChar;


  @override
  void initState() {
    super.initState();
    _loadMarkingData();
  }

  /// Fetches the player list once, determines who this user should mark,
  /// then fetches that player's answers.
  Future<void> _loadMarkingData() async {
    try {
      final uid = _store.getUserid();

      // 1️⃣ Get the game document
      final doc = await _db.collection('games').doc(widget.code).get();
      if (!doc.exists) {
        debugPrint("❌ Game not found for code ${widget.code}");
        setState(() => _loading = false);
        return;
      }

      // 2️⃣ Parse and extract players
      final game = FirestoreGame.fromMap(doc.data()!);
      setState(() {
        selectedChar = game.selectedChar;
      });
      final players = game.playerIds;
      final myIndex = players.indexOf(uid);


      if (myIndex == -1) {
        debugPrint("⚠️ Current user not in playerIds list");
        setState(() => _loading = false);
        return;
      }

      // 3️⃣ Determine who this player will mark (next player or first)
      final targetIndex = (myIndex == players.length - 1) ? 0 : myIndex + 1;
      final targetUid = players[targetIndex];
      setState(() {
        uidMarked = targetUid;
      });

      // 4️⃣ Fetch that player’s answers once
      final answers = await _store.getUserAnswerMultiplay(widget.code, targetUid);

      // 5️⃣ Save to state
      if (mounted) {
        setState(() {
          _answersToMark = answers;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint("❌ Error loading marking data: $e");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_answersToMark == null || _answersToMark!.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No answers to mark")),
      );
    }

    return PopScope(
      canPop: false,
      child:  Scaffold(
        appBar: AppBar(
          title: const Text("Mark Answers"),
          centerTitle: true,

        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: _answersToMark!.entries.map((entry) {
              final category = entry.key;
              final answer = entry.value;

              // auto-validate empty or wrong-starting answers
              final isInvalid = answer.isEmpty || !answer.toUpperCase().startsWith(selectedChar!.toUpperCase());
              if (isInvalid) _marks[category] = 0;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(category, style: TextStyle(fontWeight: FontWeight.bold),),
                  subtitle: Text(
                    answer.isEmpty ? "No answer" : answer,
                    style: TextStyle(
                      color: isInvalid ? Colors.red : Colors.black87,
                      fontStyle: isInvalid ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 50%
                      IconButton(
                        icon: Icon(Icons.help, color: isInvalid ? Colors.grey : Colors.orange),
                        onPressed: isInvalid ? null : () {
                          setState(() => _marks[category] = 0.5);
                          debugPrint("MARKS - ${_marks.toString()}");
                        },
                      ),
                      // 0%
                      IconButton(
                        icon: Icon(Icons.close, color: isInvalid ? Colors.grey : Colors.red),
                        onPressed: isInvalid ? null : () {
                          setState(() => _marks[category] = 0.0);
                          debugPrint("MARKS - ${_marks.toString()}");
                        },
                      ),
                      // 100%
                      IconButton(
                        icon: Icon(Icons.check, color: isInvalid ? Colors.grey : Colors.green),
                        onPressed: isInvalid ? null : () {
                          setState(() => _marks[category] = 1.0);
                          debugPrint("MARKS - ${_marks.toString()}");
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(bottom: 25),
          child: CurvedButton(
            leftLabel: "RULES",
            rightLabel: "SUBMIT",
            onLeftPressed: () => _showRulesDialog(context),
            onRightPressed: () => _showSubmitDialog(context),
          ),
        ),
      ),
    ); 
  }

  /// Shows the game rules
  void _showRulesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            "Game Rules",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.green[700],
            ),
          ),
        ),
        content: const Text(
          "Give each answer a fair score.\n\n"
          "✅ If it’s clearly correct, give full marks.\n"
          "❓ If you’re unsure, go with about 50%.\n"
          "❌ Leave it at zero if it’s blank or doesn’t start with the right letter.\n\n"
          "Keep it fun and fair!",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: Colors.black87,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Text("Got it!", style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows the confirmation dialog before submitting marks
  void _showSubmitDialog(BuildContext context) {
    final totalScore = _marks.values.fold(0.0, (sum, value) => sum + value);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Submit Marks?"),
        content: const Text(
          "Are you sure you want to submit your markings? "
          "You won’t be able to change them after submission.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _store.updateGameFields(
                'scores',
                MapEntry<String, double>(uidMarked!, totalScore),
                widget.code,
              );
              await _store.updateUserMultiPlayDoc(uidMarked!, widget.code);
              await _store.setPlayerScore(uidMarked!, widget.code, totalScore);

               Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PageLoading(
                  second: 'Submitting your markings...', 
                  third: 'Getting your scores.....', 
                  first: 'Finalizing.....', 
                  nextPage: MultiplayResult(score: totalScore, letter: selectedChar!, gameCode: widget.code,),  
                )),
              );
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

}
