import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bedtime_stories/core/models/child_profile.dart';
import 'package:bedtime_stories/core/models/story_section.dart';
import 'package:bedtime_stories/core/services/analytics.dart';
import 'package:bedtime_stories/core/services/narrator.dart';
import 'package:bedtime_stories/core/utils/app_constants.dart';

/// Sections page. State = the section whose card was tapped last (its card
/// glows), null before any tap.
///
/// The kid can't read, so a tap says the section's name aloud. The page
/// stays under the section list (pushed), so the clip plays to its end.
class SectionsCubit extends Cubit<StorySection?> {
  SectionsCubit({required this._narrator, required this._analytics})
    : super(null);

  final Narrator _narrator;
  final Analytics _analytics;

  void open(StorySection section, AppLanguage language) {
    emit(section);
    unawaited(_analytics.sectionOpen(section));
    unawaited(_narrator.play(AppConstants.sectionAudio(section, language)));
  }

  @override
  Future<void> close() async {
    await _narrator.dispose();
    return super.close();
  }
}
