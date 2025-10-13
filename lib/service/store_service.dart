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

  // ✅ Solo + Multiplayer persistence
  Future<void> createSolo(Solo solo, String uid);
  Future<void> createMultiplayer(Multiplay multiplay, String uid);

  //is the User the creator
  Future <bool?>  isCreator(String creator); 

  Future <void> updateGameFields (String value, String field, String gameCode);
  Future<bool> checkIfUserEmailExist(String email);
}
