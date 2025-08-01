import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

/* 
Color(0xFFEFF1ED) whitesmoke
Color(0xFF373D20)  dark green
Color(0xFF717744) green
Color(0xFFBCBD8B) sage
Color(0xFF766153) umber brown
*/

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Name IT',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFEFF1ED),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 132, 116, 160)),
      ),
      home: const FallingLetters(),
    );
  }
}

class FallingLetters extends StatefulWidget {
  const FallingLetters({super.key});

  @override
  State<FallingLetters> createState() => _FallingLettersState();
}

class _FallingLettersState extends State<FallingLetters> with TickerProviderStateMixin {
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFF1ED),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(width: 20.0, height: 100.0),
                Text(
                  'name',
                  style: TextStyle(
                    fontSize: 43.0, 
                    fontFamily: GoogleFonts.michroma().fontFamily,
                    color: Color(0xFF717744),
                    letterSpacing: 2.0,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(width: 20.0, height: 100.0),
                DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 40.0,
                    fontFamily: GoogleFonts.dancingScript().fontFamily,
                    color: Color(0xFF373D20),
                  ),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      RotateAnimatedText('IT'),
                      RotateAnimatedText('a noun'),
                      RotateAnimatedText('a place'),
                      RotateAnimatedText('a thing'),
                    ],
                    onTap: () {
                      print("Tap Event");
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF717744),
                foregroundColor: Color(0xFFEFF1ED),
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                textStyle: TextStyle(
                  fontSize: 30.0,
                  fontFamily: GoogleFonts.satisfy().fontFamily,
                  color: Color(0xFFEFF1ED),
                ),
                elevation: 5.0,
              ),
              onPressed: () {
                // Add your button action here
              },
              child: const Text('PLAY'),
            ),

            const SizedBox(height: 15.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF717744),
                foregroundColor: Color(0xFFEFF1ED),
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                textStyle: TextStyle(
                  fontSize: 30.0,
                  fontFamily: GoogleFonts.satisfy().fontFamily,
                  color: Color(0xFFEFF1ED),
                ),
                elevation: 5.0,
              ),
              onPressed: () {
                // Add your button action here
              },
              child: const Text('ACCOUNT'),
            ),
          ],
        ),
      )
    );
  }
}
