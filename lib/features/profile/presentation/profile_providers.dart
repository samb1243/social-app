import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../models/user_model.dart';
import '../../auth/presentation/auth_providers.dart';

class ProfileState {
  final UserModel user;
  final Uint8List? localAvatar;
  final Uint8List? localBanner;

  const ProfileState({
    required this.user,
    this.localAvatar,
    this.localBanner,
  });

  ProfileState copyWith({
    UserModel? user,
    Uint8List? localAvatar,
    Uint8List? localBanner,
    bool clearLocalAvatar = false,
    bool clearLocalBanner = false,
  }) {
    return ProfileState(
      user: user ?? this.user,
      localAvatar: clearLocalAvatar ? null : localAvatar ?? this.localAvatar,
      localBanner: clearLocalBanner ? null : localBanner ?? this.localBanner,
    );
  }
}

class ProfileNotifier extends Notifier<ProfileState> {
  final _picker = ImagePicker();

  @override
  ProfileState build() {
    final user = ref.watch(authProvider);
    return ProfileState(
      user: user ?? const UserModel(id: '', username: '', displayName: ''),
    );
  }

  void updateUser(UserModel user) {
    state = state.copyWith(user: user);
  }

  Future<void> pickAvatar() async {
    final file =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    state = state.copyWith(localAvatar: bytes);
  }

  Future<void> pickBanner() async {
    final file =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    state = state.copyWith(localBanner: bytes);
  }
}

final profileProvider =
    NotifierProvider<ProfileNotifier, ProfileState>(ProfileNotifier.new);
