import 'package:app_nameit/model/games.dart';
import 'package:app_nameit/model/multiplayer.dart';
import 'package:app_nameit/model/solo.dart';
import 'package:app_nameit/model/player.dart';
import 'package:app_nameit/service/store_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart';

class StoreImpl implements StoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String getUserid ()  {
    return  _auth.currentUser!.uid;
  }

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
  Future<void> createUser(Player player) async {
    try {
      await _db.collection('users').doc(player.uid).set(player.toMap());
      print("✅ User created: ${player.uid}");
    } catch (e) {
      print("❌ createUser error: $e");
      rethrow;
    }
  }

  @override
  Future<void> createSolo(Solo solo) async {
    final uid = getUserid();
    try {
      await _db.collection('users').doc(uid).collection('solo').add(solo.toMap());
      print("✅ Solo added for $uid");
    } catch (e) {
      print("❌ updateSolo error: $e");
      rethrow;
    }
  }

  @override
  Future<void> createMultiplayer(Multiplay multiplay) async {
    final uid = getUserid();
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

  @override
  Future<bool?> isCreator(String creator) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return null; // not logged in

      return currentUser.uid == creator;

      // or if you store emails instead of UIDs:
      // return currentUser.email == creator;
    } catch (e) {
      print("❌ Failed to check creator: $e");
      return null;
    }
  }
  
/*
  Updates specific fields within a Firestore "games" document.

  Handles all updateable fields explicitly:
    • hasStarted, hasEnded  → bool
    • playerIds             → List<String> (using FieldValue)
    • scores                → Map<String, double>
    • selectedCategories    → List<String>

  @param field     The field or nested path to update.
  @param value     The new value or Firestore FieldValue operation.
  @param gameCode  The gameCode document ID.

  Usage:
  await updateGameField( gameCode, 'scores',MapEntry(currentUserId, 75.0), );

*/
@override
Future<void> updateGameFields(String field, dynamic value, String gameCode) async {
  try {
    final docRef = _db.collection('games').doc(gameCode);

    switch (field) {
      case 'hasStarted':
      case 'hasEnded':
        await docRef.update({field: value});
        break;

      case 'playerIds':
        await _db.collection('games').doc(gameCode).update({
        'playerIds': FieldValue.arrayUnion([getUserid()]),
      });
        break;

      case 'scores':
        if (value is MapEntry<String, double>) {
          final uid = value.key;
          final score = value.value;

          await _db.collection('games').doc(gameCode).update({
            'scores.$uid': score, // 👈 updates only that player’s score
          });

          print("✅ Updated score for $uid → $score in game: $gameCode");
        } else {
          throw ArgumentError("scores expects a MapEntry<String, double> (uid → score)");
        }
        break;


      default:
        print("⚠️ Unknown field '$field'. Updating directly as fallback.");
        await docRef.update({field: value});    
    }
    print("✅ Updated $field → $value for game: $gameCode");

  } catch (e) {
    print("❌ updateGameFields error: $e");
    rethrow;
  }
}


  @override
  Future<bool> checkIfUserEmailExist(String email) async {
    email = email.trim().toLowerCase();

    // Check Firestore first
    final firestoreSnapshot = await _db
        .collection('users')
        .where('userEmail', isEqualTo: email)
        .limit(1)
        .get();

    if (firestoreSnapshot.docs.isNotEmpty) {
      return true;
    }

    return false;
  }

  Future<Map<String, String>> getUserAnswerMultiplay(String code, String uid) async {

    final doc = await _db
        .collection('users')
        .doc(uid)
        .collection('multiplayer')
        .doc(code)
        .get();

    if (!doc.exists) {
      return {}; // empty map if no data
    }

    final data = doc.data();
    if (data == null || data['answers'] == null) {
      return {};
    }

    // Ensure values are Strings (Firestore maps can be dynamic)
    final answers = Map<String, String>.from(data['answers'] as Map);

    return answers;
  }

  Future<void> setPlayerScore(String markedUid, String gameCode, double totalScore, Map <String, double> scores) async {
    final uid = getUserid();
    try {

      await _db
          .collection('users')
          .doc(markedUid)
          .collection('multiplayer')
          .doc(gameCode)
          .update({
        'markedBy': uid,
        'totalScore': totalScore,
        'scores': scores,
      });

      print("✅ Updated score for $markedUid → $totalScore");
    } catch (e) {
      print("❌ Error updating player score: $e");
      rethrow;
    }
  }

  Future<void> updateUserMultiPlayDoc (String markedUid, String gameCode) async {
    final uid = getUserid();
    try {

      await _db
          .collection('users')
          .doc(uid)
          .collection('multiplayer')
          .doc(gameCode)
          .update({
        'markedWho': markedUid,
      });

      print("✅ Updated score for marekdWho → $markedUid");
    } catch (e) {
      print("❌ Error updating player score: $e");
      rethrow;
    }
  }

  Stream<double> getUserScore(String gameCode) {
    final uid = getUserid();

    return _db
        .collection('users')
        .doc(uid)
        .collection('multiplayer')
        .doc(gameCode)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return 0.0;
          final data = snapshot.data();
          if (data == null || data['totalScore'] == null) return 0.0;
          return (data['totalScore'] as num).toDouble();
        });
  }

   Future<Map<String, double>> getUserScoreArray(String code) async {
    final uid = getUserid();
    final doc = await _db
        .collection('users')
        .doc(uid)
        .collection('multiplayer')
        .doc(code)
        .get();

    if (!doc.exists) {
      return {}; // empty map if no data
    }

    final data = doc.data();
    if (data == null || data['scores'] == null) {
      return {};
    }

    // Ensure values are Strings (Firestore maps can be dynamic)
    final scores = Map<String, double>.from(data['scores'] as Map);

    return scores;
  }

}
