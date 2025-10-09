import 'package:app_nameit/game_play/waiting_room.dart';
import 'package:app_nameit/misc/custom_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MultiplayerChoice extends StatefulWidget {
  final VoidCallback onNext;
  const MultiplayerChoice({super.key, required this.onNext});

  @override
  State<MultiplayerChoice> createState() => _MultiplayerChoiceState();
}

class _MultiplayerChoiceState extends State<MultiplayerChoice> {
  bool _isJoining = false;
  final TextEditingController _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const borderColor = Color.fromARGB(255, 153, 140, 80);
    final screenWidth = MediaQuery.of(context).size.width * 0.6;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        // Create and Join Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: !_isJoining ? borderColor : Colors.white,
                foregroundColor: !_isJoining ? Colors.white : borderColor,
                side: const BorderSide(color: borderColor, width: 2),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              onPressed: () {
                setState(() => _isJoining = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Game created! Code: ABC123")),
                );
                widget.onNext();
              },
              child: const Text("CREATE"),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isJoining ? borderColor : Colors.white,
                foregroundColor: _isJoining ? Colors.white : borderColor,
                side: const BorderSide(color: borderColor, width: 2),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              onPressed: () => setState(() => _isJoining = true),
              child: const Text("JOIN"),
            ),
          ],
        ),

        const SizedBox(height: 30),

        // TextField and QR scanner (only visible if joining)
        _isJoining
          ? Material( 
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              key: const ValueKey("join_field"),
              children: [
                SizedBox(
                  width: screenWidth,
                  child: TextField(
                    controller: _codeController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: "Enter code",
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: borderColor),
                      ),
                    ),
                    onChanged: (value) async {
                      if (value.length == 6) {
                        final code = value.trim().toUpperCase();
                        final doc = await FirebaseFirestore.instance
                            .collection('games')
                            .doc(code)
                            .get();

                        if (doc.exists) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WaitingRoom(gameCode: code),
                            ),
                          );
                        } else {
                          CustomSnackbar.show(context, title: "Code not found!", message: "Please create a game instead");
                        }
                      }
                    } 
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(
                    Icons.qr_code_scanner,
                    color: borderColor,
                    size: 30,
                  ),
                  onPressed: () { },
                )
              ],
            ),
          )
        : const SizedBox.shrink(),
      ],
    );
  }
}
