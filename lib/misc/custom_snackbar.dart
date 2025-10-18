import 'package:flutter/material.dart';

class CustomSnackbar {
  CustomSnackbar(String s, String t);

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    String actionLabel = "DISMISS",
    VoidCallback? onAction,
  }) {
    final theme = Theme.of(context);

    // 🔹 Detect type from title
    final upperTitle = title.toUpperCase();
    Color backgroundColor;
    Color accentColor;

    if (upperTitle.contains("ERROR")) {
      backgroundColor = const Color(0xFFFFE5E5); // soft red background
      accentColor = const Color(0xFFE46C5D); // coral
    } else if (upperTitle.contains("SUCCESS")) {
      backgroundColor = const Color(0xFFE5F8F4); // soft teal background
      accentColor = const Color(0xFF4FC7C0); // teal
    } else {
      backgroundColor = const Color(0xFFEDEAFF); // soft purple background
      accentColor = const Color(0xFF8A6FB3); // purple info
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        content: Card(
          color: backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                // Text content
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color.fromARGB(221, 30, 29, 29),
                        ),
                      ),
                    ],
                  ),
                ),

                // Vertical separator
                Container(
                  color: accentColor.withOpacity(0.4),
                  height: 30,
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),

                // Action button
                TextButton(
                  onPressed: onAction ??
                      () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                  child: Text(
                    actionLabel.toUpperCase(),
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
