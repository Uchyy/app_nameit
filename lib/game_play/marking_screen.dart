import 'package:app_nameit/main.dart';
import 'package:app_nameit/misc/curved_button.dart';
import 'package:app_nameit/misc/custom_snackbar.dart';
import 'package:app_nameit/model/games.dart';
import 'package:app_nameit/service/store_impl.dart';
import 'package:app_nameit/theme/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  //Map<String, double> _scores = {};
  String? uidMarked;
  bool _loading = true;
  String? selectedChar;
  bool _hasSubmitted = false;


  @override
  void initState() {
    super.initState();
    _hasSubmitted = false;
    _loadMarkingData();
  }

  /// Fetches the player list once, determines who this user should mark,
  /// then fetches that player's answers.
  Future<void> _loadMarkingData() async {
  try {
    final uid = _store.getUserid();

    // 1️⃣ Get game document
    final doc = await _db.collection('games').doc(widget.code).get();
    if (!doc.exists) {
      debugPrint("❌ Game not found for code ${widget.code}");
      setState(() => _loading = false);
      return;
    }

    // 2️⃣ Parse game + find next player
    final game = FirestoreGame.fromMap(doc.data()!);
    setState(() => selectedChar = game.selectedChar);

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
    setState(() => uidMarked = targetUid);

    // 4️⃣ Start listening for when the target player's answers are ready
    _db
        .collection('users')
        .doc(targetUid)
        .collection('multiplayer')
        .doc(widget.code)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) {
        debugPrint("⏳ Waiting for $targetUid to finish...");
        setState(() {
          _answersToMark = null;
          _loading = false;
        });
      } else {
        final data = snapshot.data();
        if (data != null && data['answers'] != null) {
          final answers = Map<String, String>.from(data['answers']);
          debugPrint("✅ Answers ready for marking!");
          setState(() {
            _answersToMark = answers;
            _loading = false;
          });
        }
      }
    });
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

    if (_answersToMark == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                "Waiting for the other player to finish...",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
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
          
          child:
          
          Column(
            children: [
              Expanded(
                child: ListView(
                  children: _answersToMark!.entries.map((entry) {
                    final category = entry.key;
                    final answer = entry.value;

                    final isInvalid = answer.isEmpty || !answer.toUpperCase().startsWith(selectedChar!.toUpperCase());
                    if (isInvalid) _marks[category] = 0;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          category,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
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
                            IconButton(
                              icon: Icon(Icons.help,
                                  color: isInvalid ? Colors.grey : Colors.orange),
                              onPressed: isInvalid
                                  ? null
                                  : () {
                                      setState(() => _marks[category] = 0.5);
                                    },
                            ),
                            IconButton(
                              icon: Icon(Icons.close,
                                  color: isInvalid ? Colors.grey : Colors.red),
                              onPressed: isInvalid
                                  ? null
                                  : () {
                                      setState(() => _marks[category] = 0.0);
                                    },
                            ),
                            IconButton(
                              icon: Icon(Icons.check,
                                  color: isInvalid ? Colors.grey : Colors.green),
                              onPressed: isInvalid
                                  ? null
                                  : () {
                                      setState(() => _marks[category] = 1.0);
                                    },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            
              StreamBuilder<double>(
                stream: _store.getUserScore(widget.code),
                builder: (context, snapshot) {
                  // handle error and waiting inline with ? :
                  return snapshot.connectionState == ConnectionState.waiting
                    ? _buildStatusCard(
                        context,
                        title: "Your score is being marked",
                        trailing: const CircularProgressIndicator(color: Colors.white),
                        color: AppColors.secondary,
                      )
                    : snapshot.hasError
                      ? _buildStatusCard(
                          context,
                          title: "Something went wrong",
                          trailing: const Icon(Icons.error, color: Colors.white),
                          color: AppColors.lightRed,
                        )
                      : snapshot.hasData
                        ? _buildStatusCard(
                          context,
                          title: "Your score is ready",
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.secondaryVariant,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () =>
                                _showScoreDialog(context, snapshot.data ?? 0.0),
                            child: const Text(
                              "See Full Results",
                               style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          color: AppColors.secondaryVariant,
                        )
                        : _buildStatusCard(
                          context,
                          title: "Waiting for your score",
                          trailing:
                              const CircularProgressIndicator(color: Colors.white),
                          color: AppColors.secondary,
                        );
                      },
                    )
            ],
          ) 
        ),

        bottomNavigationBar:  _hasSubmitted 
          ? Padding(
            padding: const EdgeInsets.only(bottom: 25),
            child: CurvedButton(
              leftLabel: "RULES",
              rightLabel: "CLOSE",
              onLeftPressed: () => _showRulesDialog(context),
              onRightPressed: _goToHome,
            ),
          )
          : Padding (
              padding: const EdgeInsets.only(bottom: 25),
              child: CurvedButton(
                leftLabel: "RULES",
                rightLabel: "SUBMIT",
                onLeftPressed: () => _showRulesDialog(context),
                onRightPressed: () => _showSubmitDialog(context)
            ),
          )
      ),
    ); 
  }

  void _goToHome () {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const Nomino()),
      (route) => false,
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
          "Give each answer a fair score.\n\n\n"
          "✅ If it’s clearly correct, give full marks.\n\n"
          "❓ If you’re unsure or spelling is incorrect, go with about 50%.\n\n"
          "❌ Leave it at zero if it’s blank or incorrect. For example, foppy is not a type of animal.\n\n\n"
          "Keep it fun and fair!\n",
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
              Navigator.pop(context);
              await _store.updateGameFields(
                'scores',
                MapEntry<String, double>(uidMarked!, totalScore),
                widget.code,
              );
              await _store.updateUserMultiPlayDoc(uidMarked!, widget.code);
              await _store.setPlayerScore(uidMarked!, widget.code, totalScore, _marks);
              setState(() { _hasSubmitted = true; });

              CustomSnackbar.show(context, title: 'Marking Sucessful', message: 'Sent to Player!');
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

 Widget _buildStatusCard(
    BuildContext context, {
    required String title,
    required Widget trailing,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            trailing,
          ],
        ),
      ),
    );
  }


  void _showScoreDialog(BuildContext context, double score) async {
    final answers = await _store.getUserAnswerMultiplay(widget.code, _store.getUserid());
    final scoreArr = await _store.getUserScoreArray(widget.code);

    // Prepare and sort entries by score descending
    final sortedEntries = answers.entries
        .map((entry) {
          final category = entry.key;
          final answer = entry.value;
          final scoreValue = scoreArr[category] ?? 0.0;
          return {
            'category': category,
            'answer': answer,
            'score': scoreValue,
          };
        })
        .toList()
      ..sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.only(top: 20, bottom: 0),
        title: Center(
          child: Text(
            "${(score / 6 * 100).toStringAsFixed(1)}%",
            style: GoogleFonts.playfairDisplay(
              fontSize: 38,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryVariant,
            ),
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedEntries.length,
                itemBuilder: (_, index) {
                  final item = sortedEntries[index];
                  return _buildScoreRow(
                    item['category'] as String,
                    item['answer'] as String,
                    item['score'] as double,
                  );
                },
              ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppColors.primaryVariant,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow(String category, String answer, double scoreValue) {
    final color = scoreValue == 1.0
        ? Colors.green
        : scoreValue == 0.5
            ? Colors.orange
            : Colors.red;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  category,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  answer.isEmpty ? "No answer" : answer,
                  style: TextStyle(
                    fontStyle: answer.isEmpty ? FontStyle.italic : FontStyle.normal,
                    color: answer.isEmpty ? Colors.red : Colors.black87,
                  ),
                ),
              ),
              Text(
                "${(scoreValue * 100).toStringAsFixed(0)}%",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        Divider(
          color: AppColors.secondary.withOpacity(0.5),
          thickness: 1,
          height: 0,
          indent: 12,
          endIndent: 12,
        ),
      ],
    );
  }

}
