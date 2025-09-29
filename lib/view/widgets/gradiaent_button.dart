import 'package:flutter/material.dart';

Widget buildGradientButton({
  required String text,
   bool isLoading = false,
  required VoidCallback onPressed,
  required IconData icon,
  required List<Color> gradientColors,
  bool isSecondary = false,
}) {
  return Container(
    width: double.infinity,
    height: 56,
    decoration: BoxDecoration(
      gradient: isSecondary ? null : LinearGradient(
        colors: gradientColors,
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      borderRadius: BorderRadius.circular(12),
      border: isSecondary ? Border.all(color: Colors.grey.shade300, width: 1.5) : null,
      boxShadow: isSecondary ? null : [
        BoxShadow(
          color: gradientColors.first.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      ) : Icon(icon, color: isSecondary ? Colors.grey.shade700 : Colors.white),
      label: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isSecondary ? Colors.grey.shade700 : Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSecondary ? Colors.white : Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}