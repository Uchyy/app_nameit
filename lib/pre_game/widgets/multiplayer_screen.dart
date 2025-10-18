import 'package:nomino/game_play/multiplay/waiting_room.dart';
import 'package:nomino/helpers/game_provider.dart';
import 'package:nomino/helpers/qrcode.dart';
import 'package:nomino/helpers/validate_code.dart';
import 'package:nomino/misc/custom_snackbar.dart';
import 'package:nomino/misc/page_loading.dart';
import 'package:nomino/service/store_impl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MultiplayerChoice extends StatefulWidget {
  final VoidCallback onNext;
  const MultiplayerChoice({super.key, required this.onNext});

  @override
  State<MultiplayerChoice> createState() => _MultiplayerChoiceState();
}

class _MultiplayerChoiceState extends State<MultiplayerChoice> {
  bool _isJoining = false;
  final TextEditingController _codeController = TextEditingController();
  final _storeService = StoreImpl();
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFE46C5D); // 🔸 coral tone (your multiplayer color)
    final screenWidth = MediaQuery.of(context).size.width * 0.6;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 🔹 Create and Join Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // CREATE
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: !_isJoining ? borderColor : Colors.white,
                foregroundColor: !_isJoining ? Colors.white : borderColor,
                side: const BorderSide(color: borderColor, width: 2),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: !_isJoining ? 4 : 0,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              onPressed: () {
                setState(() => _isJoining = false);
                context.read<GameProvider>().setIsJoining(false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Game created! Code: ABC123")),
                );
                widget.onNext();
              },
              child: const Text("CREATE"),
            ),

            const SizedBox(width: 20),

            // JOIN
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isJoining ? borderColor : Colors.white,
                foregroundColor: _isJoining ? Colors.white : borderColor,
                side: const BorderSide(color: borderColor, width: 2),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: _isJoining ? 4 : 0,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              onPressed: () {
                setState(() => _isJoining = true);
                context.read<GameProvider>().setIsJoining(true);
              },  
              child: const Text("JOIN"),
            ),
          ],
        ),

        const SizedBox(height: 30),

        // 🔹 TextField + QR Scanner (only visible if joining)
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isJoining
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
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: "Enter code",
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 16,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 10,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: borderColor, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: borderColor.withOpacity(0.8),
                            width: 3,
                          ),
                        ),
                      ),
                      onChanged: (value) async {
                        final trimmed = value.trim().toUpperCase();
                        context.read<GameProvider>().setJoinCode(trimmed);
                        await _goToGame(context, value);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(
                      Icons.qr_code_scanner,
                      color: borderColor,
                      size: 32,
                    ),
                    onPressed: () async {
                      final scannedCode = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const QRScanScreen()),
                      );
                      debugPrint("Scanned code is : $scannedCode");
                      if (scannedCode != null && scannedCode.isNotEmpty) {
                        //_codeController.text = scannedCode;
                        final code = scannedCode.trim().toUpperCase();
                        _codeController.text = code;
                        context.read<GameProvider>().setJoinCode(code);
                        debugPrint('✅ Scanned Game Code: $scannedCode');
                        await _goToGame(context, code);
                       //await _goToGame(context, scannedCode);
                      }
                    },
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Future<void> _goToGame(BuildContext context, String value) async {
    if (value.isEmpty) return;

    final isValid = await validateJoinCode(context, value);
    if (!isValid) return;

    final code = value.trim().toUpperCase();

    try {
      debugPrint("✅ FIRESTORE - ADDING PLAYER TO GAME SESSION");
      await _storeService.updateGameFields(
        "playerIds",
        _auth.currentUser!.uid,
        code,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PageLoading(
            first: "Getting game session...",
            second: "Adding you to the game...",
            third: "Loading waiting room...",
            nextPage: WaitingRoom(gameCode: code),
          ),
        ),
      );
    } catch (e) {
      debugPrint("❌ ERROR ADDING PLAYER: $e");
      CustomSnackbar.show(
        context,
        title: "ERROR: Join Failed",
        message: "Could not add player to the game. Please try again.",
      );
    }
  }

}
