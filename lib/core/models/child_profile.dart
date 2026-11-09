import 'package:freezed_annotation/freezed_annotation.dart';

part 'child_profile.freezed.dart';

/// Picks the kid's avatar on home and profile. Story art never depends on
/// it: each story has its own hero (see `StoryHero`).
enum Gender { girl, boy }

/// App language: UI text, story text and narration. Vietnamese is default.
enum AppLanguage { vi, en }

/// The kid the stories are about. Set on the welcome page.
@freezed
abstract class ChildProfile with _$ChildProfile {
  const factory ChildProfile({required String name, required Gender gender}) =
      _ChildProfile;
}
