import 'package:nomino/account/main.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nomino/misc/gradient_text.dart';
import 'package:nomino/theme.dart';
import 'package:provider/provider.dart'; 

import './styles/main_button.dart';
import './pre_game/game_setup.dart';
import 'helpers/game_provider.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ChangeNotifierProvider(
      create: (_) => GameProvider(),
      child: const NominoApp(),
    ),
  );
}

class NominoApp extends StatelessWidget {
  const NominoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nomino',
      debugShowCheckedModeBanner: false,
      theme: NominoTheme.light,
      home: const Nomino(),
    );
  }
}


class Nomino extends StatefulWidget {
  const Nomino({super.key});

  @override
  State<Nomino> createState() => nominoState();
}

class nominoState extends State<Nomino> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop(); // 👈 exits the app completely
        return false; // prevents normal back navigation
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEFF1ED),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(width: 20.0, height: 100.0),
                  GradientText(
                    'nomino',
                    style: TextStyle(
                      fontSize: 60.0,
                      fontFamily: GoogleFonts.modak().fontFamily,
                      color: const Color.fromARGB(255, 196, 204, 138),
                      letterSpacing: 2.0,
                    ),
                    textAlign: TextAlign.left,
                  ),
                 const SizedBox(height: 20,),

                  DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 40.0,
                      fontFamily: GoogleFonts.dancingScript().fontFamily,
                      color: Theme.of(context).primaryColorDark
                    ),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TyperAnimatedText('a song'),
                        TyperAnimatedText('a food'),
                        TyperAnimatedText('a movie'),
                        TyperAnimatedText('a name'),
                      ],
                      isRepeatingAnimation: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 45.0),
              ElevatedButton(
                style: elevatedButtonStyle(context),
                onPressed: () {
                  Navigator.of(context).push(PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (_, __, ___) => const GameSetupScreen(),
                  ));
                },
                child: const Text('PLAY'),
              ),

              const SizedBox(height: 25.0),
              ElevatedButton(
                style: elevatedButtonStyle(context),
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
      ),
    );
  }
}
