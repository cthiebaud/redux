\version "2.26.0"

#(set-global-staff-size 16)

#(define darkGray (rgb-color 0.5 0.5 0.5))

\paper {

  property-defaults.fonts.serif      = "Nimbus Sans"      % default text
  property-defaults.fonts.sans       = "Nimbus Sans"
  property-defaults.fonts.typewriter = "Nimbus Mono PS"

  page-breaking = #ly:minimal-breaking
  system-system-spacing.padding = #1.8
  ragged-bottom = ##t

  %%% system-system-spacing.basic-distance = #10
  %%% system-system-spacing.minimum-distance = #6
}

sectionLineMarkup =
#(define-markup-command (sectionLineMarkup layout props text) (markup?)
   (let ((lw (ly:output-def-lookup layout 'line-width)))
     (interpret-markup layout props
       #{
         \markup \column {
           \vspace #1
           \with-color #darkGray \override #'(thickness . 2) \draw-dotted-line #(cons lw 0)
           \vspace #0.3
           \with-color #darkGray #text
         }
       #})))

sectionLine = #(define-music-function (text) (markup?)
  #{ \sectionLabel \markup \sectionLineMarkup #text #})

offsetLeft =
#(define-music-function () ()
   #{
     \once \override LyricText.after-line-breaking =
       #(lambda (grob)
          (let* ((sys  (ly:grob-system grob))
                 (left (car (ly:grob-extent grob sys X))))
            (ly:grob-translate-axis! grob (- 3.5 left) X)))
   #})

offsetLeftSmall = \tweak extra-offset #'(-3.5 . 0) \etc

% Lyrics for quatrains 1-9 (sung) and the plain-verse continuation for
% quatrains 10-25 are generated from bateau_ivre.yaml -- see
% generate_lyrics.py. Re-run it after editing the yaml, before compiling.
\include "bateau_lyrics.ily"

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
  | d1
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

% sequence

sequence = {
  \voiceOne
  | <f'     bes'  d''              >1 ( 
  | <e'     bes'  dis''            >  )(
  | <a'     cis'' e''              >  )(
  | <a'     d''   f''              >  )(
  | <bes'   d''   fis''            >  )(
  | <bes'   cis'' g''              >  )(
  | <ges'   c''   eeses'' aes''    >  )(
  | <f'     b'    d''      a''     >  )
  % 
  | <d'     bes'  f''      a''     >1 ( 
  | <e'     bes'  dis''    aes''   >  )(
  | <e'     a'    cis''    g''     >  )(
  | <a'           d''      fis''   >  )(
  | <a'     bes'  d''      f''     >  )(  % E7sus4(b5,b9) (bass e' at line 221)
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
  | g1 
  | c' 
  \break
  | f 
  | bes 
  \break
  | e 
  | a 
  \break
  | as
  | g
%
  | << \tag #'score { g } \tag #'midi { g' } >>
  | c'
  \break
  | << \tag #'score { f } \tag #'midi { f' } >>
  | bes
  \break
  | << \tag #'score { e } \tag #'midi { e' } >>
  | a
  \break
  | as
  | g2   c'
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
    | d1
    | f1
  }
  \set Score.currentBarNumber = #29
  \break
  | b1
  | a1
  \break
  | d1
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
  | d
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
  | d,2 d,2 
  | d,2 d,2 
  | d,2 d,4. d,8~
  | d,1
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

% The Outro is a fully independent piece: its own StaffGroup, its own
% fresh timing starting at bar 1, no relation to pieceMusic. It's placed
% after the poem continuation in the file so it prints after it too.
outroMusic = {
  \new StaffGroup { <<
    \set StaffGroup.systemStartDelimiter = #'SystemStartSquare
    \new Staff = "outroMelody" \with {
      \RemoveEmptyStaves
    } {
      \clef "treble_8"
      \key g \major
      \partial 2
      r16 a16 d'16 a'16 g'16 f'16 d'16 c'16
      \outroLeadGuitar
      \bar "|."
    }
    \new Staff = "outroEcho" \with {
      \RemoveEmptyStaves
    } {
      \set Staff.midiInstrument = "vibraphone"
      \clef "treble_8"
      \key g \major
      \partial 2
      r2
      \outroEcho
      \bar "|."
    }
    \new Staff = "outroMain" {
      \set Staff.midiInstrument = "acoustic guitar (nylon)"
      <<
        \new ChordNames \with {
          alignAboveContext = "outroMain"
        } {
          \chordmode {
            \partial 2
            s2
            % TODO: outro chords
            s1 s1 s1 s1
          }
        }
        \new Voice = "outroBasseVoice" {
          \key g \major
          \section \sectionLine "Outro"
          \partial 2
          r2
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\header {
  title = "Le Bateau ivre"
  % subtitle = \markup { \abs-fontsize #10 "lundi 11 juin 2018, 8 h 20 du matin"}
  poet = "Poème d’Arthur Rimbaud"
  composer = "Musique de Christophe Thiebaud"
  copyright = \markup \with-color #darkGray \small {
    \center-column {
      "© 2026 Christophe Thiebaud. All rights reserved."
      "Registered with SACEM · ISWC T-305.593.089-3"
    }
  }
  tagline = \markup \with-color #darkGray
    \pad-to-box #'(0 . 0) #'(0 . 3)
      \with-url
        "https://lilypond.org"
        #(format #f "LilyPond v~a" (lilypond-version))
}

\markup {
  \vspace #1
}

pieceMusic = \transpose c' c {
  \new StaffGroup { <<
    \set StaffGroup.systemStartDelimiter = #'SystemStartSquare
    \new Staff = "introMelody" \with {
      \RemoveEmptyStaves
      \consists "Timing_translator"
    } {
      \clef "treble_8"
      \key g \major
      \partial 2
      r8 d'''16 a''16 g''16 f''16 d''8
      \introLeadGuitar
      \bar "|"
      d''2_\markup \small \italic \with-color #darkGray \wordwrap {
        After the intro, the guitar continues as an improvised obbligato: a constant voice, not a series of solos.
      }
    }
    \new Staff = "introEcho" \with {
      \consists "Timing_translator"
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
    \new Staff = "main" {

    \set Staff.midiInstrument = "acoustic guitar (nylon)"
    \set Voice.midiInstrument = "acoustic guitar (nylon)"

    % { part I
    <<
      % {
      \new ChordNames \with {
        alignAboveContext = "main"
      } {
        \partial 2
        s2
        \introChordNames
        \repeat volta 2 \vampChordNames
        \sequenceChordNames
        \climaxChordNames
        \repeat volta 4 \vampChordNames
      }
      %}
      {
      \new Voice = "basseI" {
        \set midiInstrument = "acoustic bass"
        \set Voice.instrumentTransposition = c
        \key g \major

        \section \sectionLabel \markup \with-color #darkGray "Intro"
        \partial 2
        r2
        \noBreak
        \voiceTwo
        \introBasse
        \break

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
        \footnote \markup \null #'(0 . 0) \markup \with-color #darkGray \abs-fontsize #9 \wordwrap {
          "The" "climactic" "section" "quotes" "the" "closing" "chords" "of" "Richard" "Strauss,"
          \italic "Vier letzte Lieder,"
          "no." "4," "“Im" "Abendrot”" "(original" "key:" "E-flat" "major;" "transposed" "to" "D)."
        } \sectionLine \markup \concat { "Climax" \super "*" }
        \climaxBasse
        \once \overrideProperty Score.NonMusicalPaperColumn.line-break-system-details
          #'((extra-offset . (0 . 1)))
        \break

        \key g \major
        \section \sectionLine "Vamp"
        \override Score.TextMark.Y-offset = #-2
        \textMark \markup { \tiny "4x" }
        \bar ".|:"
        \repeat volta 4 \vampBasse
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

        \repeat volta 4 \vamp
      }
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
        <<
          \textHeight
          \new Lyrics = "heightAndAHalf" {
            \set associatedVoice = "basseI"
            \textHeightndAHalf
          }
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
    %}

    }
  >> }
}

\score {
  \keepWithTag #'score \pieceMusic

  \layout {
    \clef "treble_8"
    \time 4/4
    indent = #0
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
      \override VerticalAxisGroup.nonstaff-relatedstaff-spacing.minimum-distance = #9
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

\include "bateau_poem_continuation.ily"

\markup {
  \vspace #4
}

\score {
  \outroMusic

  \layout {
    \clef "treble_8"
    \time 4/4
    indent = #0
    short-indent = #0
    \context {
      \Score
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

