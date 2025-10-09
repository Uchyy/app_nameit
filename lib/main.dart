import 'package:app_nameit/account/main.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; 

import './styles/main_button.dart';
import './pre_game/game_setup.dart';
import 'helpers/game_provider.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return const SizedBox.shrink();
  };
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
      ChangeNotifierProvider(
        create: (_) => GameProvider(),
        child: const MyApp(),
      ),
  );
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      title: 'Name IT',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFEFF1ED),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 132, 116, 160),
        ),
      ),
      home: const Nomino(),
    );
  }
}

class Nomino extends StatefulWidget {
  const Nomino({super.key});

  @override
  State<Nomino> createState() => NominoState();
}

class NominoState extends State<Nomino> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF1ED),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(width: 20.0, height: 100.0),
                Text(
                  'nomino',
                  style: TextStyle(
                    fontSize: 60.0,
                    fontFamily: GoogleFonts.modak().fontFamily,
                    color: const Color(0xFF717744),
                    letterSpacing: 2.0,
                  ),
                  textAlign: TextAlign.left,
                ),
                DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 40.0,
                    fontFamily: GoogleFonts.dancingScript().fontFamily,
                    color: const Color(0xFF373D20),
                  ),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText('a song'),
                      TyperAnimatedText('a food'),
                      TyperAnimatedText('a movie'),
                      TyperAnimatedText('a name'),
                    ],
                    isRepeatingAnimation: true,
                    //totalRepeatCount: 4,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 45.0),
            ElevatedButton(
              style: elevatedButtonStyle(),
              onPressed: () {
                Navigator.of(context).push(PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (_, __, ___) => const GameSetupScreen(),
                ));
              },
              child: const Text('PLAY'),
            ),

            const SizedBox(height: 15.0),
            ElevatedButton(
              style: elevatedButtonStyle(),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AccountScreen()),
                );
              },
              child: const Text('ACCOUNT'),
            ),
          ],
        ),
      ),
    );
  }
}
