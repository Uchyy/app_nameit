import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ButtonStyle subelevatedButtonStyle() {
   return  ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF717744),
                foregroundColor: Color(0xFFEFF1ED),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                textStyle: TextStyle(
                  fontSize: 10.0,
                  fontFamily: GoogleFonts.satisfy().fontFamily,
                  color: Color(0xFFEFF1ED),
                ),
                elevation: 5.0,
              );
  }