import 'dart:ffi';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'category_list.dart';
import '../theme/colors.dart';
import '../main.dart';

class GameSetupScreen extends StatefulWidget{
  const GameSetupScreen({super.key});

  @override
  GameSetupScreenState createState() => GameSetupScreenState();
  
}

class GameSetupScreenState extends State<GameSetupScreen> {

  final PageController _pageController = PageController();
  int _currentPage = 0;

  List <GameModel> gameSetupWidgets = [];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _currentPage++;
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

        return Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: screenHeight * 0.5,
            
            child: Column(
              children: [
                // Custom header at bottom
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, size: 30,),
                        onPressed:  _previousPage
                      ),
                      const Spacer(),
                    ],
                  ),
                ),

                // PageView and navigation
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      Container(color: Colors.blue[100], child: Center(child: Text("Page 1"))),
                      Container(color: Colors.green[100], child: Center(child: Text("Page 2"))),
                      Container(color: Colors.orange[100], child: Center(child: Text("Page 3"))),
                    ],
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _currentPage  == gameSetupWidgets.length - 1
                    ? SizedBox.shrink()
                    : Spacer(),
                      TextButton(
                        onPressed: _nextPage, 
                        child: 
                          Text("Next", style: TextStyle(
                            fontFamily: GoogleFonts.lato().fontFamily, 
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.primaryVariant),
                          )
                      ),
                  ],
                ),
                const SizedBox(height: 40,)
              ],
            ),
          ),
        );
    }
    
  }

class GameModel  {
  final String title;
  final Widget widget;

  GameModel ({
    required this.title,
    required this.widget,
  });
}

