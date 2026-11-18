#!/usr/bin/env python3
"""Measure the exact rendered width of each fret-diagram's associated
chord name, by actually rendering it through LilyPond (the only way to
get a byte-accurate width -- there's no font-metric shortcut that
would match LilyPond's own chord-naming/layout engine) and reading the
glyphs' exact bounding boxes back out of the PDF via pdftotext -bbox,
then write the result to fret_diagram_offsets.scm for bateau.3.ly to
read at compile time.

fret-diag (in bateau.3.ly) reads that file if present and uses the
exact offset for any chord listed there, falling back to its own
plain-text-width estimate for anything missing -- so this script is
optional tooling, not a build dependency: the score always compiles
fine without it, just with the heuristic.

Requires poppler's pdftotext (same tool already used elsewhere in this
project's workflow for PDF inspection).

Run after editing fret_diagram_chords.yaml (a chord moved, a new one
was added, chExceptionMusic changed, etc.):
    python3 measure_chord_widths.py
"""

import pathlib
import re
import shutil
import subprocess
import sys
import tempfile
import yaml

HERE = pathlib.Path(__file__).parent
CHORDS_YAML = HERE / "fret_diagram_chords.yaml"
OFFSETS_OUT = HERE / "fret_diagram_offsets.scm"

# Must mirror bateau.3.ly: same staff size and fonts (both affect
# glyph metrics) and the same chordNameExceptions (changes which
# glyphs print for some chords, e.g. the Ab7(9,#11) case -- see
# chExceptionMusic there). ChordName.font-size is hardcoded to 1.5
# below, matched to \sectionLabel's SectionLabel grob default used
# elsewhere in bateau.3.ly.
GLOBAL_STAFF_SIZE = 16
STAFF_SPACE_PT = GLOBAL_STAFF_SIZE / 4.0  # LilyPond: staff-space = staff-size / 4

# Mirrors fret-diag's own fallback formula (10 + name-width) so a
# measured and an estimated offset land the same way relative to the
# chord name either way.
BASE_PUSH = 10

LY_HEADER = r'''
\version "2.26.0"
#(set-global-staff-size %d)

\paper {
  property-defaults.fonts.serif      = "Nimbus Sans"
  property-defaults.fonts.sans       = "Nimbus Sans"
  property-defaults.fonts.typewriter = "Nimbus Mono PS"
  indent = 0
  ragged-right = ##t
}

\header {
  tagline = ##f
}

chExceptionMusic = {
  <aes c' ees' ges' bes' d''>1-\markup { \super \concat { "7 9 " \sharp "11" } }
}
chExceptions = #(append
  (sequential-music-to-chord-exceptions chExceptionMusic #t)
  ignatzekExceptions)
''' % GLOBAL_STAFF_SIZE

BOOK_TEMPLATE = r'''
\book {
  \score {
    \new ChordNames {
      \override ChordName.font-size = #1.5
      \chordmode { __CHORD__ }
    }
    \layout {
      indent = 0
      \context { \Score \omit BarLine }
    }
  }
}
'''


def load_chords():
    data = yaml.safe_load(CHORDS_YAML.read_text(encoding="utf-8"))
    # dict preserves insertion order (Python 3.7+ / PyYAML) -- relied
    # on below to match rendered pages back to keys.
    return list(data.items())


def pdf_path_for_index(base, i):
    # LilyPond names the first \book's output "<base>.pdf" and every
    # book after that "<base>-N.pdf" starting at N=1 for the second
    # book (confirmed empirically, not documented behavior to rely on
    # blindly -- main() double-checks file counts before trusting this).
    return base.with_name(f"{base.name}.pdf") if i == 0 else base.with_name(f"{base.name}-{i}.pdf")


def render(chords, tmp):
    ly_path = tmp / "measure.ly"
    books = "\n".join(BOOK_TEMPLATE.replace("__CHORD__", chord) for _key, chord in chords)
    ly_path.write_text(LY_HEADER + books, encoding="utf-8")

    base = tmp / "measure"
    result = subprocess.run(
        ["lilypond", "-dno-point-and-click", "-o", str(base), str(ly_path)],
        capture_output=True, text=True,
    )
    if result.returncode != 0:
        sys.stderr.write(result.stdout)
        sys.stderr.write(result.stderr)
        raise SystemExit("lilypond failed -- see output above")

    pdfs = sorted(tmp.glob("measure*.pdf"))
    if len(pdfs) != len(chords):
        raise SystemExit(
            f"expected {len(chords)} PDFs (one per chord), found {len(pdfs)}: {pdfs}"
        )
    return [pdf_path_for_index(base, i) for i in range(len(chords))]


WORD_BBOX_RE = re.compile(
    r'<word xMin="([-\d.]+)" yMin="[-\d.]+" xMax="([-\d.]+)" yMax="[-\d.]+"'
)


def measure_pdf_width(pdf_path):
    result = subprocess.run(
        ["pdftotext", "-bbox", str(pdf_path), "-"],
        capture_output=True, text=True, check=True,
    )
    # Parsed with a regex, not an XML parser: some chord glyphs (e.g.
    # the flat sign) come back from pdftotext as a word with an
    # unmapped/control-character byte as its text content, which isn't
    # valid XML and breaks a real parser -- but the xMin/xMax
    # attributes themselves are still well-formed, and that's all that
    # is needed here.
    boxes = WORD_BBOX_RE.findall(result.stdout)
    if not boxes:
        raise SystemExit(f"no glyphs found in {pdf_path} -- empty chord render?")
    x_min = min(float(x1) for x1, _x2 in boxes)
    x_max = max(float(x2) for _x1, x2 in boxes)
    width_pt = x_max - x_min
    return width_pt / STAFF_SPACE_PT


def main():
    chords = load_chords()
    print(f"Measuring {len(chords)} chords via LilyPond...")
    with tempfile.TemporaryDirectory() as tmp:
        tmp = pathlib.Path(tmp)
        pdf_paths = render(chords, tmp)

        lines = ["; Generated by measure_chord_widths.py -- do not edit by hand.",
                 "; Re-run it after editing fret_diagram_chords.yaml.",
                 "("]
        for (key, chord), pdf_path in zip(chords, pdf_paths):
            width = measure_pdf_width(pdf_path)
            push = BASE_PUSH + width
            lines.append(f'  ("{key}" . {push:.4f})')
            print(f"  {key:30s} {chord:20s} width={width:.3f}  push={push:.3f}")
        lines.append(")")

    OFFSETS_OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"wrote {OFFSETS_OUT}")


if __name__ == "__main__":
    main()
