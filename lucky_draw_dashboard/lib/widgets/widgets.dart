import 'package:flutter/material.dart';

Widget buildOutlinedButton({
  required String label,
  required Color color,
  required VoidCallback onPressed,
}) {
  return OutlinedButton(
    style: OutlinedButton.styleFrom(
      foregroundColor: color,
      side: BorderSide(color: color, width: 2),
    ),
    onPressed: onPressed,
    child: Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),
  );
}

Widget buildFilledButton({
  required String label,
  required Color color,
  required VoidCallback? onPressed, // Nullable to allow disabling
}) {
  return FilledButton(
    style: FilledButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: color,
    ),
    onPressed: onPressed,
    child: Padding(
      padding: const EdgeInsets.all(25.0),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
  );
}
