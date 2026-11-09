import 'package:bedtime_stories/core/services/narrator.dart';
import 'package:bedtime_stories/core/services/web_audio_narrator.dart';

Narrator createPlatformNarrator() => WebAudioNarrator();
