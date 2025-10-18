import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ButtonStyle elevatedButtonStyle(BuildContext context) {
   return  ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Color(0xFFEFF1ED),
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                textStyle: TextStyle(
                  fontSize: 30.0,
                  fontFamily: GoogleFonts.satisfy().fontFamily,
                  color: Color(0xFFEFF1ED),
                ),
                elevation: 5.0,
              );
  }