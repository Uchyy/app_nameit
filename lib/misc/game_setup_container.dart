import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nomino/theme.dart'; // for NominoTheme.mainGradient

class GameSetupContainer extends StatelessWidget {
  final Color borderColor;
  final String title;
  final Widget child;
  final Gradient? borderGradient;
  final IconData? icon;

  const GameSetupContainer({
    super.key,
    required this.borderColor,
    required this.title,
    required this.child,
    this.borderGradient,
    this.icon
  });

  @override
  Widget build(BuildContext context) {
    final gradient = borderGradient ?? NominoTheme.mainGradient;

    return Container(
      margin: const EdgeInsets.all(16), // outer spacing
      decoration: BoxDecoration(
        gradient: gradient, // 🌈 gradient outer layer
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        margin: const EdgeInsets.all(3), // thickness of border
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: borderColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            // Title text uses your borderColor
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: borderColor, size: 30,),
                const SizedBox(width: 10,),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: GoogleFonts.cormorant().fontFamily,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                    color: borderColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          
            const SizedBox(height: 15),
            Divider(
              color: borderColor,
              thickness: 2,
            ),
            const SizedBox(height: 20),
            child,
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
