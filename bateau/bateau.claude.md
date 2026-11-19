# bateau.3.ly — implementation notes

Detailed rationale for non-obvious decisions, kept out of the score file
so its own comments stay short. Read the relevant section here before
touching the referenced code.

## fonts

`bateau.3.ly`'s `\paper` block sets `property-defaults.fonts.serif/sans`
to "Nimbus Sans" and the lyrics override `LyricText.font-name` to
"URW Bookman, URW Bookman L". The PDF backend embeds the actual glyph
outlines for whatever font LilyPond resolves those names to (confirmed
via `pdffonts bateau.3.pdf`: NimbusSans-{Regular,Bold,Italic} and
URWBookman-Light, all `emb=yes`), so it renders identically everywhere.

The web SVG backend does not embed fonts — it emits plain
`<text font-family="Nimbus Sans">` / `font-family="URW Bookman,URW Bookman L">`
elements and relies on the viewer's browser having a matching font
installed under that literal name, which essentially never happens
("Nimbus Sans" without "L" isn't a common system font). Without help,
the browser silently substitutes its own fallback, so the web version
looked visibly different from the PDF.

Fixed by embedding the exact same font files as `@font-face` webfonts in
`bateau.3.html`'s `<head>`, loaded from `bateau/fonts/*.woff2`:
- `NimbusSans-{Regular,Bold,Italic}.woff2` — copied from LilyPond's own
  bundled copy (`<lilypond-install>/share/lilypond/<version>/fonts/otf/`,
  found via `fc-match "Nimbus Sans"` tracing to the font LilyPond
  actually renders with — NOT the system's "Nimbus Sans L", which
  fontconfig resolves to something else entirely).
- `URWBookman-Light.woff2` — LilyPond doesn't bundle this one; copied
  from the system font file fontconfig resolves "URW Bookman" to
  (`fc-match "URW Bookman"`).

Converted from the source `.otf` to `.woff2` via
`fonttools ttLib.woff2 compress` (needs the `brotli` Python package).
Since the SVG is injected inline into the HTML document (`innerHTML`,
not an `<object>`/`<iframe>`), `@font-face` rules declared in the page
apply directly to its `<text>` elements — no change to
`build-web-svg.sh` or the SVG generation itself was needed.

If `bateau.3.ly`'s fonts ever change, regenerate the matching `.woff2`
files the same way and update the `@font-face` `src` paths/weights in
`bateau.3.html`.

## web-svg

`build-web-svg.sh` generates a wrapper `.ly` that `\includes` `bateau.3.ly`
after defining `web-svg` and `web-svg-height`, then compiles with
`-dbackend=svg`. This skips the manual page breaks and gives the page a
fixed, deliberately oversized height (2000mm, comfortably more than the
piece's own ~730mm) so everything, footer included, fits on one
continuous page. That leaves real blank space below the content;
cropping it away happens client-side in `bateau.3.html`, which measures
the loaded SVG with `getBBox()` and trims the `viewBox` to fit.

Two `\paper` settings only matter for this build:
- `ragged-bottom`/`ragged-last`: ragged, not justify-to-fill — otherwise
  the oversized single page would stretch system spacing throughout to
  fill all 2000mm instead of sitting at its natural height.
- `last-bottom-spacing` stretchability 0: otherwise this spring (last
  system → footer, independent of `ragged-bottom`) stretches to fill
  the oversized page, pushing the footer almost all the way down.

## sectionLineMarkup

The one place that controls how a section header (Intro/Vamp/Sequence/
Climax/Outro/etc.) looks, for both the sung score (via `\sectionLine`)
and the generated poem continuation, which calls this markup command by
name directly in `bateau_lyrics.ily` — so changing the look here never
requires touching `generate_lyrics.py` or regenerating anything.

The `\override #'(font-size . 1.5)` (not `\fontsize`, which is additive)
matters because in the score, `\sectionLabel`'s `SectionLabel` grob
already renders this markup at font-size 1.5 (LilyPond's own default,
`scm/lily/define-grobs.scm`); called as plain markup from the poem
continuation there's no grob setting that, so it would otherwise fall
back to the ambient size. `\override` sets the same absolute 1.5 both
ways instead of doubling up in the score.

## offsetLeft / offsetRight

Used for the sung-lyrics / poem-continuation split layout. Both align
flush against the same page margins (x=0 .. line-width) as the
`\fill-line` columns used for the poem continuation, so both halves
share identical left/right edges. Each also colors its line by
performer: the poem alternates performers verse by verse (not quatrain
by quatrain), and since every quatrain has an even number of lines (4),
that alternation always lands odd verses in the left column and even
verses in the right — so the color is hardcoded per column instead of
threaded through as a parameter.

`offsetRight`'s target is a fixed constant (`128.0374`), not a live
lookup of the system's own extent, because querying a grob's containing
system from within that same grob's `after-line-breaking` callback is
self-referential: the system's extent isn't settled yet, and the
resulting translation can blow up and wreck the whole page's spacing.

## chordNameBelow

Placement uses only stock grob/context properties, each a flat,
self-contained adjustment (no cross-grob lookups, nothing that forces
another grob's layout to resolve early):
- `alignBelowContext` (set in the `\with` block at context creation,
  "mainCN") moves the row below the staff instead of above it.
- `nonstaff-relatedstaff-spacing`: the *real* gap the layout solver
  reserves between the row and the staff, shrunk to a small fixed
  constant. This is what makes anything after the chord name (the
  lyrics) shift up and follow — unlike `extra-offset` below, which is a
  late, purely cosmetic nudge the solver never sees. Safe on its own: a
  past bug came from fixing this *and* pushing past it with a large
  `extra-offset` at the same time; a small fixed gap with nothing
  contradicting it is the configuration verified rock-solid across
  systems.
- `X-offset`: a constant rightward nudge.
- `extra-offset`'s Y part: a small fixed lift (1.5) on top of the
  already-shrunk gap above. It is NOT scaled by the chord's own height
  despite computing one (`height`, unused — a leftover from an earlier,
  abandoned attempt at that) — a tall chord like "E7b5b9sus4" and a
  plain one like "D7" get the same lift. What actually keeps every
  chord the same distance from the staff regardless of its own height
  is unrelated to this function: it's `fret-diag`'s own width-based
  `\hspace` push, which stops the fret diagram and chord name from
  colliding in the first place. That collision — not asymmetric
  `chordNameBelow` lift — was the real cause of the original uneven
  spacing bug.

## fret-diagram offsets

Fret diagrams (guitar chord boxes). The Vamp and Sequence ones were
imported from the earlier `bateau.0.ly` draft, whose bass line and chord
symbols map bar-for-bar onto those two sections; Climax's were added
later by hand to match (`bateau.0.ly` has no Climax at all), and the
Outro still has none. Each diagram's vertical position is fixed (the
`\translate` in `fret-diag`); its horizontal position is computed per
chord.

The push-right needs to scale with how wide the associated chord name
reads — a fixed amount for every chord either collides with wide ones or
leaves narrow ones stranded too far right. `fret_diagram_offsets.scm`
(generated by `measure_chord_widths.py`, which actually renders each
chord through LilyPond and reads its exact glyph widths back out of the
PDF) gives a byte-accurate push per key when present. This file is
optional tooling output, not a build dependency: its absence, or a key
missing from it, falls back to estimating from `name`, a plain-text
approximation of the chord — not a byte-identical reproduction of its
glyphs, since stacked alterations/extensions render more compactly than
their flat text form. That means the fallback over-estimates a bit,
which is the safe direction (pushed slightly too far right, never into
a collision).

Pipeline: `fret_diagram_chords.yaml` (key → real `\chordmode` spec) →
`measure_chord_widths.py` → `fret_diagram_offsets.scm` → read back by
`fret-diag` at compile time. Keep the yaml in sync with `bateau.3.ly` by
hand whenever a fret-diagram variable is added, removed, or paired with
a different chord bar, then re-run the script.

## vampRiff

Upper melody line for the 2nd (re-vamp) occurrence only, transcribed
from `vamp_riff.mid`: a 4-bar riff (staccato stabs on D/C, then a longer
descending tag, itself already played twice within these 4 bars) that
covers the first 4 of the 2nd vamp's 6 printed bars — the hardcoded
`| d'1 | d'1 \break | d'1 | d'1` in `basseI`, in the main score block.
The remaining 2 printed bars, on both voices, come from
`\repeat volta 2 \vamp` / the matching `\repeat volta 2 {| d1 | d1 }` in
`basseI`, not from `vampRiff` itself. Written an octave higher than it
should sound, like `introLeadGuitar`, since `pieceMusic`'s outer
`\transpose c' c` shifts everything down an octave at render time.

## fretDiagramOverlay

A silent voice, parallel to `basseI`, that exists only to carry the
second fret-diagram where a bar holds two harmonies (Vamp's 2nd bar,
Sequence's A7sus4/A7 bar) — entirely separate from `basseI` itself so it
can never change that voice's note count, which `\lyricsto "basseI"`
depends on to stay in sync with the sung lyrics. Stops right after the
last diagram it needs to carry; a voice shorter than its simultaneous
siblings is fine, nothing downstream depends on it.

## StaffGroup

`pieceMusic` and `outroMusic` both have `\new StaffGroup` commented out
(no bracket grouping the staves at the system start — confirmed by
rendering: `\set StaffGroup.systemStartDelimiter` is currently a dead
no-op). This is intentional, not leftover debris: kept as a comment
rather than deleted in case it's wanted back later.

## Known loose end

`fret_diagram_chords.yaml`'s `miSeptNeufBemolAddTreize: e:7.9-.13` entry
doesn't match what `sequenceChordNames` actually prints for that bar
(`e:7sus4.5-.9-`). Harmless since that fret-diagram variable is
currently unused, but worth fixing (or removing) if it's ever wired up.
