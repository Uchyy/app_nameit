import 'package:flutter/material.dart';

class BottomActionRow extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onSubmit;
  final VoidCallback onMiddlePressed;

  const BottomActionRow({
    super.key,
    required this.onReset,
    required this.onSubmit,
    required this.onMiddlePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 227, 100, 100),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
            ),
            onPressed: onReset,
            child: const Text("RESET"),
          ),
        ),

        /* Middle button (placeholder)
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade300,
              foregroundColor: Colors.black,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            onPressed: onMiddlePressed,
            child: const Text("???"),
          ),
        ),

        const SizedBox(width: 4),
        */
        const Spacer(),

        // SUBMIT button - curved on left side
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 164, 72, 235),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  bottomLeft: Radius.circular(25),
                ),
              ),
            ),
            onPressed: onSubmit,
            child: const Text("SUBMIT"),
          ),
        ),
      ],
    );
  }
}
