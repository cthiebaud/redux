# bateau

Score, lyrics, and build pipeline for "Le Bateau Ivre".

## Layout

- `bateau.3.ly`, `bateau.3.html` — the LilyPond score and its web viewer. Source.
- `bateau_ivre.yaml` — the poem's words. Source.
- `fret_diagram_chords.yaml` — chord definitions for the fret diagrams. Source.
- `scripts/` — the build scripts (see below).
- `build/` — generated intermediates, read back by `bateau.3.ly` at compile
  time. Gitignored; regenerated on demand.
- `dist/` — final outputs: `bateau.3.web.svg` (fetched by `bateau.3.html`),
  `bateau.3.pdf`, `bateau.3.midi`, `bateau.3-1.midi`. Committed to git, since
  this site deploys straight from the `main` branch with no build step.
- `fonts/`, `og-image.jpg` — static assets.
- `*-paroles*.md` — lyrics sheets, not part of the build.
- `LogicPro/`, `Suno/` — Logic Pro projects and raw Suno generations. Fully gitignored.
- `video/` — self-contained video pipeline (`generate_video.py`,
  `video_timeline.yaml`, background images). Mirrors the same split:
  `video/build/` (pre-rendered intermediates) and `video/dist/` (the final
  `bateau_video_draft.mp4`) are gitignored, as is `video/cache/` (the
  source audio, fetched rather than committed -- see `video/README.md`).
  Everything else in `video/` is a tracked source.

## Building

Requires LilyPond and `pip install invoke pyyaml`.

```
invoke          # build everything (lyrics, chord offsets, web svg, pdf/midi)
invoke --list   # show individual tasks
invoke clean    # remove build/ and dist/
```

Each task skips itself if its output is already newer than its sources.
Run `invoke clean build` to force a full rebuild.

## Pipeline

```
bateau_ivre.yaml ----------> lyrics  -> build/bateau_lyrics.ily
                                      -> build/bateau_poem_continuation.ily
fret_diagram_chords.yaml --> offsets -> build/fret_diagram_offsets.scm

bateau.3.ly + the above -----> websvg -> dist/bateau.3.web.svg
                            -> score  -> dist/bateau.3.pdf / .midi / -1.midi
```

`websvg` and `score` both read `bateau.3.ly`, which in turn includes the two
generated `.ily` files and `fret_diagram_offsets.scm` from `build/`.
