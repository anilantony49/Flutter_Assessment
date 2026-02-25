import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

Future<dynamic> nextScreen(BuildContext context, Widget page) {
  return Navigator.push(
    context,
    PageTransition(child: page, type: PageTransitionType.fade),
  );
}

Future<dynamic> nextScreenRemoveUntil(BuildContext context, Widget page) {
  return Navigator.pushAndRemoveUntil(
    context,
    PageTransition(child: page, type: PageTransitionType.fade),
    (route) => false,
  );
}

void customSnackbar(
  BuildContext context,
  String message, {
  IconData? leading,
  Color? iconColor,
}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      margin: const EdgeInsets.all(20),
      backgroundColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
      elevation: 8,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      duration: const Duration(seconds: 3),
      content: Row(
        children: [
          Icon(
            leading ?? Icons.info_outline_rounded,
            color: iconColor ?? theme.colorScheme.primary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
