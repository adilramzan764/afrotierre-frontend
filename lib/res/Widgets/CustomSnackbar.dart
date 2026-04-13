import 'package:flutter/material.dart';

class CustomSnackbar {
  static void showError(
      BuildContext context,
      String message, {
        Duration duration = const Duration(seconds: 4),
      }) {
    _showSnackbar(
      context,
      message,
      Colors.red.shade700,
      Icons.error_outline_rounded,
      duration,
    );
  }

  static void showSuccess(
      BuildContext context,
      String message, {
        Duration duration = const Duration(seconds: 3),
      }) {
    _showSnackbar(
      context,
      message,
      Colors.green.shade700,
      Icons.check_circle_outline_rounded,
      duration,
    );
  }

  static void showInfo(
      BuildContext context,
      String message, {
        Duration duration = const Duration(seconds: 3),
      }) {
    _showSnackbar(
      context,
      message,
      Colors.blue.shade700,
      Icons.info_outline_rounded,
      duration,
    );
  }

  static void showWarning(
      BuildContext context,
      String message, {
        Duration duration = const Duration(seconds: 4),
      }) {
    _showSnackbar(
      context,
      message,
      Colors.orange.shade700,
      Icons.warning_amber_rounded,
      duration,
    );
  }

  static void _showSnackbar(
      BuildContext context,
      String message,
      Color backgroundColor,
      IconData icon,
      Duration duration,
      ) {
    // Remove any existing snackbars
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        duration: duration,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                child: Icon(
                  Icons.close,
                  color: Colors.white.withOpacity(0.7),
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}