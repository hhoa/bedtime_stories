import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:bedtime_stories/core/models/child_profile.dart';
import 'package:bedtime_stories/core/router/app_routes.dart';
import 'package:bedtime_stories/core/theme/app_colors.dart';
import 'package:bedtime_stories/core/theme/app_spacing.dart';
import 'package:bedtime_stories/core/theme/app_typography.dart';
import 'package:bedtime_stories/core/utils/app_constants.dart';
import 'package:bedtime_stories/core/utils/app_strings.dart';
import 'package:bedtime_stories/core/widgets/kid_buttons.dart';
import 'package:bedtime_stories/core/widgets/language_toggle.dart';
import 'package:bedtime_stories/core/widgets/night_sky.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/language_cubit.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/welcome_cubit.dart';

/// First page: the kid picks girl/boy, a parent types the name and may
/// record it. Also reached from the profile page to edit.
///
/// Never scrolls: the hero picker takes whatever height is left and its
/// avatars shrink to fit. While the keyboard is up only the name field and
/// start button show. Wide-and-short screens (phone landscape) put the
/// picker beside the form.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  /// Below this height the voice hint moves out (phone landscape, small
  /// phones), so the rest still fits.
  static const _hintMinHeight = 640.0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<WelcomeCubit, WelcomeState>(
          listenWhen: (a, b) => !a.saved && b.saved,
          listener: (context, _) => context.go(AppRoutes.home),
        ),
        BlocListener<WelcomeCubit, WelcomeState>(
          listenWhen: (a, b) => !a.micExplain && b.micExplain,
          listener: (context, _) => _showMicExplain(context),
        ),
        BlocListener<WelcomeCubit, WelcomeState>(
          listenWhen: (a, b) => !a.micDenied && b.micDenied,
          listener: (context, _) => showMicHelp(context),
        ),
      ],
      child: Scaffold(
        body: NightSky(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, box) {
                // Keyboard up and little room left (phones): name only.
                final typing =
                    MediaQuery.viewInsetsOf(context).bottom > 0 &&
                    box.maxHeight < 520;
                final wide =
                    box.maxWidth > box.maxHeight && box.maxHeight < 600;
                final showHint = box.maxHeight >= _hintMinHeight;
                final pad = typing ? AppSpace.md : AppSpace.xl;
                final Widget body;
                if (typing) {
                  body = const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _NameField(),
                      SizedBox(height: AppSpace.md),
                      _StartButton(),
                    ],
                  );
                } else if (wide) {
                  body = Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _Title(),
                            SizedBox(height: AppSpace.md),
                            Expanded(child: _HeroPicker()),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpace.xl),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Align(
                              alignment: Alignment.centerRight,
                              child: LanguageToggle(),
                            ),
                            const SizedBox(height: AppSpace.md),
                            const _NameField(),
                            const SizedBox(height: AppSpace.md),
                            _VoiceSection(showHint: showHint),
                            const SizedBox(height: AppSpace.lg),
                            const _StartButton(),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  body = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Align(
                        alignment: Alignment.centerRight,
                        child: LanguageToggle(),
                      ),
                      const _Title(),
                      const SizedBox(height: AppSpace.lg),
                      const Expanded(child: _HeroPicker()),
                      const SizedBox(height: AppSpace.lg),
                      const _NameField(),
                      const SizedBox(height: AppSpace.md),
                      _VoiceSection(showHint: showHint),
                      const SizedBox(height: AppSpace.lg),
                      const _StartButton(),
                    ],
                  );
                }
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: wide ? 1000 : 640 + pad * 2,
                    ),
                    child: Padding(padding: EdgeInsets.all(pad), child: body),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

ShapeBorder get _dialogShape => RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(AppRadius.xl),
  side: const BorderSide(color: AppColors.nightBorder),
);

/// Mic not asked yet: say what the phone/browser is about to ask, then let
/// it ask.
Future<void> _showMicExplain(BuildContext context) {
  final cubit = context.read<WelcomeCubit>();
  final strings = context.readStrings;
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.nightSurface,
      shape: _dialogShape,
      icon: const Icon(Icons.mic_rounded, color: AppColors.amber, size: 40),
      title: Text(strings.micAskTitle, style: AppText.kidLabel),
      content: SingleChildScrollView(
        child: Text(
          kIsWeb ? strings.micAskWeb : strings.micAskApp,
          style: AppText.body,
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsOverflowButtonSpacing: AppSpace.md,
      actions: [
        KidPillButton(
          icon: Icons.close_rounded,
          label: strings.close,
          background: AppColors.lavenderDark,
          onPressed: () => Navigator.of(dialogContext).pop(),
        ),
        KidPillButton(
          icon: Icons.mic_rounded,
          label: strings.continueLabel,
          onPressed: () {
            Navigator.of(dialogContext).pop();
            cubit.startAfterExplain();
          },
        ),
      ],
    ),
  );
}

/// Mic refused (or the parent asked how): explain how to allow it. A web
/// page can't open the browser's settings, so there it lists the steps and
/// offers to retry.
Future<void> showMicHelp(BuildContext context) {
  final cubit = context.read<WelcomeCubit>();
  final strings = context.readStrings;
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.nightSurface,
      shape: _dialogShape,
      icon: const Icon(Icons.mic_off_rounded, color: AppColors.peach, size: 40),
      title: Text(strings.micHelpTitle, style: AppText.kidLabel),
      content: SingleChildScrollView(
        child: Text(micHelpText(strings), style: AppText.body),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsOverflowButtonSpacing: AppSpace.md,
      actions: [
        KidPillButton(
          icon: Icons.close_rounded,
          label: strings.close,
          background: AppColors.lavenderDark,
          onPressed: () => Navigator.of(dialogContext).pop(),
        ),
        if (kIsWeb)
          KidPillButton(
            icon: Icons.mic_rounded,
            label: strings.retry,
            onPressed: () {
              Navigator.of(dialogContext).pop();
              cubit.toggleRecording();
            },
          )
        else
          KidPillButton(
            icon: Icons.settings_rounded,
            label: strings.openSettings,
            onPressed: () {
              Navigator.of(dialogContext).pop();
              cubit.openMicSettings();
            },
          ),
      ],
    ),
  );
}

/// Steps for this platform.
@visibleForTesting
String micHelpText(AppStrings strings) => !kIsWeb
    ? strings.micHelpApp
    : switch (defaultTargetPlatform) {
        TargetPlatform.iOS => strings.micHelpIosWeb,
        TargetPlatform.android => strings.micHelpAndroidWeb,
        _ => strings.micHelpDesktopWeb,
      };

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            strings.welcomeTitle,
            style: AppText.kidDisplay,
            textAlign: TextAlign.center,
          ),
        ).animate().fadeIn().slideY(begin: -0.3),
        Text(
          strings.pickHero,
          style: AppText.kidLabel.copyWith(color: AppColors.lavender),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _HeroPicker extends StatelessWidget {
  const _HeroPicker();

  @override
  Widget build(BuildContext context) {
    final selected = context.select<WelcomeCubit, Gender?>(
      (c) => c.state.gender,
    );
    final cubit = context.read<WelcomeCubit>();
    final strings = context.strings;
    return Center(
      child: ConstrainedBox(
        // Cards never get taller than the full-size avatar needs.
        constraints: const BoxConstraints(
          maxHeight: AppConstants.heroCardMaxSize + 80,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _HeroCard(
                gender: Gender.girl,
                label: strings.girl,
                selected: selected == Gender.girl,
                onTap: () => cubit.selectGender(Gender.girl),
              ),
            ),
            const SizedBox(width: AppSpace.lg),
            Expanded(
              child: _HeroCard(
                gender: Gender.boy,
                label: strings.boy,
                selected: selected == Gender.boy,
                onTap: () => cubit.selectGender(Gender.boy),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.gender,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Gender gender;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: AnimatedScale(
        scale: selected ? 1.04 : 1,
        duration: const Duration(milliseconds: 200),
        child: Material(
          color: selected ? AppColors.nightSurfaceHigh : AppColors.nightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            side: BorderSide(
              color: selected ? AppColors.amber : AppColors.nightBorder,
              width: selected ? 4 : 1.5,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpace.md),
              child: Column(
                children: [
                  // Avatar fills the height left; the label always shows.
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: AppConstants.heroCardMaxSize,
                          maxHeight: AppConstants.heroCardMaxSize,
                        ),
                        child: SvgPicture.asset(
                          AppConstants.heroAvatar(gender.name),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpace.sm),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: AppText.kidLabel.copyWith(
                        color: selected ? AppColors.amber : AppColors.cream,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WelcomeCubit>();
    final strings = context.strings;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      borderSide: const BorderSide(color: AppColors.nightBorder, width: 1.5),
    );
    return TextFormField(
      initialValue: cubit.state.name,
      onChanged: cubit.setName,
      onFieldSubmitted: (_) => cubit.save(),
      maxLength: AppConstants.childNameMaxLength,
      textAlign: TextAlign.center,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.done,
      style: AppText.kidTitle,
      cursorColor: AppColors.amber,
      decoration: InputDecoration(
        hintText: strings.nameHint,
        hintStyle: AppText.kidTitle.copyWith(color: AppColors.creamFaint),
        counterText: '',
        filled: true,
        fillColor: AppColors.nightSurface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpace.xl,
          vertical: AppSpace.md,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: AppColors.amber, width: 3),
        ),
      ),
    );
  }
}

/// Parent-facing: record the name, play it back, delete it, or read how to
/// allow the mic.
class _VoiceSection extends StatelessWidget {
  const _VoiceSection({required this.showHint});

  final bool showHint;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WelcomeCubit>();
    final strings = context.strings;
    return BlocBuilder<WelcomeCubit, WelcomeState>(
      buildWhen: (a, b) =>
          a.voice != b.voice || a.name.trim().isEmpty != b.name.trim().isEmpty,
      builder: (context, state) {
        final recording = state.voice == VoiceStatus.recording;
        final canListen =
            !recording &&
            (state.voice == VoiceStatus.saved || state.name.trim().isNotEmpty);
        const iconSize = AppConstants.kidIconButton * 0.85;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (recording)
              Text(
                    strings.recordingNow,
                    style: AppText.label.copyWith(color: AppColors.pink),
                    textAlign: TextAlign.center,
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fade(begin: 0.4, duration: 700.ms)
            else if (showHint)
              Text(
                strings.voiceHint,
                style: AppText.body.copyWith(color: AppColors.creamFaint),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: AppSpace.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: KidPillButton(
                    icon: recording ? Icons.stop_rounded : Icons.mic_rounded,
                    label: switch (state.voice) {
                      VoiceStatus.recording => strings.stopRecording,
                      VoiceStatus.saved => strings.recordAgain,
                      VoiceStatus.none => strings.recordName,
                    },
                    background: recording ? AppColors.pink : AppColors.lavender,
                    onPressed: cubit.toggleRecording,
                  ),
                ),
                const SizedBox(width: AppSpace.sm),
                KidIconButton(
                  icon: Icons.volume_up_rounded,
                  tooltip: strings.listenName,
                  size: iconSize,
                  background: AppColors.lavenderDark,
                  onPressed: canListen ? () => cubit.previewName() : null,
                ),
                if (state.voice == VoiceStatus.saved) ...[
                  const SizedBox(width: AppSpace.sm),
                  KidIconButton(
                    icon: Icons.delete_outline_rounded,
                    tooltip: strings.deleteRecording,
                    size: iconSize,
                    onPressed: cubit.deleteRecording,
                  ),
                ],
                const SizedBox(width: AppSpace.sm),
                KidIconButton(
                  icon: Icons.help_outline_rounded,
                  tooltip: strings.micHelpButton,
                  size: iconSize,
                  onPressed: () => showMicHelp(context),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton();

  @override
  Widget build(BuildContext context) {
    final canSave = context.select<WelcomeCubit, bool>((c) => c.state.canSave);
    return Center(
      child: AnimatedOpacity(
        opacity: canSave ? 1 : 0.4,
        duration: const Duration(milliseconds: 200),
        child: KidPillButton(
          icon: Icons.arrow_forward_rounded,
          label: context.strings.letsGo,
          onPressed: canSave ? context.read<WelcomeCubit>().save : null,
        ),
      ),
    );
  }
}
