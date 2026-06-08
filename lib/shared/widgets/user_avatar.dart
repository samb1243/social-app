import 'package:flutter/material.dart';
import '../../models/user_model.dart';

/// Returns a consistent vibrant color for a user based on their display name.
Color avatarColorFor(String name) {
  const colors = [
    Color(0xFFEF4444), // red
    Color(0xFFF97316), // orange
    Color(0xFFEAB308), // amber
    Color(0xFF22C55E), // green
    Color(0xFF14B8A6), // teal
    Color(0xFF06B6D4), // cyan
    Color(0xFF3B82F6), // blue
    Color(0xFF8B5CF6), // violet
    Color(0xFFEC4899), // pink
    Color(0xFF84CC16), // lime
  ];
  if (name.isEmpty) return colors[0];
  final index = name.codeUnits.fold(0, (a, b) => a + b) % colors.length;
  return colors[index];
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.user, this.radius = 20});

  final UserModel user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (user.avatarUrl != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(user.avatarUrl!),
      );
    }
    final bg = avatarColorFor(user.displayName);
    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      child: Text(
        user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: radius * 0.85,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
