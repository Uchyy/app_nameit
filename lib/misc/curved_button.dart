import 'package:flutter/material.dart';

class CurvedButton extends StatelessWidget {
  final String leftLabel;
  final String rightLabel;
  final VoidCallback onLeftPressed;
  final VoidCallback onRightPressed;
  final Color leftColor;
  final Color rightColor;
  final Color textColor;
  final EdgeInsetsGeometry padding;

  const CurvedButton({
    super.key,
    required this.leftLabel,
    required this.rightLabel,
    required this.onLeftPressed,
    required this.onRightPressed,
    this.leftColor = const Color.fromARGB(255, 227, 100, 100),
    this.rightColor = const Color.fromARGB(255, 164, 72, 235),
    this.textColor = Colors.white,
    this.padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Left button (curved on right)
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: leftColor,
              foregroundColor: textColor,
              padding: padding,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
            ),
            onPressed: onLeftPressed,
            child: Text(leftLabel.toUpperCase()),
          ),
        ),

        const Spacer(),

        // Right button (curved on left)
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: rightColor,
              foregroundColor: textColor,
              padding: padding,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  bottomLeft: Radius.circular(25),
                ),
              ),
            ),
            onPressed: onRightPressed,
            child: Text(rightLabel.toUpperCase()),
          ),
        ),
      ],
    );
  }
}
