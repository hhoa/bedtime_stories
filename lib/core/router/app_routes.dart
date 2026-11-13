import 'package:bedtime_stories/core/models/story_section.dart';

abstract final class AppRoutes {
  /// Sections page (pick behavior or math).
  static const home = '/';
  static const welcome = '/welcome';
  static const sleep = '/sleep';
  static const profile = '/profile';

  // Path patterns for GoRoute definitions
  static const sectionPattern = '/learn/:section';
  static const storyPattern = '/story/:id';
  static const endingPattern = '/story/:id/end';

  // Navigation helpers
  static String section(StorySection section) => '/learn/${section.name}';
  static String story(String id) => '/story/$id';
  static String ending(String id) => '/story/$id/end';
}
