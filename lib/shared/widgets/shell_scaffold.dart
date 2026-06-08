import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_providers.dart';
import '../../features/feed/presentation/create_thought_dialog.dart';

class ShellScaffold extends StatelessWidget {
  const ShellScaffold({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    (icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home', path: '/feed'),
    (icon: Icons.search_outlined, activeIcon: Icons.search_rounded, label: 'Search', path: '/search'),
    (icon: Icons.notifications_outlined, activeIcon: Icons.notifications_rounded, label: 'Alerts', path: '/notifications'),
    (icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile', path: '/profile'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);
    final mq = MediaQuery.of(context);
    final isWide = mq.size.width >= 650;

    if (isWide) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Row(
          children: [
            _GlassNavRail(
              currentIndex: index,
              onTap: (i) => context.go(_tabs[i].path),
              onCompose: () => context.push('/compose'),
              topPad: mq.padding.top,
            ),
            const VerticalDivider(width: 1, thickness: 0.5),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: child,
      floatingActionButton: _GradientFAB(
        onPressed: () => context.push('/compose'),
      ),
      bottomNavigationBar: _GlassNavBar(
        currentIndex: index,
        onTap: (i) => context.go(_tabs[i].path),
        bottomPad: mq.padding.bottom,
      ),
    );
  }
}

// ─── Wide: glass nav rail ─────────────────────────────────────────────────────

class _GlassNavRail extends StatelessWidget {
  const _GlassNavRail({
    required this.currentIndex,
    required this.onTap,
    required this.onCompose,
    required this.topPad,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onCompose;
  final double topPad;

  static const _tabs = ShellScaffold._tabs;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: 80,
          color: const Color(0xFF080A1C).withValues(alpha: 0.65),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: topPad + 18),
              // App logo orb
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: -4,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.hub_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(height: 20),
              // Compose button
              _RailComposeButton(onTap: onCompose),
              const SizedBox(height: 8),
              // Thought bubble button
              const _RailThoughtButton(),
              const SizedBox(height: 12),
              // Nav items
              ...List.generate(
                _tabs.length,
                (i) => _RailItem(
                  icon: i == currentIndex
                      ? _tabs[i].activeIcon
                      : _tabs[i].icon,
                  label: _tabs[i].label,
                  selected: i == currentIndex,
                  onTap: () => onTap(i),
                ),
              ),
              const Spacer(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _RailItem extends StatefulWidget {
  const _RailItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_RailItem> createState() => _RailItemState();
}

class _RailItemState extends State<_RailItem> {
  bool _hovered = false;

  static const _active = Color(0xFF6366F1);
  static const _inactive = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final color = widget.selected
        ? _active
        : _hovered
            ? _active.withValues(alpha: 0.75)
            : _inactive;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: 62,
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: widget.selected
                ? _active.withValues(alpha: 0.15)
                : _hovered
                    ? _active.withValues(alpha: 0.09)
                    : Colors.transparent,
          ),
          child: AnimatedScale(
            scale: _hovered ? 1.06 : 1.0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, size: 22, color: color),
                const SizedBox(height: 4),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight:
                        widget.selected ? FontWeight.w600 : FontWeight.w400,
                    color: color,
                    letterSpacing: 0.2,
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

class _RailThoughtButton extends ConsumerStatefulWidget {
  const _RailThoughtButton();

  @override
  ConsumerState<_RailThoughtButton> createState() => _RailThoughtButtonState();
}

class _RailThoughtButtonState extends ConsumerState<_RailThoughtButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    if (user == null) return const SizedBox.shrink();

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _hovered ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 52,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withValues(alpha: _hovered ? 0.10 : 0.05),
            border: Border.all(
              color: Colors.white.withValues(alpha: _hovered ? 0.20 : 0.10),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              hoverColor: Colors.transparent,
              onTap: () => showDialog(
                context: context,
                builder: (_) => CreateThoughtDialog(currentUser: user),
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                color: Colors.white.withValues(alpha: _hovered ? 0.90 : 0.60),
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RailComposeButton extends StatefulWidget {
  const _RailComposeButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_RailComposeButton> createState() => _RailComposeButtonState();
}

class _RailComposeButtonState extends State<_RailComposeButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _hovered ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 52,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1)
                    .withValues(alpha: _hovered ? 0.60 : 0.38),
                blurRadius: _hovered ? 32 : 20,
                spreadRadius: _hovered ? -2 : -5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              hoverColor: Colors.transparent,
              onTap: widget.onTap,
              child: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Narrow: floating bottom nav bar ─────────────────────────────────────────

class _GlassNavBar extends StatelessWidget {
  const _GlassNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.bottomPad,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final double bottomPad;

  static const _tabs = ShellScaffold._tabs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPad + 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF0D1020).withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.09), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (i) {
                final selected = i == currentIndex;
                return _NavItem(
                  icon: selected ? _tabs[i].activeIcon : _tabs[i].icon,
                  label: _tabs[i].label,
                  selected: selected,
                  onTap: () => onTap(i),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  static const _active = Color(0xFF6366F1);
  static const _inactive = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final color = widget.selected
        ? _active
        : _hovered
            ? _active.withValues(alpha: 0.75)
            : _inactive;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: _hovered && !widget.selected
                ? _active.withValues(alpha: 0.09)
                : Colors.transparent,
          ),
          child: AnimatedScale(
            scale: _hovered ? 1.07 : 1.0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, size: 24, color: color),
                const SizedBox(height: 3),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                        widget.selected ? FontWeight.w600 : FontWeight.w400,
                    color: color,
                    letterSpacing: 0.2,
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

// ─── Narrow: gradient FAB ─────────────────────────────────────────────────────

class _GradientFAB extends StatefulWidget {
  const _GradientFAB({required this.onPressed});
  final VoidCallback onPressed;

  @override
  State<_GradientFAB> createState() => _GradientFABState();
}

class _GradientFABState extends State<_GradientFAB> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _hovered ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1)
                    .withValues(alpha: _hovered ? 0.65 : 0.45),
                blurRadius: _hovered ? 38 : 28,
                spreadRadius: _hovered ? -2 : -6,
                offset: Offset(0, _hovered ? 14 : 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              hoverColor: Colors.transparent,
              onTap: widget.onPressed,
              child:
                  const Icon(Icons.edit_outlined, color: Colors.white, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}
