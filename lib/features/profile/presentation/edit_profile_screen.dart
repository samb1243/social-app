
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'profile_providers.dart';

const _pronounSuggestions = ['he/him', 'she/her', 'they/them', 'he/they', 'she/they'];

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _pronounsCtrl;
  late final TextEditingController _ageCtrl;

  @override
  void initState() {
    super.initState();
    final user = ref.read(profileProvider).user;
    _nameCtrl = TextEditingController(text: user.displayName);
    _usernameCtrl = TextEditingController(text: user.username);
    _bioCtrl = TextEditingController(text: user.bio ?? '');
    _pronounsCtrl = TextEditingController(text: user.pronouns ?? '');
    _ageCtrl = TextEditingController(text: user.age?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _bioCtrl.dispose();
    _pronounsCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final notifier = ref.read(profileProvider.notifier);
    final current = ref.read(profileProvider).user;

    final ageText = _ageCtrl.text.trim();
    final age = ageText.isEmpty ? null : int.tryParse(ageText);
    final pronouns = _pronounsCtrl.text.trim();
    final bio = _bioCtrl.text.trim();

    notifier.updateUser(
      current.copyWith(
        displayName: _nameCtrl.text.trim().isEmpty ? current.displayName : _nameCtrl.text.trim(),
        username: _usernameCtrl.text.trim().isEmpty ? current.username : _usernameCtrl.text.trim(),
        bio: bio,
        clearBio: bio.isEmpty,
        pronouns: pronouns,
        clearPronouns: pronouns.isEmpty,
        age: age,
        clearAge: ageText.isEmpty,
      ),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => context.pop(),
          child: const Text('Cancel'),
        ),
        title: const Text('Edit profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text('Save'),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          // ── Banner ──────────────────────────────────────────────────────
          _BannerPicker(
            bytes: state.localBanner,
            onTap: () => ref.read(profileProvider.notifier).pickBanner(),
          ),

          // ── Avatar (overlapping the banner) ─────────────────────────────
          Transform.translate(
            offset: const Offset(16, -36),
            child: Align(
              alignment: Alignment.centerLeft,
              child: _AvatarPicker(
                bytes: state.localAvatar,
                fallbackInitial: state.user.displayName[0].toUpperCase(),
                onTap: () => ref.read(profileProvider.notifier).pickAvatar(),
              ),
            ),
          ),

          // ── Form fields ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Field(
                  label: 'Name',
                  controller: _nameCtrl,
                  maxLength: 50,
                ),
                const SizedBox(height: 16),
                _Field(
                  label: 'Username',
                  controller: _usernameCtrl,
                  maxLength: 30,
                  prefix: const Text('@'),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
                  ],
                ),
                const SizedBox(height: 16),
                _Field(
                  label: 'Bio',
                  controller: _bioCtrl,
                  maxLength: 160,
                  maxLines: 4,
                  hint: 'Tell people a little about yourself',
                ),
                const SizedBox(height: 16),
                _Field(
                  label: 'Age',
                  controller: _ageCtrl,
                  maxLength: 3,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  hint: 'Optional',
                ),
                const SizedBox(height: 16),
                _PronounsField(
                  controller: _pronounsCtrl,
                  suggestions: _pronounSuggestions,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Banner picker ────────────────────────────────────────────────────────────

class _BannerPicker extends StatelessWidget {
  const _BannerPicker({required this.bytes, required this.onTap});

  final Uint8List? bytes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 150,
        child: Stack(
          fit: StackFit.expand,
          children: [
            bytes != null
                ? Image.memory(bytes!, fit: BoxFit.cover)
                : ColoredBox(color: colorScheme.surfaceContainerHighest),
            Container(
              color: Colors.black38,
              alignment: Alignment.center,
              child: const _CameraIcon(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Avatar picker ────────────────────────────────────────────────────────────

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({
    required this.bytes,
    required this.fallbackInitial,
    required this.onTap,
  });

  final Uint8List? bytes;
  final String fallbackInitial;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: colorScheme.primaryContainer,
            backgroundImage: bytes != null ? MemoryImage(bytes!) : null,
            child: bytes == null
                ? Text(
                    fallbackInitial,
                    style: TextStyle(
                      fontSize: 32,
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraIcon extends StatelessWidget {
  const _CameraIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black45,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(10),
      child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 22),
    );
  }
}

// ── Reusable text field ──────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.maxLength,
    this.maxLines = 1,
    this.hint,
    this.prefix,
    this.keyboardType,
    this.inputFormatters,
  });

  final String label;
  final TextEditingController controller;
  final int? maxLength;
  final int maxLines;
  final String? hint;
  final Widget? prefix;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefix: prefix,
        border: const OutlineInputBorder(),
        counterStyle: const TextStyle(fontSize: 11),
      ),
    );
  }
}

// ── Pronouns field with chip suggestions ─────────────────────────────────────

class _PronounsField extends StatefulWidget {
  const _PronounsField({required this.controller, required this.suggestions});

  final TextEditingController controller;
  final List<String> suggestions;

  @override
  State<_PronounsField> createState() => _PronounsFieldState();
}

class _PronounsFieldState extends State<_PronounsField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          maxLength: 40,
          decoration: const InputDecoration(
            labelText: 'Pronouns',
            hintText: 'e.g. they/them',
            border: OutlineInputBorder(),
            counterStyle: TextStyle(fontSize: 11),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: widget.suggestions.map((s) {
            final selected = widget.controller.text == s;
            return ChoiceChip(
              label: Text(s),
              selected: selected,
              onSelected: (_) => setState(() {
                widget.controller.text = selected ? '' : s;
              }),
            );
          }).toList(),
        ),
      ],
    );
  }
}
