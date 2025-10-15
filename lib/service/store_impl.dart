import 'package:app_nameit/model/games.dart';
import 'package:app_nameit/model/multiplayer.dart';
import 'package:app_nameit/model/player.dart';
import 'package:app_nameit/model/solo.dart';
import 'package:app_nameit/service/store_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StoreImpl implements StoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /* -------------------- USER -------------------- */

  /* Get the current user's UID */
  @override
  String getUserid() => _auth.currentUser!.uid;

  /* Create a new user document */
  @override
  Future<void> createUser(Player player) async {
    try {
      await _db.collection('users').doc(player.uid).set(player.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /* Check if a user's email exists in Firestore */
  @override
  Future<bool> checkIfUserEmailExist(String email) async {
    email = email.trim().toLowerCase();
    final snapshot = await _db
        .collection('users')
        .where('userEmail', isEqualTo: email)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }


  /* -------------------- GAME -------------------- */

  /* Create a new game document */
  @override
  Future<void> createGame(FirestoreGame game) async {
    try {
      await _db.collection('games').doc(game.code).set(game.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /* Stream live updates for a game (used in multiplayer flow) */
  @override
  Stream<FirestoreGame?> streamGame(String code) {
    return _db
        .collection('games')
        .doc(code)
        .snapshots()
        .map((snapshot) =>
            snapshot.exists ? FirestoreGame.fromMap(snapshot.data()!) : null);
  }

  /* Check if the current user is the game creator */
  @override
  Future<bool?> isCreator(String creator) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;
      return currentUser.uid == creator;
    } catch (e) {
      return null;
    }
  }

  /*
    Update a field in the "games" document.
    Usage examples:
      await updateGameFields('hasStarted', true, gameCode);
      await updateGameFields('scores', MapEntry(uid, 10.0), gameCode);
  */
  @override
  Future<void> updateGameFields(
      String field, dynamic value, String gameCode) async {
    try {
      final docRef = _db.collection('games').doc(gameCode);

      switch (field) {
        case 'hasStarted':
        case 'hasEnded':
          await docRef.update({field: value});
          break;

        case 'playerIds':
          await docRef.update({
            'playerIds': FieldValue.arrayUnion([getUserid()]),
          });
          break;

        case 'scores':
          if (value is MapEntry<String, double>) {
            await docRef.update({'scores.${value.key}': value.value});
          } else {
            throw ArgumentError(
                "scores expects a MapEntry<String, double> (uid → score)");
          }
          break;

        default:
          await docRef.update({field: value});
      }
    } catch (e) {
      rethrow;
    }
  }


  /* -------------------- SOLO / MULTIPLAYER -------------------- */

  /* Save solo game results under user */
  @override
  Future<void> createSolo(Solo solo) async {
    try {
      await _db
          .collection('users')
          .doc(getUserid())
          .collection('solo')
          .add(solo.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /* Save multiplayer game results under user */
  @override
  Future<void> createMultiplayer(Multiplay multiplay) async {
    try {
      await _db
          .collection('users')
          .doc(getUserid())
          .collection('multiplayer')
          .doc(multiplay.gameCode)
          .set(multiplay.toMap());
    } catch (e) {
      rethrow;
    }
  }


  /* -------------------- MULTIPLAYER SCORING -------------------- */

  /* Get a player's answers for a specific game */
  @override
  Future<Map<String, String>> getUserAnswerMultiplay(
      String code, String uid) async {
    final doc =
        await _db.collection('users').doc(uid).collection('multiplayer').doc(code).get();
    if (!doc.exists) return {};
    final data = doc.data();
    if (data == null || data['answers'] == null) return {};
    return Map<String, String>.from(data['answers'] as Map);
  }

  /* Save the total score + individual category marks */
  @override
  Future<void> setPlayerScore(String markedUid, String gameCode,
      double totalScore, Map<String, double> scores) async {
    try {
      await _db
          .collection('users')
          .doc(markedUid)
          .collection('multiplayer')
          .doc(gameCode)
          .update({
        'markedBy': getUserid(),
        'totalScore': totalScore,
        'scores': scores,
      });
    } catch (e) {
      rethrow;
    }
  }

  /* Record which player the current user has marked */
  @override
  Future<void> updateUserMultiPlayDoc(String markedUid, String gameCode) async {
    try {
      await _db
          .collection('users')
          .doc(getUserid())
          .collection('multiplayer')
          .doc(gameCode)
          .update({'markedWho': markedUid});
    } catch (e) {
      rethrow;
    }
  }

  /* Stream live updates for the user's total score */
  @override
  Stream<double> getUserScore(String gameCode) {
    final uid = getUserid();
    return _db
        .collection('users')
        .doc(uid)
        .collection('multiplayer')
        .doc(gameCode)
        .snapshots()
        .map((snap) {
      if (!snap.exists) return 0.0;
      final data = snap.data();
      if (data == null || data['totalScore'] == null) return 0.0;
      return (data['totalScore'] as num).toDouble();
    });
  }

  /* Fetch a detailed map of all category scores for the user */
  @override
  Future<Map<String, double>> getUserScoreArray(String code) async {
    final uid = getUserid();
    final doc =
        await _db.collection('users').doc(uid).collection('multiplayer').doc(code).get();
    if (!doc.exists) return {};
    final data = doc.data();
    if (data == null || data['scores'] == null) return {};
    return Map<String, double>.from(data['scores'] as Map);
  }
}
