import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../models/thought_model.dart';
import '../../../shared/widgets/user_avatar.dart';

class ThoughtCard extends StatelessWidget {
  const ThoughtCard({super.key, required this.thought, this.onDelete});

  final ThoughtModel thought;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    if (thought.isExpired) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    final gradientColors = isDark
        ? [
            const Color(0xFF4F46E5).withValues(alpha: 0.32),
            const Color(0xFF7C3AED).withValues(alpha: 0.22),
          ]
        : [
            const Color(0xFF6366F1).withValues(alpha: 0.13),
            const Color(0xFF8B5CF6).withValues(alpha: 0.09),
          ];

    final borderColor = Colors.white.withValues(alpha: isDark ? 0.13 : 0.65);
    final circleColor = isDark
        ? const Color(0xFF3730A3)
        : const Color(0xFF6366F1);

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 26),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 180, minWidth: 120),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Glass bubble body
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: avatarColorFor(thought.author.displayName),
                              backgroundImage: thought.author.avatarUrl != null
                                  ? NetworkImage(thought.author.avatarUrl!)
                                  : null,
                              child: thought.author.avatarUrl == null
                                  ? Text(
                                      thought.author.displayName.isNotEmpty
                                          ? thought.author.displayName[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    thought.author.displayName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '@${thought.author.username}',
                                    style: TextStyle(color: textColor, fontSize: 10),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (onDelete != null)
                              PopupMenuButton<String>(
                                onSelected: (v) {
                                  if (v == 'delete') onDelete!();
                                },
                                itemBuilder: (_) => [
                                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                                ],
                                child: Icon(Icons.more_horiz, size: 14, color: textColor),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          thought.content,
                          style: const TextStyle(fontSize: 13, height: 1.4),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          timeago.format(thought.createdAt),
                          style: TextStyle(color: textColor, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Thought-bubble tail: three cascading circles
              Positioned(
                bottom: -8,
                left: 14,
                child: _TailCircle(size: 10, color: circleColor, borderColor: borderColor),
              ),
              Positioned(
                bottom: -16,
                left: 8,
                child: _TailCircle(size: 7, color: circleColor, borderColor: borderColor),
              ),
              Positioned(
                bottom: -22,
                left: 3,
                child: _TailCircle(size: 5, color: circleColor, borderColor: borderColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TailCircle extends StatelessWidget {
  const _TailCircle({
    required this.size,
    required this.color,
    required this.borderColor,
  });

  final double size;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: borderColor, width: 1),
      ),
    );
  }
}
