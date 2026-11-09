abstract final class AppRoutes {
  static const home = '/';
  static const welcome = '/welcome';
  static const sleep = '/sleep';
  static const profile = '/profile';

  // Path patterns for GoRoute definitions
  static const storyPattern = '/story/:id';
  static const endingPattern = '/story/:id/end';

  // Navigation helpers
  static String story(String id) => '/story/$id';
  static String ending(String id) => '/story/$id/end';
}
