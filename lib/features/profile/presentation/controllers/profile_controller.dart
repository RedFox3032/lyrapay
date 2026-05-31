import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'profile_state.dart';

final profileControllerProvider = StateNotifierProvider<ProfileController, ProfileState>((ref) {
  return ProfileController();
});

class ProfileController extends StateNotifier<ProfileState> {
  ProfileController() : super(const ProfileInitial());
}
