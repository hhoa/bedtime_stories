import 'dart:developer';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:bedtime_stories/core/models/child_profile.dart';
import 'package:bedtime_stories/features/stories/domain/entities/story.dart';

/// What the kid does in stories, for the parent-facing product owner.
///
/// Kids app: only story/node/option ids, language, counts and the avatar
/// gender are sent. Never
/// the child's name or anything else that identifies them.
abstract interface class Analytics {
  /// A story was opened (from home or "play again").
  Future<void> storyStart(String storyId, AppLanguage language);

  Future<void> storyChoice({
    required String storyId,
    required String nodeId,
    required String optionId,
    required ChoiceKind kind,
  });

  /// Kid went back to [nodeId] to try the other option.
  Future<void> storyRewind({required String storyId, required String nodeId});

  /// [goodAnswers] = stickers earned (first picks that were kind).
  Future<void> storyComplete({
    required String storyId,
    required String endingId,
    required int goodAnswers,
  });

  /// User property, so every event can be split by girl/boy hero.
  Future<void> setHeroGender(Gender gender);
}

/// Best-effort Firebase Analytics: failures are logged, never thrown.
final class FirebaseAppAnalytics implements Analytics {
  FirebaseAppAnalytics(this._analytics);

  final FirebaseAnalytics _analytics;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  /// Kids app: no ad storage, no ad personalization.
  Future<void> applyKidsConsent() => _guard(
    'consent',
    () => _analytics.setConsent(
      adStorageConsentGranted: false,
      adUserDataConsentGranted: false,
      adPersonalizationSignalsConsentGranted: false,
      analyticsStorageConsentGranted: true,
    ),
  );

  @override
  Future<void> storyStart(String storyId, AppLanguage language) =>
      _log('story_start', {'story_id': storyId, 'lang': language.name});

  @override
  Future<void> storyChoice({
    required String storyId,
    required String nodeId,
    required String optionId,
    required ChoiceKind kind,
  }) => _log('story_choice', {
    'story_id': storyId,
    'node_id': nodeId,
    'option_id': optionId,
    'kind': kind.name,
  });

  @override
  Future<void> storyRewind({required String storyId, required String nodeId}) =>
      _log('story_rewind', {'story_id': storyId, 'node_id': nodeId});

  @override
  Future<void> storyComplete({
    required String storyId,
    required String endingId,
    required int goodAnswers,
  }) => _log('story_complete', {
    'story_id': storyId,
    'ending_id': endingId,
    'good_answers': goodAnswers,
  });

  @override
  Future<void> setHeroGender(Gender gender) => _guard(
    'hero_gender',
    () => _analytics.setUserProperty(name: 'hero_gender', value: gender.name),
  );

  Future<void> _log(String name, Map<String, Object> params) =>
      _guard(name, () => _analytics.logEvent(name: name, parameters: params));

  Future<void> _guard(String what, Future<void> Function() run) async {
    try {
      await run();
    } catch (e) {
      log('analytics $what failed: $e', name: 'Analytics');
    }
  }
}

/// Used when Firebase could not start (and in tests).
final class NoopAnalytics implements Analytics {
  const NoopAnalytics();

  @override
  Future<void> storyStart(String storyId, AppLanguage language) async {}

  @override
  Future<void> storyChoice({
    required String storyId,
    required String nodeId,
    required String optionId,
    required ChoiceKind kind,
  }) async {}

  @override
  Future<void> storyRewind({
    required String storyId,
    required String nodeId,
  }) async {}

  @override
  Future<void> storyComplete({
    required String storyId,
    required String endingId,
    required int goodAnswers,
  }) async {}

  @override
  Future<void> setHeroGender(Gender gender) async {}
}
