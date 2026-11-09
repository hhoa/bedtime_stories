import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bedtime_stories/core/models/child_profile.dart';
import 'package:bedtime_stories/features/profile/data/profile_storage.dart';

/// App-wide child profile. `null` until the welcome page is completed.
class ProfileCubit extends Cubit<ChildProfile?> {
  ProfileCubit(this._storage) : super(_storage.load());

  final ProfileStorage _storage;

  Future<bool> save(ChildProfile profile) async {
    final ok = await _storage.save(profile);
    if (ok && !isClosed) emit(profile);
    return ok;
  }
}

extension ProfileX on BuildContext {
  /// Reactive. Screens behind the welcome redirect always have a profile;
  /// the fallback only covers the moment before redirect runs.
  ChildProfile get profile =>
      select<ProfileCubit, ChildProfile?>((c) => c.state) ??
      const ChildProfile(name: '', gender: Gender.girl);
}
