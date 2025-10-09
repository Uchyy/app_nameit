import 'package:app_nameit/model/games.dart';
import 'package:app_nameit/model/multiplayer.dart';
import 'package:app_nameit/model/solo.dart';
import 'package:app_nameit/model/player.dart';

abstract class StoreService {
  // ✅ User creation
  Future<void> createUser(Player user);

  // ✅ Game creation and retrieval
  Future<void> createGame(FirestoreGame game);
  Stream<FirestoreGame?> streamGame(String code); // 👈 Live game updates

  // ✅ Player management
  Future<void> addPlayer(String gameCode, String playerUid);

  // ✅ Score updates
  Future<void> updateScores(String gameCode, double score);

  // ✅ Solo + Multiplayer persistence
  Future<void> updateSolo(Solo solo, String uid);
  Future<void> updateMultiplayer(Multiplay multiplay, String uid);

  //is the User the creator
  Future <bool?>  isCreator(String creator); 
}
