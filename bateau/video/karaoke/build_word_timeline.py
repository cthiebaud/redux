#!/usr/bin/env python3
"""Shifts and truncates cache/word_timestamps.json (WhisperX's raw
word-level alignment, done against the vocal-only stem
bateau_suno_stems202611211922-normalized.wav) onto the timeline of
cache/bateau-solo-plus-voice.wav -- a separate, shorter mix (guitar +
voice) that starts the poem later and fades out partway through it.

The two takes aren't time-stretched relative to each other, just offset:
the first word ("Comme") is known (by ear) to land at OFFSET_START in
the new mix instead of its raw aligned timestamp, so every word shifts
by the same constant amount. Cross-checked: projecting that same offset
onto the word "troupeaux" -- by ear, the last word audible before the
new mix fades out -- lands at ~194.4s, a few seconds before the mix's
actual end (~200.6s), consistent with "last heard right before the
fade-out finishes", not stretched.

Words after CUTOFF_WORD are dropped entirely: this shorter mix doesn't
contain the rest of the poem (quatrains 13-25) at all.

Run after re-generating cache/word_timestamps.json:
    python3 build_word_timeline.py
"""

import json
import pathlib

HERE = pathlib.Path(__file__).parent
WORDS_IN = HERE / "cache" / "word_timestamps.json"
BUILD_DIR = HERE / "build"
OUT = BUILD_DIR / "word_timestamps_solo_plus_voice.json"

NEW_AUDIO = "cache/bateau-solo-plus-voice.wav"
NEW_DURATION = 200.605313  # ffprobe -show_entries format=duration

FIRST_WORD = "Comme"
OFFSET_START = 36.92  # where FIRST_WORD actually lands in NEW_AUDIO, by ear
CUTOFF_WORD = "troupeaux"  # last word heard before NEW_AUDIO fades out
CUTOFF_PRECEDING = "glauques"  # disambiguates which "troupeaux" (only one, but cheap to check)


def strip_punct(w):
    return w.strip(",.!?;:—").lower()


def main():
    words = json.loads(WORDS_IN.read_text(encoding="utf-8"))
    assert words[0]["word"] == FIRST_WORD, f"expected first word {FIRST_WORD!r}, got {words[0]['word']!r}"
    offset = OFFSET_START - words[0]["start"]

    texts = [strip_punct(w["word"]) for w in words]
    cutoff_idx = next(
        i for i in range(1, len(words))
        if texts[i] == strip_punct(CUTOFF_WORD) and texts[i - 1] == strip_punct(CUTOFF_PRECEDING)
    )

    kept = words[: cutoff_idx + 1]
    shifted = [
        {"word": w["word"], "start": round(w["start"] + offset, 3), "end": round(w["end"] + offset, 3)}
        for w in kept
    ]

    print(f"offset: {offset:.3f}s")
    print(f"kept {len(shifted)} words, last: {shifted[-1]}")
    print(f"fade-out tail after last word: {NEW_DURATION - shifted[-1]['end']:.3f}s")

    BUILD_DIR.mkdir(exist_ok=True)
    OUT.write_text(
        json.dumps({"audio": NEW_AUDIO, "duration": NEW_DURATION, "words": shifted}, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    print(f"wrote {OUT}")


if __name__ == "__main__":
    main()
