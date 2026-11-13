import 'package:bedtime_stories/core/models/child_profile.dart';
import 'package:bedtime_stories/core/models/story_section.dart';

abstract final class AppConstants {
  // Assets
  static const storiesRoot = 'assets/stories';
  static const storyIndexAsset = 'assets/stories/index.json';
  static const uiAudioDir = 'assets/audio/ui';

  /// Narration clip format. Parent recordings drop in with the same names.
  static const audioExt = 'm4a';

  /// Shared lines (`rewind`, `be`, `sticker_<n>`) in one language.
  static String uiAudio(String key, AppLanguage language) =>
      '$uiAudioDir/${language.name}/$key.$audioExt';

  /// Said in place of the child's name when the parent hasn't recorded it
  /// ("bé" / "sweetie", same voice as the story). Device TTS was dropped: on
  /// iOS Safari it can mute the page's audio for the rest of the story.
  static String nameFallbackAudio(AppLanguage language) =>
      uiAudio('be', language);

  /// Ending line for [count] stickers; above 2 the "2" line is reused.
  static String stickerAudio(int count, AppLanguage language) =>
      uiAudio('sticker_${count.clamp(0, 2)}', language);
  static String heroAvatar(String gender) => 'assets/images/hero_$gender.svg';

  /// Card picture on the sections page.
  static String sectionArt(StorySection section) => switch (section) {
    // Placeholder until the Gemini section card is made.
    StorySection.behavior => 'assets/stories/tidy_toys/images/cover.webp',
    StorySection.math => 'assets/images/section_math.svg',
  };

  /// Section name read aloud when its card is tapped.
  static String sectionAudio(StorySection section, AppLanguage language) =>
      uiAudio('section_${section.name}', language);

  // Profile
  static const childNameMaxLength = 20;
  static const heroCardMaxSize = 168.0;
  static const heroCardMinSize = 56.0;

  // Recorded name (see `RecordNameVoice`): WAV, boosted when saved so it
  // is about as loud as the narration clips.
  static const nameSampleRate = 16000;
  static const nameTargetPeak = 0.9;
  static const nameMaxGain = 8.0;

  // Kid-sized touch targets (logical px)
  static const kidMinTarget = 96.0;
  static const kidIconButton = 64.0;
  static const choiceIconSize = 120.0;
  static const choiceIconSizeCompact = 96.0;

  // Layout
  static const wideLayoutMinWidth = 700.0;
  static const sceneAspectRatio = 4 / 3;

  /// Home grid: two columns once the content is at least this wide.
  static const storyGridTwoColumnWidth = 800.0;

  /// Home side rails kept free for future ads (wide skyscraper 160×600),
  /// only on screens at least [adRailMinScreenWidth] wide.
  static const adRailWidth = 160.0;
  static const adRailMinScreenWidth = 1280.0;

  /// Small covers decode at this width; bigger ones at native size (≤ 800).
  static const smallCoverDecodeWidth = 400.0;
  static const stickerTileSize = 140.0;
  static const contentMaxWidth = 1200.0;

  // Player pacing
  static const autoAdvanceDelay = Duration(milliseconds: 1400);

  /// Used when narration audio is missing, so text-only scenes still pace.
  static const silentSceneDuration = Duration(seconds: 5);

  /// Longest wait for story clips to download before the story starts anyway.
  static const preloadTimeout = Duration(seconds: 3);

  /// Pause before reading each choice option (after the question, between options).
  static const choiceOptionGap = Duration(milliseconds: 900);
  static const choiceCelebrateDelay = Duration(milliseconds: 650);

  /// Math stories: pause between numbers of a count ("one, two, three").
  static const countGap = Duration(milliseconds: 250);

  /// Math stories: delay between waiting objects as they `arrive`.
  static const arriveStagger = Duration(milliseconds: 350);

  // Motion
  static const kenBurnsDuration = Duration(seconds: 14);
  static const kenBurnsScale = 1.07;

  /// After the Ken Burns zoom, the picture keeps slowly "breathing".
  static const breatheDuration = Duration(seconds: 8);
  static const breatheScale = 1.02;
  static const breatheDrift = 6.0;

  // Layered scene parts (see `SceneLayers`)
  static const partReactDuration = Duration(milliseconds: 850);

  /// Pose switch on a cue: cross-fade, then a small squash.
  static const poseFadeDuration = Duration(milliseconds: 150);
  static const poseSquashDuration = Duration(milliseconds: 320);

  /// A part travelling to a new spot on a `move` cue.
  static const partMoveDuration = Duration(milliseconds: 600);
  static const blinkMinGap = Duration(milliseconds: 2600);
  static const blinkDuration = Duration(milliseconds: 140);

  /// Extra room around a part's tap box, as a fraction of the picture.
  /// Small fingers miss; the picture also zooms slightly (Ken Burns).
  static const partTapPadding = 0.04;

  // Hotspot bursts on flat AI pictures (see `SceneBurst`)
  static const burstDuration = Duration(milliseconds: 1300);
  static const burstSparkleCount = 12;
  static const burstHeartCount = 6;

  // Ambient scene effects (see `SceneAmbient`)
  static const ambientStarCount = 10;
  static const ambientSparkleCount = 8;
  static const ambientMoteCount = 12;
  static const ambientZzzCount = 3;
  static const sparkleDuration = Duration(milliseconds: 5000);
  static const zzzDuration = Duration(milliseconds: 4500);
  static const moteDuration = Duration(seconds: 9);
  static const sceneFadeDuration = Duration(milliseconds: 600);
  static const twinkleDuration = Duration(milliseconds: 1800);
  static const bobDuration = Duration(milliseconds: 1600);
  static const sleepFadeDuration = Duration(seconds: 12);
}
