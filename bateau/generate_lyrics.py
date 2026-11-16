#!/usr/bin/env python3
"""Generate bateau_lyrics.ily and bateau_poem_continuation.ily from
bateau_ivre.yaml.

bateau_ivre.yaml is the single source of truth for the poem's words.
This script keeps two things in sync with it:

  - bateau_lyrics.ily: the \\lyricmode variables for quatrains 1-9, which
    are sung in the score (their split points and spacing hacks are tied
    to the music's melisma timing, so that layout stays hardcoded here,
    not in the yaml)
  - bateau_poem_continuation.ily: one top-level \\markup block per section
    group for the plain-text remainder of the poem (quatrains 10-25),
    under the same section dividers used elsewhere in the score. Kept as
    separate top-level blocks (not one big markup) so LilyPond's normal
    page breaking can distribute them instead of squashing everything
    onto one page.

Run after editing the yaml, before compiling bateau.3.ly:
    python3 generate_lyrics.py
"""

import pathlib
import yaml

HERE = pathlib.Path(__file__).parent
YAML_PATH = HERE / "bateau_ivre.yaml"
LYRICS_OUT_PATH = HERE / "bateau_lyrics.ily"
POEM_OUT_PATH = HERE / "bateau_poem_continuation.ily"


def load_strophes():
    sections = yaml.safe_load(YAML_PATH.read_text(encoding="utf-8"))
    by_number = {}
    order = []  # [(section_name, [strophe_numbers...]), ...] in file order
    for entry in sections:
        numbers = []
        for strophe in entry["strophes"]:
            by_number[strophe["strophe"]] = strophe
            numbers.append(strophe["strophe"])
        order.append((entry["section"], numbers))
    return by_number, order


def v(by_number, strophe, idx):
    return by_number[strophe]["vers"][idx]


def sym(by_number, strophe):
    return by_number[strophe]["symbole"]


def render_sung_lyrics(by_number):
    s = by_number
    return f"""% VAMP
textOne = \\lyricmode {{
  \\offsetLeft "{sym(s,1)} {v(s,1,0)}"
  \\offsetRight "{v(s,1,1)}"
}} textOneAndAHalf = \\lyricmode {{
  \\offsetLeft "{v(s,1,2)}"
  \\offsetRight "{v(s,1,3)}"
}}

% SEQUENCE
textTwoThreeFourFive = \\lyricmode {{
  \\offsetLeft "{sym(s,2)} {v(s,2,0)}"
  \\offsetRight "{v(s,2,1)}"
  \\offsetLeft "{v(s,2,2)}"
  \\offsetRight "{v(s,2,3)}"

  \\offsetLeft "{sym(s,3)} {v(s,3,0)}"
  \\offsetRight "{v(s,3,1)}"
  \\offsetLeft "{v(s,3,2)}"
  \\offsetRight "{v(s,3,3)}"

  \\offsetLeft "{sym(s,4)} {v(s,4,0)}"
  \\offsetRight "{v(s,4,1)}"
  \\offsetLeft "{v(s,4,2)}"
  \\offsetRight "{v(s,4,3)}"

  \\offsetLeft "{sym(s,5)} {v(s,5,0)}"
  \\offsetRight "{v(s,5,1)}"
  \\offsetLeft "{v(s,5,2)}"
  \\offsetRight "{v(s,5,3)}" " "
}}

% CLIMAX
textSix = \\lyricmode {{
  \\offsetLeft "{sym(s,6)} {v(s,6,0)} "
  \\offsetRight "{v(s,6,1)} "
}} textSixAndAHalf = \\lyricmode {{
  \\offsetLeft "{v(s,6,2)} "
  \\offsetRight "{v(s,6,3)} "
}} textSeven=  \\lyricmode {{
  \\offsetLeft "{sym(s,7)} {v(s,7,0)} "
  \\offsetRight "{v(s,7,1)} "
  \\offsetLeft "{v(s,7,2)} "
  \\offsetRight "{v(s,7,3)} "
}}

% RE-VAMP
textHeight =  \\lyricmode {{
  \\offsetLeft "{sym(s,8)} {v(s,8,0)} "
  \\offsetRight "{v(s,8,1)} " " "
}} textHeightndAHalf = \\lyricmode {{
  \\offsetLeft "{v(s,8,2)} "
  \\offsetRight "{v(s,8,3)} " " "
}} textNine = \\lyricmode {{
  \\offsetLeft "{sym(s,9)} {v(s,9,0)} "
  \\offsetRight "{v(s,9,1)} " " "
}} textNineAndAHalf = \\lyricmode {{
  \\offsetLeft "{v(s,9,2)} "
  \\offsetRight "{v(s,9,3)} " " "
}}
"""


def render_continuation(by_number, order):
    # One top-level \markup block per quatrain (with a section header
    # prefixed onto the first quatrain of each group), so LilyPond's page
    # breaker can pack them tightly instead of only being able to place or
    # reject a whole section group at once, which left large gaps whenever
    # a group didn't quite fit what was left of a page.
    #
    # Within each quatrain, the 4 lines are laid out as two rows of two
    # columns (line 1 left / line 2 right, then line 3 left / line 4
    # right), echoing how the sung quatrains 1-9 split across two bars
    # per system in bateau_lyrics.ily.
    blocks = []
    for section_name, numbers in order:
        if not numbers or numbers[0] < 10:
            continue
        for i, n in enumerate(numbers):
            vers = by_number[n]["vers"]
            first = f"{sym(by_number, n)} {vers[0]}"
            # Performers alternate verse by verse, not quatrain by
            # quatrain; with 4 lines per quatrain that always lands odd
            # verses (vers[0], vers[2]) in the left column and even
            # verses (vers[1], vers[3]) in the right column.
            rows = "\n".join(
                f'    \\fill-line {{\n'
                f'      \\line {{ \\with-color #oddVoiceColor "{first if row == 0 else vers[row]}" }}\n'
                f'      \\line {{ \\with-color #evenVoiceColor "{vers[row + 1]}" }}\n'
                f'    }}'
                for row in (0, 2)
            )
            header = (
                f'  \\sectionLineMarkup "{section_name}"\n  \\vspace #0.5\n'
                if i == 0
                else "  \\vspace #0.5\n"
            )
            # Same font/size as the sung lyrics (LyricText.font-name/font-size
            # in bateau.3.ly), so the plain-verse continuation reads as a
            # continuation of the same text, not a different typeface.
            blocks.append(
                f"\\markup \\column {{\n{header}"
                f'  \\override #\'(font-name . "URW Bookman, URW Bookman L") \\fontsize #0.5\n'
                f"  \\column {{\n{rows}\n  }}\n}}"
            )
    return "\n\n".join(blocks) + "\n"


def main():
    by_number, order = load_strophes()
    header = "% Generated by generate_lyrics.py from bateau_ivre.yaml -- do not edit by hand.\n\n"
    LYRICS_OUT_PATH.write_text(header + render_sung_lyrics(by_number), encoding="utf-8")
    print(f"wrote {LYRICS_OUT_PATH}")
    POEM_OUT_PATH.write_text(header + render_continuation(by_number, order), encoding="utf-8")
    print(f"wrote {POEM_OUT_PATH}")


if __name__ == "__main__":
    main()
