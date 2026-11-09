import 'package:bedtime_stories/core/models/child_profile.dart';

/// UI chrome text in each [AppLanguage]. Story content is data and lives in
/// story JSON. Get the current set with `context.strings`.
abstract final class AppStrings {
  const AppStrings();

  static AppStrings of(AppLanguage language) => switch (language) {
    AppLanguage.vi => const AppStringsVi(),
    AppLanguage.en => const AppStringsEn(),
  };

  // App
  String get appName;
  String get languageVi => 'Tiếng Việt';
  String get languageEn => 'English';
  String get languageLabel;

  // Welcome
  String get welcomeTitle;
  String get pickHero;
  String get girl;
  String get boy;
  String get nameHint;
  String get recordName;
  String get recordAgain;
  String get stopRecording;
  String get recordingNow;
  String get listenName;
  String get deleteRecording;
  String get voiceHint;
  String get micHelpButton;

  /// Before the system mic prompt: what is about to happen.
  String get micAskTitle;
  String get micAskApp;
  String get micAskWeb;
  String get continueLabel;

  /// After the mic was refused: how to turn it back on.
  String get micDenied;
  String get micHelpTitle;
  String get micHelpApp;
  String get micHelpIosWeb;
  String get micHelpAndroidWeb;
  String get micHelpDesktopWeb;
  String get openSettings;
  String get close;
  String get letsGo;

  // Home
  String greeting(String name);
  String get homeSubtitle;
  String get noStories;
  String get loadError;
  String get retry;
  String get openProfile;

  // Profile
  String get profileTitle;
  String stickerTotal(int count);
  String get noStickersYet;
  String get editProfile;
  String get back;

  // Player
  String get home;
  String get listenAgain;
  String get next;

  /// Keep in sync with `UI_LINES['rewind']` in `tool/gen_audio.py`.
  String get rewindQuestion;
  String get tryOtherChoice;
  String get keepGoing;

  // Ending (keep sticker lines in sync with `UI_LINES` in gen_audio.py)
  String get theEnd;
  String stickersEarned(int count);
  String get noSticker;
  String get goodnightButton;
  String get readAgain;

  // Sleep
  String goodnight(String name);
  String get tapToWake;
}

final class AppStringsVi extends AppStrings {
  const AppStringsVi();

  @override
  String get appName => 'Truyện trước giờ ngủ';
  @override
  String get languageLabel => 'Ngôn ngữ';

  @override
  String get welcomeTitle => 'Chào bé!';
  @override
  String get pickHero => 'Bé là bạn gái hay bạn trai?';
  @override
  String get girl => 'Bé gái';
  @override
  String get boy => 'Bé trai';
  @override
  String get nameHint => 'Tên của bé';
  @override
  String get recordName => 'Ghi âm tên';
  @override
  String get recordAgain => 'Ghi âm lại';
  @override
  String get stopRecording => 'Xong';
  @override
  String get recordingNow => 'Đang ghi âm... nói tên bé nhé';
  @override
  String get listenName => 'Nghe thử';
  @override
  String get deleteRecording => 'Xoá bản ghi âm';
  @override
  String get voiceHint =>
      'Ghi âm tên để truyện gọi bé bằng giọng nhà mình. Không ghi âm thì '
      'truyện gọi là "bé".';
  @override
  String get micHelpButton => 'Cách cho phép micrô';

  @override
  String get micAskTitle => 'Ghi âm tên bé';
  @override
  String get micAskApp =>
      'Máy sẽ hỏi có cho ứng dụng dùng micrô không.\n'
      'Hãy chọn "Cho phép" (Android: "Khi dùng ứng dụng").\n\n'
      'Bản ghi chỉ lưu trên máy này.';
  @override
  String get micAskWeb =>
      'Trình duyệt sẽ hỏi có cho trang này dùng micrô không.\n'
      'Hãy bấm "Cho phép".\n\n'
      'Bản ghi chỉ lưu trên trình duyệt này.';
  @override
  String get continueLabel => 'Tiếp tục';

  @override
  String get micDenied => 'Chưa được phép dùng micrô.';
  @override
  String get micHelpTitle => 'Cho phép dùng micrô';
  @override
  String get micHelpApp =>
      'Để ghi âm tên bé, hãy bật Micrô cho ứng dụng trong Cài đặt:\n'
      'iPhone/iPad: Cài đặt → Truyện trước giờ ngủ → Micrô.\n'
      'Android: Cài đặt → Ứng dụng → Truyện trước giờ ngủ → Quyền → Micrô.\n'
      'Rồi quay lại bấm "Ghi âm tên".';
  @override
  String get micHelpIosWeb =>
      'Để ghi âm tên bé, hãy cho trang này dùng micrô:\n'
      '1. Bấm nút "aA" hoặc ⋯ cạnh thanh địa chỉ Safari\n'
      '2. Chọn "Cài đặt trang web"\n'
      '3. Micrô → "Cho phép"\n\n'
      'Vẫn không được? Mở Cài đặt iPhone → Safari (hoặc Chrome) → Micrô → '
      'chọn "Hỏi" hoặc "Cho phép", rồi tải lại trang.';
  @override
  String get micHelpAndroidWeb =>
      'Để ghi âm tên bé, hãy cho trang này dùng micrô:\n'
      '1. Bấm biểu tượng cạnh địa chỉ trang (ổ khoá hoặc cài đặt)\n'
      '2. Chọn "Quyền" → Micrô → "Cho phép"\n'
      '3. Quay lại bấm "Thử lại"';
  @override
  String get micHelpDesktopWeb =>
      'Để ghi âm tên bé, bấm biểu tượng cạnh địa chỉ trang, cho phép '
      'Micrô, rồi bấm "Thử lại".';
  @override
  String get openSettings => 'Mở Cài đặt';
  @override
  String get close => 'Đóng';
  @override
  String get letsGo => 'Bắt đầu nào!';

  @override
  String greeting(String name) => 'Chào $name!';
  @override
  String get homeSubtitle => 'Tối nay mình nghe truyện gì nhỉ?';
  @override
  String get noStories => 'Truyện mới sắp có rồi!';
  @override
  String get loadError => 'Không mở được truyện.';
  @override
  String get retry => 'Thử lại';
  @override
  String get openProfile => 'Sticker của bé';

  @override
  String get profileTitle => 'Sticker của bé';
  @override
  String stickerTotal(int count) => '$count sticker';
  @override
  String get noStickersYet =>
      'Nghe truyện và chọn thật ngoan để nhận sticker nhé!';
  @override
  String get editProfile => 'Sửa thông tin';
  @override
  String get back => 'Quay lại';

  @override
  String get home => 'Về trang chủ';
  @override
  String get listenAgain => 'Nghe lại';
  @override
  String get next => 'Tiếp theo';
  @override
  String get rewindQuestion => 'Mình thử chọn cách khác xem sao nhé?';
  @override
  String get tryOtherChoice => 'Chọn lại';
  @override
  String get keepGoing => 'Đi tiếp';

  @override
  String get theEnd => 'Hết truyện rồi!';
  @override
  String stickersEarned(int count) =>
      count == 1 ? 'Bé nhận được một sticker!' : 'Bé nhận được $count sticker!';
  @override
  String get noSticker =>
      'Lần sau mình thử chọn cách khác để nhận sticker nhé!';
  @override
  String get goodnightButton => 'Đi ngủ thôi';
  @override
  String get readAgain => 'Đọc lại truyện';

  @override
  String goodnight(String name) => 'Chúc $name ngủ ngon';
  @override
  String get tapToWake => 'Chạm để quay lại';
}

final class AppStringsEn extends AppStrings {
  const AppStringsEn();

  @override
  String get appName => 'Bedtime Stories';
  @override
  String get languageLabel => 'Language';

  @override
  String get welcomeTitle => 'Hello there!';
  @override
  String get pickHero => 'Are you a girl or a boy?';
  @override
  String get girl => 'Girl';
  @override
  String get boy => 'Boy';
  @override
  String get nameHint => "Child's name";
  @override
  String get recordName => 'Record name';
  @override
  String get recordAgain => 'Record again';
  @override
  String get stopRecording => 'Done';
  @override
  String get recordingNow => 'Recording... say the name';
  @override
  String get listenName => 'Listen';
  @override
  String get deleteRecording => 'Delete recording';
  @override
  String get voiceHint =>
      'Record the name so stories call your child in your voice. Without a '
      'recording, stories say "sweetie".';
  @override
  String get micHelpButton => 'How to allow the mic';

  @override
  String get micAskTitle => "Record your child's name";
  @override
  String get micAskApp =>
      'Your device will ask whether this app may use the microphone.\n'
      'Choose "Allow" (Android: "While using the app").\n\n'
      'The recording stays on this device.';
  @override
  String get micAskWeb =>
      'Your browser will ask whether this page may use the microphone.\n'
      'Tap "Allow".\n\n'
      'The recording stays in this browser.';
  @override
  String get continueLabel => 'Continue';

  @override
  String get micDenied => 'Microphone not allowed yet.';
  @override
  String get micHelpTitle => 'Allow the microphone';
  @override
  String get micHelpApp =>
      "To record your child's name, turn on the Microphone for this app in "
      'Settings:\n'
      'iPhone/iPad: Settings → Bedtime Stories → Microphone.\n'
      'Android: Settings → Apps → Bedtime Stories → Permissions → '
      'Microphone.\n'
      'Then come back and tap "Record name".';
  @override
  String get micHelpIosWeb =>
      "To record your child's name, let this page use the microphone:\n"
      '1. Tap "aA" or ⋯ next to the Safari address bar\n'
      '2. Choose "Website Settings"\n'
      '3. Microphone → "Allow"\n\n'
      'Still not working? Open iPhone Settings → Safari (or Chrome) → '
      'Microphone → "Ask" or "Allow", then reload the page.';
  @override
  String get micHelpAndroidWeb =>
      "To record your child's name, let this page use the microphone:\n"
      '1. Tap the icon next to the address (lock or settings)\n'
      '2. Choose "Permissions" → Microphone → "Allow"\n'
      '3. Come back and tap "Try again"';
  @override
  String get micHelpDesktopWeb =>
      "To record your child's name, click the icon next to the address, "
      'allow the Microphone, then click "Try again".';
  @override
  String get openSettings => 'Open Settings';
  @override
  String get close => 'Close';
  @override
  String get letsGo => "Let's go!";

  @override
  String greeting(String name) => 'Hi $name!';
  @override
  String get homeSubtitle => 'Which story tonight?';
  @override
  String get noStories => 'New stories are coming soon!';
  @override
  String get loadError => "Couldn't open the stories.";
  @override
  String get retry => 'Try again';
  @override
  String get openProfile => 'My stickers';

  @override
  String get profileTitle => 'My stickers';
  @override
  String stickerTotal(int count) =>
      count == 1 ? '1 sticker' : '$count stickers';
  @override
  String get noStickersYet =>
      'Listen to a story and make kind choices to earn stickers!';
  @override
  String get editProfile => 'Edit profile';
  @override
  String get back => 'Back';

  @override
  String get home => 'Home';
  @override
  String get listenAgain => 'Listen again';
  @override
  String get next => 'Next';
  @override
  String get rewindQuestion => 'Shall we try the other choice?';
  @override
  String get tryOtherChoice => 'Try again';
  @override
  String get keepGoing => 'Keep going';

  @override
  String get theEnd => 'The end!';
  @override
  String stickersEarned(int count) =>
      count == 1 ? 'You got a sticker!' : 'You got $count stickers!';
  @override
  String get noSticker => 'Next time, try another choice to get a sticker!';
  @override
  String get goodnightButton => 'Time for bed';
  @override
  String get readAgain => 'Read again';

  @override
  String goodnight(String name) => 'Good night, $name';
  @override
  String get tapToWake => 'Tap to come back';
}
