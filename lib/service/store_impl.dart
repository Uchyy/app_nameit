import 'package:app_nameit/model/games.dart';
import 'package:app_nameit/model/multiplayer.dart';
import 'package:app_nameit/model/solo.dart';
import 'package:app_nameit/model/player.dart';
import 'package:app_nameit/service/store_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  Future<void> createSolo(Solo solo, String uid) async {
    try {
      await _db.collection('users').doc(uid).collection('solo').add(solo.toMap());
      print("✅ Solo added for $uid");
    } catch (e) {
      print("❌ updateSolo error: $e");
      rethrow;
    }
  }

  @override
  Future<void> createMultiplayer(Multiplay multiplay, String uid) async {
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
        if (value is Map<String, double>) {
          print("✅ Replaced all scores → $value for game: $gameCode");
        } else {
          throw ArgumentError("scores expects a Map<String, double>");
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


}
