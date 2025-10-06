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
    this.duration = 3,
    this.categories = const [],
    this.selectedChar = "N",
    this.answers = const {},
    //this.multiplayer = const [],
  });

  @override
  String toString() {
    return 'Mode: $mode,\n'
          'Duration: $duration,\n'
          'Categories: ${categories.map((c) => c.name).toList()},\n'
          'SelectedChar: $selectedChar,\n'
          'Answers: ${answers.toString()}';
  }

}
