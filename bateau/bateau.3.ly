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

% VAMP
textOne = \lyricmode {
  \offsetLeft "① Comme je descendais des Fleuves impassibles,"
  \offsetLeftSmall "Je ne me sentis plus guidé par les haleurs :"
} textOneAndAHalf = \lyricmode {
  \offsetLeft "Des Peaux-Rouges criards les avaient pris pour cibles,"
  \offsetLeftSmall "Les ayant cloués nus aux poteaux de couleurs"
}

% SEQUENCE
textTwoThreeFourFive = \lyricmode {
  \offsetLeft "② J’étais insoucieux de tous les équipages,"
  \offsetLeftSmall "Porteur de blés flamands ou de cotons anglais."
  \offsetLeft "Quand avec mes haleurs ont fini ces tapages,"
  \offsetLeftSmall "Les Fleuves m’ont laissé descendre où je voulais."

  \offsetLeft "③ Dans les clapotements furieux des marées,"
  \offsetLeftSmall "Moi, l’autre hiver, plus sourd que les cerveaux d’enfants,"
  \offsetLeft "Je courus ! Et les Péninsules démarrées"
  \offsetLeftSmall "N’ont pas subi tohu-bohus plus triomphants."

  \offsetLeft "④ La tempête a béni mes éveils maritimes."
  \offsetLeftSmall "Plus léger qu’un bouchon j’ai dansé sur les flots"
  \offsetLeft "Qu’on appelle rouleurs éternels de victimes,"
  \offsetLeftSmall "Dix nuits, sans regretter l’œil niais des falots !"

  \offsetLeft "⑤ Plus douce qu’aux enfants la chair des pommes sures,"
  \offsetLeftSmall "L’eau verte pénétra ma coque de sapin"
  \offsetLeft "Et des taches de vins bleus et des vomissures"
  \offsetLeftSmall "Me lava, dispersant gouvernail et grappin." " "
}

% CLIMAX
textSix = \lyricmode {
  \offsetLeft "⑥ Et dès lors, je me suis baigné dans le Poème "
  \offsetLeftSmall "De la Mer, infusé d’astres, et lactescent, "
} textSixAndAHalf = \lyricmode {
  \offsetLeft "Dévorant les azurs verts ; où, flottaison blême "
  \offsetLeftSmall "Et ravie, un noyé pensif parfois descend ; "
} textSeven=  \lyricmode {
  \offsetLeft "⑦ Où, teignant tout à coup les bleuités, délires "
  \offsetLeftSmall "Et rythmes lents sous les rutilements du jour, "
  \offsetLeft "Plus fortes que l’alcool, plus vastes que nos lyres, "
  \offsetLeftSmall "Fermentent les rousseurs amères de l’amour ! "
}

% RE-VAMP
textHeight =  \lyricmode {
  \offsetLeft "⑧ Je sais les cieux crevant en éclairs, et les trombes "
  \offsetLeftSmall "Et les ressacs, et les courants : je sais le soir, " " "
} textHeightndAHalf = \lyricmode {
  \offsetLeft "L’Aube exaltée ainsi qu’un peuple de colombes, "
  \offsetLeftSmall "Et j’ai vu quelquefois ce que l’homme a cru voir ! " " "
} textNine = \lyricmode {
  \offsetLeft "⑨ J’ai vu le soleil bas, taché d’horreurs mystiques, "
  \offsetLeftSmall "Illuminant de longs figements violets, " " "
} textNineAndAHalf = \lyricmode {
  \offsetLeft "Pareils à des acteurs de drames très antiques "
  \offsetLeftSmall "Les flots roulant au loin leurs frissons de volets ! " " "
}

% ETC.
% (...)

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
        \chordmode {
          \partial 2
          s2
          | d1:7 
          | g4.:7  c4.:9sus4 s4
          | d1:7
          | g4.:7  c4.:9sus4 s4

          \repeat volta 2 {
            | d1:7
            | g2:7/d  c:7/d
          }

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

          {
            \repeat volta 2 {
              | d1
              | bes/f
            }
            | b:m
            | a
            | d
            | d
          }

          \repeat volta 4 {
            | d1:7
            | g2:7/d  c:7/d
          }
        }
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
        \section \sectionLine "Climax"
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

\markup {   
  \vspace #1 
  \hspace #3.5 \large "(...)" 
}

\markup \with-color #darkGray \sans \abs-fontsize #9 \column {
  \vspace #3
  \fill-line { \center-column {
    \line { "Demo score: quatrains 1–9 of 25 are shown." }
    \line { "The complete version reuses the same music, with" }
    \line { "minor variations, for the remaining quatrains (10–25)." }
  } }
  \vspace #1
  \fill-line { \center-column {
    \line { "The climactic section quotes the closing chords of" }
    \line { "Richard Strauss," \italic "Vier letzte Lieder," "no. 4, “Im Abendrot”" }
    \line { "(original key: E-flat major; transposed to D)." }
  } }
}

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

