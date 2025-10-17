import 'package:nomino/model/games.dart';
import 'package:nomino/model/multiplayer.dart';
import 'package:nomino/model/player.dart';
import 'package:nomino/model/solo.dart';

abstract class StoreService {
  /* -------------------- USER -------------------- */

  /* Create a new user document */
  Future<void> createUser(Player user);

  /* Check if user email already exists */
  Future<bool> checkIfUserEmailExist(String email);

  /* Get the current user's UID */
  String getUserid();


  /* -------------------- GAME -------------------- */

  /* Create a new game document */
  Future<void> createGame(FirestoreGame game);

  /* Stream live updates for a specific game */
  Stream<FirestoreGame?> streamGame(String code);

  /* Check if the user is the creator of a game */
  Future<bool?> isCreator(String creator);

  /* Update a specific field in the game document */
  Future<void> updateGameFields(String value, String field, String gameCode);


  /* -------------------- SOLO / MULTIPLAYER -------------------- */

  /* Create a solo game record */
  Future<void> createSolo(Solo solo);

  /* Create a multiplayer record */
  Future<void> createMultiplayer(Multiplay multiplay);


  /* -------------------- MULTIPLAYER SCORING -------------------- */

  /* Fetch user answers in a multiplayer game */
  Future<Map<String, String>> getUserAnswerMultiplay(String code, String uid);

  /* Update player's total score and detailed scores */
  Future<void> setPlayerScore(
    String markedUid,
    String gameCode,
    double totalScore,
    Map<String, double> scores,
  );

  /* Update which user this player has marked */
  Future<void> updateUserMultiPlayDoc(String markedUid, String gameCode);

  /* Stream live updates of the current user's score */
  Stream<double> getUserScore(String gameCode);

  /* Get detailed score breakdown (per category) */
  Future<Map<String, double>> getUserScoreArray(String code);
}
