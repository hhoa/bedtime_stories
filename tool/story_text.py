"""Tokens in story lines, shared by gen_audio.py, cue_times.py and check_story.py.

Must match lib/features/stories/domain/entities/math.dart (tokenize, evalMath):
  {name}            the child's name (parent's recording)
  {a}               a math number (shared clip audio/ui/<lang>/num_<n>.m4a); {n} on an option = its own number
  {count:a}         "one, two, three…" with object k hopping on number k ({count:a:sleep}: pose instead)
A line is cut at every token; the words between tokens are its clips <key>_p<i> (i = piece index,
letter-less pieces skipped), or <key> when the line has no token.
"""
from __future__ import annotations

import re

TOKEN = re.compile(r'\{(name|count:[a-z]\w*(?::[a-z]\w*)?|[a-z]\w*)\}')
NUMBER_WORDS = {
    'vi': ['không', 'một', 'hai', 'ba', 'bốn', 'năm', 'sáu', 'bảy', 'tám', 'chín', 'mười'],
    'en': ['zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten'],
}
MAX_SPOKEN = 10


def pieces(text: str) -> list[tuple[int, int]]:
    """(start, end) of each words piece between tokens, in order."""
    out, at = [], 0
    for m in TOKEN.finditer(text):
        out.append((at, m.start()))
        at = m.end()
    out.append((at, len(text)))
    return out


def tokens(text: str) -> list[tuple[str, str | None, str | None]]:
    """('words', text, None) | ('name', None, None) | ('number', var, None) | ('count', var, pose)."""
    out, at = [], 0
    for m in TOKEN.finditer(text):
        out.append(('words', text[at:m.start()], None))
        body = m.group(1)
        if body == 'name':
            out.append(('name', None, None))
        elif body.startswith('count:'):
            parts = body.split(':')
            out.append(('count', parts[1], parts[2] if len(parts) > 2 else None))
        else:
            out.append(('number', body, None))
        at = m.end()
    out.append(('words', text[at:], None))
    return out


def plain(text: str) -> str:
    """The line with tokens taken out (for word counts and checks)."""
    return TOKEN.sub(' ', text)


def eval_math(expr: str, values: dict[str, int]) -> int:
    """'2', 'a', 'a + b', '5 - c': integers and variables joined by + / -."""
    toks = re.findall(r'[+-]|\d+|[a-z]\w*', str(expr))
    if not toks or ''.join(toks) != str(expr).replace(' ', ''):
        raise ValueError(f'can\'t read "{expr}"')
    total, sign, want_value = 0, 1, True
    for t in toks:
        if want_value:
            if t.isdigit():
                n = int(t)
            elif t in values:
                n = values[t]
            else:
                raise ValueError(f'unknown "{t}" in "{expr}"')
            total += sign * n
            want_value = False
        else:
            if t not in '+-':
                raise ValueError(f'expected + or - in "{expr}"')
            sign = 1 if t == '+' else -1
            want_value = True
    if want_value:
        raise ValueError(f'"{expr}" ends early')
    return total


def all_draws(vars_: dict) -> list[dict[str, int]]:
    """Every combination of the math vars (file order; a range may use the vars above it)."""
    out = [{}]
    for name, spec in vars_.items():
        nxt = []
        for values in out:
            if isinstance(spec, list):
                lo, hi = eval_math(spec[0], values), eval_math(spec[1], values)
                choices = range(lo, hi + 1)
            else:
                choices = [eval_math(spec, values)]
            nxt += [{**values, name: v} for v in choices if v >= 0]
        out = nxt
    return out



def has_numbers(text: str) -> bool:
    """True when the line has a number or count token (not just {name})."""
    return any(kind in ('number', 'count') for kind, _, _ in tokens(text))


def example_values(story: dict) -> dict[str, int]:
    """The fixed numbers the parent reads when recording a template line in one go
    ("<key>_full", cut by tool/split_numbers.py). Picks the draw whose numbers are most
    varied (fewer repeats = easier to find each number in the recording), then the first."""
    math = story.get('math')
    if not math:
        return {}
    draws = all_draws(math.get('vars') or {})
    return max(draws, key=lambda d: (len(set(d.values())), -sum(d.values()))) if draws else {}


def example_text(text: str, lang: str, values: dict[str, int], n: int | None = None) -> str:
    """The line as the parent says it in one go: numbers written out, {name} left out
    (the name is the parent's own recording)."""
    words = NUMBER_WORDS[lang]
    vals = {**values, **({'n': n} if n is not None else {})}
    out = []
    for kind, value, _ in tokens(text):
        if kind == 'words':
            out.append(value)
        elif kind == 'number':
            out.append(words[vals[value]])
        elif kind == 'count':
            out.append(', '.join(words[i] for i in range(1, vals[value] + 1)))
    line = re.sub(r'\s+', ' ', ''.join(out)).strip(' ,')
    line = re.sub(r'\s+([.,!?…”]|"(?=\s|$|[.,!?]))', r'\1', line)
    line = re.sub(r',([.!?])', r'\1', line)
    # Capital letter at each sentence start (incl. after an opening quote).
    return re.sub(r'(^|[.!?…]\s+|[.!?…:,]\s*["“]\s*)(\w)', lambda m: m.group(1) + m.group(2).upper(), line)


def option_example(story: dict, answer: str, values: dict[str, int]) -> int:
    """The number an option card says in the example play (near miss: one less, or one more)."""
    if answer.startswith('near:'):
        right = eval_math(answer[5:], values)
        return right - 1 if right > 1 else right + 1
    return eval_math(answer, values)
