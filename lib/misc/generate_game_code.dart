import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<String> generateUniqueGameCode() async {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final rand = Random.secure();
  final gamesRef = FirebaseFirestore.instance.collection('games');

  String code;
  bool exists = true;

  // keep generating until we find a code not in Firestore
  do {
    code = List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
    final doc = await gamesRef.doc(code).get();
    exists = doc.exists;
  } while (exists);

  return code;
}
