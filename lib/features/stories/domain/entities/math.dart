import 'dart:math';

import 'package:bedtime_stories/core/models/child_profile.dart';

/// Numbers drawn fresh for each play of a math story (`"math"` in
/// story.json, see `docs/math.md`).
///
/// Every variable is either a fixed expression (`"c": "a + b"`) or an
/// inclusive range whose ends may be expressions (`"b": [1, "4 - a"]`).
/// Variables are drawn in file order, so a range may use the ones above it.
final class MathSpec {
  const MathSpec({
    required this.counter,
    required this.vars,
    required this.field,
    this.wait = const [],
    this.iconAsset,
  });

  /// Part kind prefix of the counted objects: `sheep` = parts `sheep1`,
  /// `sheep2`… in counting order (left to right).
  final String counter;

  final List<MathVar> vars;

  /// Where counted object k stands (pivot), k = 1…[field].length. Also the
  /// most objects a story can show.
  final List<({double x, double y})> field;

  /// Where newcomers wait before they `arrive`, in order.
  final List<({double x, double y})> wait;

  /// One counted object (transparent picture) for the answer cards.
  final String? iconAsset;

  int get max => field.length;

  String part(int k) => '$counter$k';

  /// Draws every variable. Ranges that come out empty (min > max) are
  /// drawn again from the start; a spec that never works throws.
  Map<String, int> draw(Random random) {
    for (var attempt = 0; attempt < 200; attempt++) {
      final values = <String, int>{};
      var ok = true;
      for (final v in vars) {
        final value = v.draw(values, random);
        if (value == null || value < 0) {
          ok = false;
          break;
        }
        values[v.name] = value;
      }
      if (ok) return values;
    }
    throw const FormatException('math vars: no numbers fit the ranges');
  }

  /// Every combination [draw] can return (for checks and tests).
  List<Map<String, int>> allDraws() {
    var out = <Map<String, int>>[{}];
    for (final v in vars) {
      out = [
        for (final values in out)
          for (final value in v.choices(values)) {...values, v.name: value},
      ];
    }
    return out;
  }
}

final class MathVar {
  const MathVar.fixed(this.name, String expression)
    : value = expression,
      min = null,
      max = null;

  const MathVar.range(this.name, String this.min, String this.max)
    : value = null;

  final String name;
  final String? value;
  final String? min;
  final String? max;

  List<int> choices(Map<String, int> values) {
    final fixed = value;
    if (fixed != null) return [evalMath(fixed, values)];
    final lo = evalMath(min!, values);
    final hi = evalMath(max!, values);
    return [for (var i = lo; i <= hi; i++) i];
  }

  int? draw(Map<String, int> values, Random random) {
    final options = choices(values);
    return options.isEmpty ? null : options[random.nextInt(options.length)];
  }
}

/// `2`, `a`, `a + b`, `5 - c`, `a + b - 1`: integers and variables joined
/// by `+` / `-`.
int evalMath(String expression, Map<String, int> values) {
  final tokens = RegExp(
    r'\s*([+-]|\d+|[a-z]\w*)\s*',
  ).allMatches(expression).map((m) => m.group(1)!).toList();
  if (tokens.join() != expression.replaceAll(' ', '') || tokens.isEmpty) {
    throw FormatException('math: can\'t read "$expression"');
  }
  var total = 0;
  var sign = 1;
  var expectValue = true;
  for (final t in tokens) {
    if (expectValue) {
      final n = int.tryParse(t) ?? values[t];
      if (n == null) throw FormatException('math: unknown "$t" in $expression');
      total += sign * n;
      expectValue = false;
    } else {
      sign = switch (t) {
        '+' => 1,
        '-' => -1,
        _ => throw FormatException('math: expected + or - in $expression'),
      };
      expectValue = true;
    }
  }
  if (expectValue) throw FormatException('math: "$expression" ends early');
  return total;
}

/// The wrong answer next to [right]: one more or one less, never 0 nor
/// above [max].
int nearMiss(int right, int max, Random random) {
  final options = [
    if (right - 1 >= 1) right - 1,
    if (right + 1 <= max) right + 1,
  ];
  return options[random.nextInt(options.length)];
}

/// Spoken number words (UI clips `num_<n>`). Keep in sync with `UI_LINES` in
/// `tool/gen_audio.py`.
const numberWords = {
  AppLanguage.vi: [
    'không',
    'một',
    'hai',
    'ba',
    'bốn',
    'năm',
    'sáu',
    'bảy',
    'tám',
    'chín',
    'mười',
  ],
  AppLanguage.en: [
    'zero',
    'one',
    'two',
    'three',
    'four',
    'five',
    'six',
    'seven',
    'eight',
    'nine',
    'ten',
  ],
};

/// Most a number token may say (clips `num_1` … `num_10`).
const maxSpokenNumber = 10;

// ---------------------------------------------------------------------------
// Text tokens

/// A piece of a line between tokens, or a token.
sealed class TextToken {
  const TextToken();
}

/// Plain words, read from the line's own clip.
final class WordsToken extends TextToken {
  const WordsToken(this.text);
  final String text;
}

/// `{name}`: the child's name.
final class NameToken extends TextToken {
  const NameToken();
}

/// `{a}`: a number variable (`{n}` on an option = its own number).
final class NumberToken extends TextToken {
  const NumberToken(this.variable);
  final String variable;
}

/// `{count:a}` (each object hops) or `{count:a:sleep}` (each switches to
/// that pose): "one, two, three…", object k reacting on number k.
final class CountToken extends TextToken {
  const CountToken(this.variable, [this.pose]);
  final String variable;
  final String? pose;
}

/// Matches `{name}`, `{a}`, `{count:a}`, `{count:a:pose}`.
final tokenPattern = RegExp(
  r'\{(name|count:[a-z]\w*(?::[a-z]\w*)?|[a-z]\w*)\}',
);

/// Splits [text] into words and tokens, in order. Words between two tokens
/// are kept even when they are only punctuation, so the piece index used by
/// clip names (`_p<i>`) matches `tool/gen_audio.py`.
List<TextToken> tokenize(String text) {
  final out = <TextToken>[];
  var at = 0;
  for (final m in tokenPattern.allMatches(text)) {
    out.add(WordsToken(text.substring(at, m.start)));
    final body = m.group(1)!;
    if (body == 'name') {
      out.add(const NameToken());
    } else if (body.startsWith('count:')) {
      final parts = body.split(':');
      out.add(CountToken(parts[1], parts.length > 2 ? parts[2] : null));
    } else {
      out.add(NumberToken(body));
    }
    at = m.end;
  }
  out.add(WordsToken(text.substring(at)));
  return out;
}

/// True when [text] has any token besides plain words.
bool hasTokens(String text) => tokenPattern.hasMatch(text);

/// [text] with number and count tokens written out in [language]
/// (`{name}` is left for `resolveName`). A number that starts a sentence is
/// capitalised.
String spellNumbers(
  String text,
  AppLanguage language,
  Map<String, int> values,
) {
  final words = numberWords[language]!;
  String word(String variable) {
    final n = values[variable];
    return n == null || n < 0 || n >= words.length ? '?' : words[n];
  }

  final out = StringBuffer();
  for (final t in tokenize(text)) {
    final piece = switch (t) {
      WordsToken(:final text) => text,
      NameToken() => '{name}',
      NumberToken(:final variable) => word(variable),
      CountToken(:final variable) => [
        for (var i = 1; i <= (values[variable] ?? 0); i++)
          i < words.length ? words[i] : '?',
      ].join(', '),
    };
    final before = out.toString();
    final sentenceStart = RegExp(
      r'(^|[.!?…]["”»]?\s+|^["“«]|[.!?…:,]\s*["“«])$',
    ).hasMatch(before);
    out.write(
      t is WordsToken || t is NameToken || !sentenceStart || piece.isEmpty
          ? piece
          : piece[0].toUpperCase() + piece.substring(1),
    );
  }
  return out.toString();
}
