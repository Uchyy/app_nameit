import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nomino/misc/custom_snackbar.dart';

Future<bool> validateJoinCode(BuildContext context, String code) async {
  final trimmed = code.trim().toUpperCase();

  // 🧩 Basic validation
  if (trimmed.isEmpty || trimmed.length != 6) {
    if (Navigator.canPop(context)) Navigator.pop(context);
    CustomSnackbar.show(
      context,
      title: "ERROR: Invalid Code",
      message: "Game codes must be exactly 6 characters long.",
    );
    return false;
  }

  try {
    final doc = await FirebaseFirestore.instance
        .collection('games')
        .doc(trimmed)
        .get();

    if (!doc.exists) {
      CustomSnackbar.show(
        context,
        title: "ERROR: Code Not Found",
        message: "No game found for '$trimmed'. Please create a new one instead.",
      );

      // Wait a bit so snackbar shows before navigation
      await Future.delayed(const Duration(milliseconds: 300));
      if (Navigator.canPop(context)) Navigator.pop(context);
      return false;
    }

    return true;
  } catch (e) {
    if (Navigator.canPop(context)) Navigator.pop(context);
    debugPrint("❌ FIRESTORE ERROR: $e");
    CustomSnackbar.show(
      context,
      title: "ERROR: Network Issue",
      message: "Unable to connect. Please check your internet and try again.",
    );
    return false;
  }
}
