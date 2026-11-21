\version "2.26.0"

#(set-global-staff-size 16)

% Set by build-web-svg.sh to render one continuous page for the web
% instead of paginated PDF. Details: bateau.claude.md "web-svg".
#(define web-svg (if (defined? 'web-svg) web-svg #f))
#(define web-svg-height (if (defined? 'web-svg-height) web-svg-height 2000))
webPageBreak = #(if web-svg #{ #} #{ \pageBreak #})

% The poem alternates between two performers verse by verse (not
% quatrain by quatrain): one speaks the even verses, the other the odd.
#(define oddVoiceColor  (rgb-color 0.0 0.439 0.722)) % Spanish blue
#(define evenVoiceColor (rgb-color 0.133 0.545 0.133)) % Forest Green

\paper {
  paper-height = #(if web-svg (* web-svg-height mm) (* 280 mm))
  top-margin = 1.2\mm
  bottom-margin = 1.8\mm

  property-defaults.fonts.serif      = "Nimbus Sans"      % default text
  property-defaults.fonts.sans       = "Nimbus Sans"
  property-defaults.fonts.typewriter = "Nimbus Mono PS"

  page-breaking = #ly:minimal-breaking
  system-system-spacing.padding = #1.8
  % Ragged for the web build, else system spacing stretches to fill
  % the oversized page. Details: bateau.claude.md "web-svg".
  ragged-bottom = #f % #(if web-svg #t #f)
  ragged-last = #(if web-svg #t #f)
  last-bottom-spacing = #(if web-svg
                           '((basic-distance . 1)
                             (minimum-distance . 0)
                             (padding . 3)
                             (stretchability . 0))
                           '((basic-distance . 1)
                             (minimum-distance . 0)
                             (padding . 3)
                             (stretchability . 30)))
}

\header {
  title = "Le Bateau ivre"
  poet = "Poème d’Arthur Rimbaud"
  composer = "Musique de Christophe Thiebaud"
  copyright = \markup \small {
    \center-column {
      "© 2026 Christophe Thiebaud. Tous droits réservés."
      "Déposé à la SACEM · ISWC T-305.593.089-3"
    }
  }
}

% Shared look for every section header: used by both the sung score
% (via \sectionLine below) and the poem continuation, which calls this
% by name in bateau_lyrics.ily. Details: bateau.claude.md "sectionLineMarkup".
sectionLineMarkup =
#(define-markup-command (sectionLineMarkup layout props text) (markup?)
   (interpret-markup layout props
     #{
       \markup \column {
         \vspace #1
        % \override (not \fontsize, additive) sets the same absolute
        % font-size whether a SectionLabel grob is rendering this or not.
        \override #'(font-size . 1.5)
        #text
       }
     #}))

sectionLine = #(define-music-function (text) (markup?)
  #{ \sectionLabel \markup \sectionLineMarkup #text #})

% Aligns to the same margins as the poem continuation's \fill-line
% columns, and colors by performer (hardcoded per column). Details:
% bateau.claude.md "offsetLeft / offsetRight".
offsetLeft =
#(define-music-function () ()
   #{
     \once \override LyricText.after-line-breaking =
       #(lambda (grob)
          (let* ((sys  (ly:grob-system grob))
                 (left (car (ly:grob-extent grob sys X))))
            (ly:grob-translate-axis! grob (- 0 left) X)))
     \once \override LyricText.color = #oddVoiceColor
   #})

% Fixed constant, not a live lookup of the system's extent -- that
% would be self-referential from inside this same callback.
offsetRight =
#(define-music-function () ()
   #{
     \once \override LyricText.after-line-breaking =
       #(lambda (grob)
          (let* ((sys   (ly:grob-system grob))
                 (right (cdr (ly:grob-extent grob sys X))))
            (ly:grob-translate-axis! grob (- 128.0374 right) X)))
     \once \override LyricText.color = #evenVoiceColor
   #})

% Positions the chord-name row below the staff (alignBelowContext, set
% at context creation) and nudges it with nonstaff-relatedstaff-spacing,
% X-offset and extra-offset. Details: bateau.claude.md "chordNameBelow".
chordNameBelow = #(define-music-function () ()
  #{
     \override ChordNames.VerticalAxisGroup.nonstaff-relatedstaff-spacing =
       #'((basic-distance . 7) (minimum-distance . 7) (padding . 0) (stretchability . 0))
    \override ChordName.X-offset = #4.8
    \override ChordName.after-line-breaking =
      #(lambda (grob)
         (ly:chord-name::after-line-breaking grob)
         (let* ((text   (ly:text-interface::print grob))
                (y-ext  (ly:stencil-extent text Y))
                (height (- (cdr y-ext) (car y-ext)))
                (dy     1.5))
           (ly:grob-set-property! grob 'extra-offset (cons 0 dy))))
  #})

% LilyPond drops the natural 9 from "Ab7(9,#11)" since a higher
% altered step (#11) suppresses it (chord-ignatzek-names.scm) --
% an exception forces it back in.
chExceptionMusic = {
  <aes c' ees' ges' bes' d''>1-\markup { \super \concat { "7 9 " \sharp "11" } }
}
chExceptions = #(append
  (sequential-music-to-chord-exceptions chExceptionMusic #t)
  ignatzekExceptions)

% Fret diagrams (guitar chord boxes). Horizontal push scales with the
% associated chord name's width, so it clears the name regardless of
% how long it is; exact width comes from fret_diagram_offsets.scm
% (generated by measure_chord_widths.py) when available, else a
% plain-text estimate. Details: bateau.claude.md "fret-diagram offsets".
#(define fret-diagram-offsets
   (if (file-exists? "build/fret_diagram_offsets.scm")
       (call-with-input-file "build/fret_diagram_offsets.scm" read)
       '()))

#(define-markup-command
  (fret-diag layout props key name chord)
  (string? markup? markup?) (
    let* ((measured (assoc-ref fret-diagram-offsets key))
          (push
           (or measured
               (+ 10 (interval-length
                      (ly:stencil-extent
                       (interpret-markup layout props
                         (markup #:override '(font-size . 1.5) name))
                       X))))))
      (interpret-markup layout props #{
        \markup {
          \hspace #push
          % Pushed down to clear the chord-name row above (chordNameBelow
          % doesn't know about this markup).
          \translate #(cons 0 -1.5)
          \override #'(fret-diagram-details . ((number-type . roman-lower) (finger-code . in-dot) (barre-type . straight))) {
            \fret-diagram-terse #chord
          }
        }
      #})
  )
)

reSept                      = \markup \fret-diag "reSept" "D7" "o;x;4-2;5-4;3-1;x;"
solSeptReBasse              = \markup \fret-diag "solSeptReBasse" "G7/D" "o;x;3-1;4-4;3-2;x;"
doNeufReBasse               = \markup \fret-diag "doNeufReBasse" "C7/D" "o;x;2-1;3-3;3-4;x;"

solMineurSept               = \markup \fret-diag "solMineurSept" "Gm7" "5-3;x;3-1-(;3-1;3-1-);x;"
doSeptNeufDieze             = \markup \fret-diag "doSeptNeufDieze" "C7#9" "x;3-2;2-1;3-3;4-4;x;"
faQuinteAugm                = \markup \fret-diag "faQuinteAugm" "F7#5" "3-3;x;x;2-1;2-2;o;"
siSeptMaj                   = \markup \fret-diag "siSeptMaj" "Bb7+" "x;1-1;x;2-3;3-4;1-2;"
miMinSeptQuinteDimNeufDieze = \markup \fret-diag "miMinSeptQuinteDimNeufDieze" "Em7b5,9" "2-1;x;x;3-3;3-4;2-2;"
laSeptNeufBemol             = \markup \fret-diag "laSeptNeufBemol" "A7b9" "x;o;x;3-2;2-3;3-4;"
laBemolSeptQuinteDim        = \markup \fret-diag "laBemolSeptQuinteDim" "Ab7b5" "6-3;x;o;5-2;7-4;4-1;"
solSept                     = \markup \fret-diag "solSept" "G9" "5-2;x;o;4-1;6-4;5-3;"

solMinNeuf                  = \markup \fret-diag "solMinNeuf" "Gm9" "5-2;x;o;3-1;6-4;5-3;"
doSeptNeufDiezeQuinteAugm   = \markup \fret-diag "doSeptNeufDiezeQuinteAugm" "C7#9b13" "x;3-2;2-1;3-3;4-4-(;4-4-);"
faQuinteAugmBis             = \markup \fret-diag "faQuinteAugmBis" "F7#5,9" "3-2;x;2-1-(;2-1;2-1-);3-3;"
siSeptMajQuinteAugm         = \markup \fret-diag "siSeptMajQuinteAugm" "Bb7#5" "x;1-1;x;2-2;3-4;2-3;"
miMinSeptQuinteDimNeufBemol = \markup \fret-diag "miMinSeptQuinteDimNeufBemol" "Em7b5b9" "2-3;1-2;o;o;3-4;1-1;"
miSeptSusQuatreQuinteDimNeufBemol = \markup \fret-diag "miSeptSusQuatreQuinteDimNeufBemol" "E7sus4b5b9" "x;7-3;7-4;3-1;3-1;x;"
miSeptNeufBemolAddTreize    = \markup \fret-diag "miSeptNeufBemolAddTreize" "E7b9add13" "2-2;x;o;1-1;2-3;1-1;"
laSeptSusQuatre             = \markup \fret-diag "laSeptSusQuatre" "A7sus4" "x;o;5-3;x;3-1;o;"
laSept                      = \markup \fret-diag "laSept" "A7" "x;o;5-3;6-4;3-1;o;"
laBemolNeufOnze             = \markup \fret-diag "laBemolNeufOnze" "Ab7,9,#11" "6-4;3-1-(;4-2;3-1;3-1-);x;"
solNeuf                     = \markup \fret-diag "solNeuf" "G9" "5-4;2-1-(;3-2;2-1-);3-3;x;"
doSusQuatreNeufReBasse      = \markup \fret-diag "doSusQuatreNeufReBasse" "C9sus4" "x;3-1-(;3-1;3-1;3-1-);x;"

reMajeur                    = \markup \fret-diag "reMajeur" "D" "o;5-1;4-3;2-1;3-2;x;"
siBemolFaBasse              = \markup \fret-diag "siBemolFaBasse" "Bb/F" "3-1;x;3-2;3-1;3-2;x;"
siMineur                    = \markup \fret-diag "siMineur" "Bm" "x;2-1;4-3;4-3;3-2;x;"
laMajeur                    = \markup \fret-diag "laMajeur" "A" "x;o;2-3;2-3;2-4;o;"
reMajeurDeux                = \markup \fret-diag "reMajeurDeux" "D" "o;o;o;2-1;3-3;2-2;"

% Lyrics for quatrains 1-9 (sung) and the plain-verse continuation for
% quatrains 10-25 are generated from bateau_ivre.yaml -- see
% generate_lyrics.py. Re-run it after editing the yaml, before compiling.
\include "build/bateau_lyrics.ily"

%%%%%%%%%%%%%%%%%%%%%%%

% intro

introBasse = {
  \voiceTwo
  | d'4. d'8~d'2
  \noBreak
  | g4.  c'8~c'2
  \noBreak
  | d'4. d'8~d'2
  \noBreak
  | g4.  c'8~c'2
}

intro = {
  \voiceOne
  | <fis' c'' d''>4. <fis' c'' d''>8~<fis' c'' d''>2
  | <f'   b'  d''>4. <f'   bes' d''>8~<f'   bes' d''>2
  | <fis' c'' d''>4. <fis' c'' d''>8~<fis' c'' d''>2
  | <f'   b'  d''>4. <f'   bes' d''>8~<f'   bes' d''>2
}

introLeadGuitar = {
  \voiceOne
  | f''8. d''16~ d''2 g''16 f''16 g''16 a''16
  | f''8. d''16~ d''2.
  | f''8. d''16~ d''2 g''16 f''16 g''16 a''16
  | \acciaccatura f''8 g''8 f''16 d''16~ d''4 r16 a'16 d''16 a''16 g''16 f''16 d''16 c''16
}

% bottleneck guitar, echoing the lead with portamento
introEcho = {
  | r4. f''8.\glissando d''4..
  | r4. f''8.\glissando d''4..
  | r4. f''8.\glissando d''4..
  | r1
}

introChordNames = \chordmode {
  | d1:7
  | g4.:7  c4.:9sus4 s4
  | d1:7
  | g4.:7  c4.:9sus4 s4
}

% vamp

vampBasse = {
  \voiceTwo
  | d1_\reSept
  | d1
}

vamp = {
  \voiceOne
  | <fis' c'' d''>1
  | <f'   b' d''~>2 <e' bes' d''>2
}

% Reused for both the x2 and x4 Vamp -- same chords as vampBasse/vamp.
vampChordNames = \chordmode {
  | d1:7
  | g2:7/d  c:7/d
}

% Upper melody for the 2nd Vamp only (transcribed from vamp_riff.mid),
% covering its first 4 of 6 printed bars -- the rest come from
% \repeat volta 2 \vamp. Written an octave high, like introLeadGuitar,
% for pieceMusic's outer \transpose. Details: bateau.claude.md "vampRiff".
vampRiff = {
  r4 c''8-. [d'16 c''16-.~] c''16 d'16 c''8-. c''16 (d''16) d''8 |
  r4 c''8-. [d'16 c''16-.~] c''16 b'16 a'8 g'16 \acciaccatura f'16 fis'16 d'8 |
  r4 c''8-. [d'16 c''16-.~] c''16 d'16 c''8-. c''16 (d''16) d''8 |
  r16 f''8.  d''16 c''16 a'16 gis'16 g'16 f'16 d'16 c'16 a16 f8.
}

% sequence

sequence = {
  \voiceOne
  | <f'    bes'  d''            >1 ( 
  | <e'    bes'  dis''          >  )(
  | <a'    cis'' e''            >  )(
  | <a'    d''   f''            >  )(
  | <bes'  d''   fis''          >  )(
  | <bes'  cis'' g''            >  )(
  | <ges'  c''   eeses'' aes''  >  )(
  | <f'    b'    d''      a''   >  )
  % 
  | <d'    bes'  f''      a''   >1 ( 
  | <e'    bes'  dis''    aes'' >  )(
  | <e'    a'    cis''    g''   >  )(
  | <      a'    d''      fis'' >  )(
  | <e' a' bes'  d''      f''   >  )(  
  | <<
    {
      \voiceOne
      e''2.. )( d''8 )(
    }
    \new Voice {
      \voiceThree
      d''2_( cis'')
    }
    \new Voice {
      \voiceTwo
      <g' a'>1
    }
  >>
  | <c' ges' bes' d'' >1 )(
  | <b  f'   a'   d'' >2 )( <f' bes' d'' >2 )
}

% sequence

sequenceBasse = {
  \voiceTwo
  | g1_\solMineurSept
  | c'1_\doSeptNeufDieze
  \break
  | f1_\faQuinteAugm
  | bes1_\siSeptMaj
  \break
  | e1_\miMinSeptQuinteDimNeufDieze
  | a1_\laSeptNeufBemol
  \break
  | as1_\laBemolSeptQuinteDim
  | g1_\solSept
  \break
  | << \tag #'score { g1_\solMinNeuf } \tag #'midi { g'1 } >>
  | c'1_\doSeptNeufDiezeQuinteAugm
  \break
  | << \tag #'score { f1_\faQuinteAugmBis } \tag #'midi { f'1 } >>
  | bes1_\siSeptMajQuinteAugm
  \break
  | << \tag #'score { e1_\miSeptSusQuatreQuinteDimNeufBemol } \tag #'midi { e'1 } >>
  | a1
  \break
  | as1_\laBemolNeufOnze
  | g2_\solNeuf   c'2_\doSusQuatreNeufReBasse
}

% Silent voice, separate from basseI, carrying the second fret-diagram
% where a bar holds two harmonies -- kept separate so it can't disturb
% basseI's note count, which \lyricsto depends on. Details:
% bateau.claude.md "fretDiagramOverlay".
fretDiagramOverlay = {
  \partial 2
  s2
  s1 s1 s1 s1
  \repeat volta 2 { s1 | s2_\solSeptReBasse s2_\doNeufReBasse }
  s1 s1 s1 s1 s1 s1 s1 s1 s1 s1 s1 s1 s1
  s2_\laSeptSusQuatre s2_\laSept
}

sequenceChordNames = \chordmode {
  | g1:m7
  | c:7.9+
  | f:7+.5+
  | bes:7+
  | e:m7.5-.9
  | a:7.9-
  | aes:7.5-
  | g:7.9

  | g:m7.9
  | c:7.9+.13-
  | f:7+.5+.9
  | bes:7+.5+
  | e:7sus4.5-.9-
  | a2:7sus4     a:7
  | aes1:7.9.11+
  | g2:9         c:9sus4
}

% climax

climaxBasse = {
  \voiceTwo
  \bar ".|:"
  \repeat volta 2 {
    | d1_\reMajeur
    | f1_\siBemolFaBasse
  }
  \set Score.currentBarNumber = #29
  \break
  | b1_\siMineur
  | a1_\laMajeur
  \break
  | d1_\reMajeurDeux
  | d1
}

climaxChordNames = \chordmode {
  \repeat volta 2 {
    | d1
    | bes/f
  }
  | b:m
  | a
  | d
  | s
}

climax = {
  \voiceOne
  \repeat volta 2 {
    | <d' fis' a'   d''>1
    | <d' f'   bes' d''>
  }
  | <fis' b'    d''   >
  | <a'   cis'' e''   >
  | <a'   d''   fis'' >
  | <a'   d''   fis'' >
}

% outro

outroBasse = {
  \voiceTwo
  | d2 d2
  \noBreak
  | d2 d2
  \noBreak
  | d2 d4. d8~
  \noBreak
  | d1
}

outro = {
  \voiceOne
  | <gis d'>2 <gis d'>
  | <gis d'>  <gis d'>
  | <gis d'>  <gis d'>4. <gis d'>8~
  | <gis d'>1
}

outroLeadGuitar = {
  \voiceOne
  | d'2. g'16 f'16 g'16 a'16
  | f'8. d'16~ d'2 fis'16 f'16 c'8
  | d'2.. d'8~
  | d'1
}

outroEcho = {
  | r4 c'8.\glissando d'16~d'2
  | r4 c'8.\glissando d'16~d'2
  | r4 c'8.\glissando d'16~d'4. d'8~
  | d'1
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\markup {
  \vspace #1
}

pieceMusic = \transpose c' c {
  % \new StaffGroup 
  { <<
    \set StaffGroup.systemStartDelimiter = #'SystemStartSquare
    \new Staff = "introMelody" \with {
      \RemoveEmptyStaves
      \consists "Timing_translator"
      instrumentName = "Guitare solo"
    } {
      \clef "treble_8"
      \key g \major
      \partial 2
      r8 d'''16 a''16 g''16 f''16 d''8
      \introLeadGuitar
      \bar "|"
      d''2
    }
    \new Staff = "introEcho" \with {
      \consists "Timing_translator"
      instrumentName = "Guitare bottleneck"
    } {
      \set Staff.midiInstrument = "vibraphone"
      \clef "treble_8"
      \key g \major
      \partial 2
      r2
      \introEcho
      \bar "|"
      r2
    }
    \new Staff = "main" \with {
      instrumentName = \markup \concat { "Guitare" \super "[1]" " et Basse" }
    } {

    \set Staff.midiInstrument = "acoustic guitar (nylon)"
    \set Voice.midiInstrument = "acoustic guitar (nylon)"

    % { part I
    <<
      \new ChordNames = "introCN" \with {
        alignAboveContext = "main"
      } {
        \partial 2
        s2
        \introChordNames
      }
      \new ChordNames = "mainCN" \with {
        alignBelowContext = "main"
      } {
        \chordNameBelow
        \partial 2
        s2
        s1 s1 s1 s1
        \repeat volta 2 \vampChordNames
        \sequenceChordNames
        \climaxChordNames
        \chordmode { d1:7 s1 s1 s1 }
        \repeat volta 2 \vampChordNames
      }
      {
      \new Voice = "basseI" {
        \set midiInstrument = "acoustic bass"
        \set Voice.instrumentTransposition = c
        \key g \major

        \section
        \footnote \markup \null #'(0 . 0) \markup \abs-fontsize #9
          \override #'(word-space . 0.3) \wordwrap {
          "[1]" "6ème" "corde" "accordée" "en" "ré" "(drop" "D)."
        } \sectionLine "Intro"
        \partial 2
        r2
        \noBreak
        \voiceTwo
        \introBasse

        \bar ".|:"
        \section \sectionLine "Vamp"
        \repeat volta 2 \vampBasse
        \set Score.currentBarNumber = #9
        \break

        \key d \minor
        \section \sectionLine "Sequence"
        \sequenceBasse
        \set Score.currentBarNumber = #25
        \once \overrideProperty Score.NonMusicalPaperColumn.line-break-system-details
          #'((extra-offset . (0 . 1)))
        \break

        \key d \major
        \section
        \footnote \markup \null #'(0 . 0) \markup \abs-fontsize #9
          \override #'(word-space . 0.3) \wordwrap {
          "[2]" "La" "section" "Climax" "cite" "les" "accords" "de" "conclusion" "de" "Richard" "Strauss,"
          \italic "Vier letzte Lieder,"
          "n°" "4," "«" "Im" "Abendrot" "»" "(tonalité" "originale" ":" "mi" "bémol" "majeur" ";" "transposée" "en" "ré)."
        } \sectionLine \markup \concat { "Climax" \super "[2]" }
        \climaxBasse
        \once \overrideProperty Score.NonMusicalPaperColumn.line-break-system-details
          #'((extra-offset . (0 . 1)))
        \break

        \key g \major
        \section \sectionLine "Vamp"
        | d'1 | d'1
        \break
        | d'1 | d'1
        \break
        \repeat volta 2 {| d1 | d1 }
      }
      }
      \new Voice = "accordsI" {
        \set midiInstrument = "acoustic guitar (nylon)"

        \partial 2
        s2
        \voiceOne
        \intro

        \repeat volta 2 \vamp
        \sequence
        \climax
        \vampRiff
        \repeat volta 2 \vamp
      }
      \new Voice = "fretExtraI" { \voiceFour \fretDiagramOverlay }
      \new Lyrics \lyricsto "basseI" {
        \skip 1 \skip 1 \skip 1 \skip 1 \skip 1 \skip 1 \skip 1 \skip 1
        <<
          \textOne
          \new Lyrics = "oneAndAHalf" {
            \set associatedVoice = "basseI"
            \textOneAndAHalf
          }
        >>
        \textTwoThreeFourFive
        <<
          \textSix
          \new Lyrics = "sixAndAHalf" {
            \set associatedVoice = "basseI"
            \textSixAndAHalf
          }
        >>
        \textSeven
        \textHeight
        <<
          \new Lyrics = "nine" {
            \set associatedVoice = "basseI"
            \textNine
          }
          \new Lyrics = "nineAndAHalf" {
            \set associatedVoice = "basseI"
            \textNineAndAHalf
          }
        >>
      }
    >>
    % end of part I

    }
  >> }
}

\score {
  \keepWithTag #'score \pieceMusic

  \layout {
    \clef "treble_8"
    \time 4/4
    indent = #18
    short-indent = #0
    \override LyricText.self-alignment-X = #LEFT
    \accidentalStyle modern-voice-cautionary
    \context {
      \Score
      \override RehearsalMark.self-alignment-X = #LEFT
      \override SectionLabel.padding = #2
    }
    \context {
      \Lyrics
      \override LyricText.font-name = "URW Bookman, URW Bookman L"
      \override LyricText.font-size = #0.5
    }
    \context {
      \ChordNames
      chordNameExceptions = #chExceptions
    }
  }
}

% Kept right after the body's \layout score (and before the Outro's own
% \score below) so this -- the main piece -- claims the unsuffixed
% "bateau.3.midi" name; the Outro's MIDI then becomes "bateau.3-1.midi".
\score {
  \unfoldRepeats \keepWithTag #'midi \pieceMusic

  \midi {
    \tempo 4 = 70
    \context {
      \Staff
      \remove "Staff_performer"
    }
    \context {
      \Voice
      \consists "Staff_performer"
    }
    \context {
      \ChordNames
      \remove "Note_performer"
    }
  }
}

\include "build/bateau_poem_continuation.ily"

\markup {
  \vspace #2
}

% Independent piece, own timing from bar 1. \new StaffGroup is
% deliberately commented out (kept for possible reuse) -- same in
% pieceMusic. Details: bateau.claude.md "StaffGroup".
outroMusic = {
  % \new StaffGroup
  { <<
    \set StaffGroup.systemStartDelimiter = #'SystemStartSquare
    \new Staff = "outroMelody" \with {
      \RemoveEmptyStaves
      instrumentName = "Guitare solo"
    } {
      \set Score.currentBarNumber =#104
      \clef "treble_8"
      \key g \major
      \partial 2
      r16 a16 d'16 a'16 g'16 f'16 d'16 c'16
      \outroLeadGuitar
      \bar "|."
    }
    \new Staff = "outroEcho" \with {
      \RemoveEmptyStaves
      instrumentName = "Guitare bottleneck"
    } {
      \set Staff.midiInstrument = "vibraphone"
      \clef "treble_8"
      \key g \major
      \partial 2
      r2
      \outroEcho
      \bar "|."
    }
    \new Staff = "outroMain" \with {
      instrumentName = "Guitare et Basse"
    } {
      \set Staff.midiInstrument = "acoustic guitar (nylon)"
      <<
        \new ChordNames \with {
          alignAboveContext = "outroMain"
        } {
          \chordmode {
            \partial 2
            s2
            d1:sus4+ s1 s1 s1
          }
        }
        \new Voice = "outroBasseVoice" {
          \key g \major
          \section \sectionLine "Outro"
          \partial 2
          r2
          \noBreak
          \voiceTwo
          \outroBasse
        }
        \new Voice = "outroAccordsVoice" {
          \partial 2
          s2
          \voiceOne
          \outro
        }
      >>
    }
  >>
  }
}

\score {
  \outroMusic

  \layout {
    \clef "treble_8"
    \time 4/4
    indent = #18
    short-indent = #0
    \context {
      \Score
      barNumberVisibility = #all-bar-numbers-visible
      \override BarNumber.break-visibility = #begin-of-line-visible
      \override SectionLabel.padding = #2
    }
  }

  \midi {
    \tempo 4 = 70
    \context {
      \Staff
      \remove "Staff_performer"
    }
    \context {
      \Voice
      \consists "Staff_performer"
    }
    \context {
      \ChordNames
      \remove "Note_performer"
    }
  }
}

