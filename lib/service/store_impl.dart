import 'package:app_nameit/model/games.dart';
import 'package:app_nameit/model/multiplayer.dart';
import 'package:app_nameit/model/solo.dart';
import 'package:app_nameit/model/user.dart';
import 'package:app_nameit/service/store_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StoreImpl implements StoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<void> createGame(FirestoreGame game) async {
    try {
      await _db.collection('games').doc(game.code).set(game.toMap());
      print("✅ Game created with code: ${game.code}");
    } catch (e) {
      print("❌ createGame error: $e");
      rethrow;
    }
  }

  // 👇 Stream-based live updates for game document
  @override
  Stream<FirestoreGame?> streamGame(String code) {
    return _db
        .collection('games')
        .doc(code)
        .snapshots()
        .map((snapshot) => snapshot.exists
            ? FirestoreGame.fromMap(snapshot.data()!)
            : null);
  }

  @override
  Future<void> addPlayer(String gameCode, String playerUid) async {
    try {
      await _db.collection('games').doc(gameCode).update({
        'players': FieldValue.arrayUnion([playerUid]),
      });
      print("✅ Player added: $playerUid → $gameCode");
    } catch (e) {
      print("❌ addPlayer error: $e");
      rethrow;
    }
  }

  @override
  Future<void> updateScores(String gameCode, double score) async {
    try {
      await _db.collection('games').doc(gameCode).update({
        'scores.$gameCode': score,
      });
      print("✅ Updated score for $gameCode → $score");
    } catch (e) {
      print("❌ updateScores error: $e");
      rethrow;
    }
  }

  @override
  Future<void> createUser(User user) async {
    try {
      await _db.collection('users').doc(user.uid).set(user.toMap());
      print("✅ User created: ${user.uid}");
    } catch (e) {
      print("❌ createUser error: $e");
      rethrow;
    }
  }

  @override
  Future<void> updateSolo(Solo solo, String uid) async {
    try {
      await _db.collection('users').doc(uid).collection('solo').add(solo.toMap());
      print("✅ Solo added for $uid");
    } catch (e) {
      print("❌ updateSolo error: $e");
      rethrow;
    }
  }

  @override
  Future<void> updateMultiplayer(Multiplay multiplay, String uid) async {
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('multiplayer')
          .doc(multiplay.gameCode)
          .set(multiplay.toMap());
      print("✅ Multiplayer saved for $uid");
    } catch (e) {
      print("❌ updateMultiplayer error: $e");
      rethrow;
    }
  }
}
