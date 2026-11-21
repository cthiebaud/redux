#!/usr/bin/env python3
"""Renders a word-by-word "karaoke" highlight video for the
bateau-solo-plus-voice take (guitar + spoken/rapped voice), from
build/word_timestamps_solo_plus_voice.json (word-level timestamps,
produced by WhisperX forced-alignment -- see align_whisperx_colab.ipynb
-- then time-shifted onto this specific mix and truncated to the words
it actually contains, quatrains 1-12 only).

Groups words back into their original verse lines (bateau_ivre.yaml),
burns them in as ASS subtitles -- one Dialogue event per WORD, each
showing the full line with only that one word's colour overridden via
an inline \\c tag, active only during that word's own [start,end).
(Tried libass's native \\k karaoke tag first: confirmed by an isolated
test that it does NOT give a single spotlighted "current word" -- it
just permanently flips each word from Secondary to Primary the instant
its own turn starts, so already-said and not-yet-said words end up
looking identical. Per-word Dialogue events sidestep that entirely, and
are far cheaper than one ffmpeg drawtext filter per word would have
been -- libass lays out and positions the (identical, line-sized) text
itself every time, we never compute pixel offsets by hand.)

Run:
    python3 generate_video_karaoke.py
"""

import json
import pathlib
import subprocess
import sys

import yaml

HERE = pathlib.Path(__file__).parent
VIDEO_DIR = HERE.parent
BATEAU_DIR = VIDEO_DIR.parent
IVRE_YAML = BATEAU_DIR / "bateau_ivre.yaml"
WORDS_JSON = HERE / "build" / "word_timestamps_solo_plus_voice.json"
BUILD_DIR = HERE / "build"
DIST_DIR = HERE / "dist"
ASS_OUT = BUILD_DIR / "bateau_solo_plus_voice.ass"
OUTPUT = DIST_DIR / "bateau_solo_plus_voice.mp4"
# Shared with the other (chord-caption) video -- lives one level up, not
# duplicated into karaoke/.
BACKGROUND = VIDEO_DIR / "Rimbaud-in-the-Place-Vendome-1_16x9.png"

WIDTH, HEIGHT, FPS = 1920, 1080, 30
FONT = "URW Bookman"
FONT_SIZE = 64

# ASS style-definition colours are &HAABBGGRR (alpha inverted: 00 =
# opaque, FF = transparent).
COLOR_WHITE = "&H00FFFFFF"      # not-currently-spoken text (style default)
COLOR_OUTLINE = "&H00000000"    # black outline
COLOR_BOX = "&H80000000"        # ~50% transparent black box behind text
# Inline \c override colours are &HBBGGRR& (no alpha byte).
INLINE_HIGHLIGHT = r"\c&H00D9FF&"  # word currently being spoken (gold)
INLINE_WHITE = r"\c&HFFFFFF&"


def load_quatrains(n_quatrains):
    sections = yaml.safe_load(IVRE_YAML.read_text(encoding="utf-8"))
    by_number = {}
    for entry in sections:
        for strophe in entry["strophes"]:
            by_number[strophe["strophe"]] = strophe["vers"]
    lines = []
    for n in range(1, n_quatrains + 1):
        lines.extend(by_number[n])
    return lines


def group_words_by_line(lines, words):
    """Splits the flat word list back into per-verse-line groups, using
    each known line's own word count -- exact, not fuzzy, since these
    words came from forced-aligning this very text (verified 0
    mismatches against bateau_ivre.yaml when this was built)."""
    idx = 0
    groups = []
    for line in lines:
        n_tok = len(line.split())
        chunk = words[idx : idx + n_tok]
        if not chunk:
            break
        groups.append((line, chunk))
        idx += len(chunk)
    return groups


def ass_timestamp(t):
    h = int(t // 3600)
    m = int((t % 3600) // 60)
    s = t % 60
    return f"{h:d}:{m:02d}:{s:05.2f}"


def build_ass(groups, duration):
    header = f"""[Script Info]
Title: bateau-solo-plus-voice karaoke
ScriptType: v4.00+
PlayResX: {WIDTH}
PlayResY: {HEIGHT}
WrapStyle: 0
ScaledBorderAndShadow: yes

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Karaoke,{FONT},{FONT_SIZE},{COLOR_WHITE},{COLOR_WHITE},{COLOR_OUTLINE},{COLOR_BOX},0,0,0,0,100,100,0,0,3,0,0,2,80,80,100,1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
"""
    events = []
    for line, chunk in groups:
        for i, w in enumerate(chunk):
            # Active window: from this word's own start up to the NEXT
            # word's start (not its own end), so the line never goes
            # blank in the gap between two words -- except the last
            # word in the line, which just runs to its own end.
            seg_start = w["start"]
            seg_end = chunk[i + 1]["start"] if i + 1 < len(chunk) else w["end"]
            words_text = [
                f"{{{INLINE_HIGHLIGHT}}}{cw['word']}{{{INLINE_WHITE}}}" if j == i else cw["word"]
                for j, cw in enumerate(chunk)
            ]
            text = " ".join(words_text)
            events.append(
                f"Dialogue: 0,{ass_timestamp(seg_start)},{ass_timestamp(seg_end)},Karaoke,,0,0,0,,{text}"
            )
    return header + "\n".join(events) + "\n"


def esc_path(p):
    # ffmpeg filtergraph option values: escape ':' so it isn't read as a
    # filter-option separator.
    return str(p).replace(":", r"\:").replace("'", r"\'")


def main():
    data = json.loads(WORDS_JSON.read_text(encoding="utf-8"))
    words, duration, audio_path = data["words"], data["duration"], HERE / data["audio"]

    lines = load_quatrains(12)
    groups = group_words_by_line(lines, words)
    print(f"{len(groups)} verse lines, {sum(len(c) for _, c in groups)} words")

    BUILD_DIR.mkdir(exist_ok=True)
    DIST_DIR.mkdir(exist_ok=True)

    ass_content = build_ass(groups, duration)
    ASS_OUT.write_text(ass_content, encoding="utf-8")
    print(f"wrote {ASS_OUT}")

    if not BACKGROUND.exists():
        sys.exit(f"Missing background image: {BACKGROUND}")
    if not audio_path.exists():
        sys.exit(f"Missing audio: {audio_path}")

    filter_complex = (
        f"[0:v]scale={WIDTH}:{HEIGHT}:force_original_aspect_ratio=increase,"
        f"crop={WIDTH}:{HEIGHT},fps={FPS},setsar=1,"
        f"subtitles='{esc_path(ASS_OUT)}'[v]"
    )
    cmd = [
        "ffmpeg", "-y",
        "-loop", "1", "-t", f"{duration:.3f}", "-i", str(BACKGROUND),
        "-i", str(audio_path),
        "-filter_complex", filter_complex,
        "-map", "[v]", "-map", "1:a",
        "-t", f"{duration:.3f}",
        "-c:v", "libx264", "-preset", "medium", "-crf", "16", "-pix_fmt", "yuv420p",
        "-c:a", "aac", "-b:a", "192k",
        str(OUTPUT),
    ]
    print("Running ffmpeg...")
    subprocess.run(cmd, check=True)
    print(f"Wrote {OUTPUT}")


if __name__ == "__main__":
    main()
