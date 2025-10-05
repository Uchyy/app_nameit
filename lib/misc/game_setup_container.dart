import 'package:flutter/material.dart';

class GameSetupContainer extends StatelessWidget {
  final Color borderColor;
  final String title;
  final Widget child;

  const GameSetupContainer({
    super.key,
    required this.borderColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16), // outer spacing
      padding: const EdgeInsets.all(10), // inner spacing
      decoration: BoxDecoration(
        color: Colors.white, // background is white
        border: Border.all(
          color: borderColor,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20,),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
              color: borderColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15,),
           Divider(
            color: borderColor, // 👈 matches the border color
            thickness: 2,
          ),
          const SizedBox(height: 20),
          child, 
        ],
      ),
    );
  }
}
