import 'package:app_nameit/model/categories.dart';

class Game {
  String mode; // "solo" or "multiplayer"
  int duration;
  List<GameCategory> categories;
  String selectedChar;
   Map<String, String> answers; 
  //List<String> multiplayer; 

  Game({
    this.mode = "solo",
    this.duration = 5,
    this.categories = const [],
    this.selectedChar = "N",
     this.answers = const {},
    //this.multiplayer = const [],
  });
}
