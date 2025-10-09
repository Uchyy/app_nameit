import 'package:app_nameit/game_play/play_solo.dart';
import 'package:app_nameit/model/games.dart';
import 'package:app_nameit/service/store_impl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WaitingRoom extends StatefulWidget {
  final String gameCode;

  const WaitingRoom({super.key, required this.gameCode});

  @override
  State<WaitingRoom> createState() => _WaitingRoomState();
}

class _WaitingRoomState extends State<WaitingRoom> {
  final ScrollController _scrollController = ScrollController();
  final _store = StoreImpl();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF1ED),
      appBar: AppBar(
        title: const Text("Waiting Room"),
        centerTitle: true,
        backgroundColor: const Color(0xFF717744),
      ),
      body: StreamBuilder<FirestoreGame?>(
        stream: _store.streamGame(widget.gameCode),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Game not found"));
          }

          final game = snapshot.data!;

          //if (game.hasEnded ) {}

          // If the game has started, navigate immediately
          if (game.hasStarted && !game.hasEnded) {
            Future.microtask(() {
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GamePlayScreen(minutes: game.duration),
                  ),
                );
              }
            });
          }

          return _buildWaitingUI(context, game);
        },
      ),
    );
  }

  Widget _buildWaitingUI(BuildContext context, FirestoreGame game) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ===== QR CODE + Code =====
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF717744).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF717744), width: 2),
              ),
              child: const Center(
                child: Text(
                  "QR CODE",
                  style: TextStyle(color: Color(0xFF717744)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  game.code,
                  style: TextStyle(
                    fontFamily: GoogleFonts.comfortaa().fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: const Color(0xFF373D20),
                    letterSpacing: 2,
                  ),
                ),
                IconButton(
                  iconSize: 25,
                  onPressed: () {}, 
                  icon: Icon(Icons.share)),
              ],
            ),

            const SizedBox(height: 10),

            // ===== Players Section =====
            StreamBuilder<FirestoreGame?>(
              stream: _store.streamGame(widget.gameCode),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text("Waiting for players..."));
                }

                final game = snapshot.data!;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ===== Header =====
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Players",
                            style: TextStyle(
                              fontFamily: GoogleFonts.lato().fontFamily,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: const Color(0xFF373D20),
                            ),
                          ),
                          Text(
                            "#${game.playerIds.length}",
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),

                      Divider(color: Colors.grey.shade400),
                      const SizedBox(height: 10),

                      // ===== Horizontal Player List =====
                      SizedBox(
                        height: 90,
                        child: ListView.builder(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount: game.playerIds.length,
                          itemBuilder: (context, index) {
                            final player = game.playerIds[index];
                            return Container(
                              width: 90,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF1ED),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF717744).withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: const Color(0xFF717744).withOpacity(0.3),
                                    radius: 20,
                                    child: Text(
                                      player[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Color(0xFF373D20),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    player,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF373D20),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),


            const SizedBox(height: 10),

            // ===== Info Card =====
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Game Info",
                    style: TextStyle(
                      fontFamily: GoogleFonts.lato().fontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: const Color(0xFF373D20),
                    ),
                  ),
                  Divider(color: Colors.grey.shade400),
                  const SizedBox(height: 10),
                  _infoRow("Created by", game.createdBy),
                  _divider(),
                  _infoRow("Selected Char", game.selectedChar),
                  _divider(),
                  _infoRow("Categories", game.selectedCategories.join(', ')),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // ===== Start Button (creator only) =====
            FutureBuilder<bool?>(
              future: _store.isCreator(game.createdBy),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final isCreator = snapshot.data ?? false;
                if (!isCreator) return const SizedBox.shrink();

                return ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('games')
                        .doc(game.code)
                        .update({'hasStarted': true});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF717744),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  label: const Text(
                    "Start Game",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }


  Widget _infoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120, // fixed label width
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF717744),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    ),
  );
}

Widget _divider() => Divider(color: Colors.grey.shade300, height: 10);

}
