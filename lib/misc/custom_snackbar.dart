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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        content: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

                // Vertical separator
                Container(
                  color: Colors.grey.shade300,
                  height: 30,
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),

                // Action button
                TextButton(
                  onPressed: onAction ?? () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                  child: Text(
                    actionLabel.toUpperCase(),
                    style: TextStyle(color: theme.colorScheme.primary),
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
