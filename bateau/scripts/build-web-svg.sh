#!/usr/bin/env bash
# Build a single, continuous-page SVG of bateau.3.ly for the web --
# everything LilyPond would normally paginate across several A4 pages
# (including the copyright, footnote, and LilyPond tagline) on one
# deliberately oversized page. bateau.3.html does the real fitting at
# load time: it finds the footer (always the last two top-level
# groups LilyPond draws), pulls it up to sit right after the real
# content -- closing the gap LilyPond leaves between them, since it
# glues the footer to the bottom margin of whatever height it's given,
# not to where the content ends -- and then crops to the result via
# the browser's own SVG getBBox().
#
# So this script only needs one guardrail: PAGE_HEIGHT_MM must stay
# clear of a LilyPond quirk where, if the page height is too close to
# the real content height, its page-fitting *estimate* (not the real
# layout) badly misjudges how much fits and pathologically splits
# into many small pages instead of one. 2000mm is a wide margin above
# this piece's ~730mm of real content.
#
# Usage: ./scripts/build-web-svg.sh   (run from the bateau/ directory)
set -euo pipefail
cd "$(dirname "$0")/.."

NAME=bateau.3
DIST_DIR=dist
WRAPPER=_web-build-wrapper.ly
PAGE_HEIGHT_MM=2000

cleanup() {
  rm -f "$WRAPPER" "$DIST_DIR/$NAME-web".midi "$DIST_DIR/$NAME-web"-*.midi "$DIST_DIR/$NAME-web"-*.svg
}
trap cleanup EXIT

mkdir -p "$DIST_DIR"

cat > "$WRAPPER" <<EOF
\\version "2.26.0"
#(define web-svg #t)
#(define web-svg-height $PAGE_HEIGHT_MM)
\\include "$NAME.ly"
EOF

lilypond -dbackend=svg -dno-point-and-click -o "$DIST_DIR/$NAME-web" "$WRAPPER" \
  2>&1 | grep -v "^Processing\|^Parsing\|^Interpreting\|^Preprocessing\|^Calculating\|^MIDI output\|unsupported formats"

PAGES=$(ls "$DIST_DIR/$NAME-web"*.svg 2>/dev/null | wc -l | tr -d ' ')
if [ "$PAGES" != "1" ]; then
  echo "Expected 1 page at ${PAGE_HEIGHT_MM}mm but got $PAGES -- raise PAGE_HEIGHT_MM." >&2
  exit 1
fi

mv "$DIST_DIR/$NAME-web.svg" "$DIST_DIR/$NAME.web.svg"
echo "Wrote $DIST_DIR/$NAME.web.svg (uncropped, ${PAGE_HEIGHT_MM}mm tall -- bateau.3.html closes the footer gap and crops at load time)"
