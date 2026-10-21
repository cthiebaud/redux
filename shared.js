// Shared between index.html and paroles.html: language detection and the
// bits of copy that appear identically on both pages' headers.

const ALERTE_AVAILABLE_LANGS = ['en', 'fr', 'it', 'de', 'es'];

const ALERTE_SUBTITLE_BY_LANG = {
  en: 'Exercises in Style',
  fr: 'Exercices de style',
  it: 'Esercizi di stile',
  de: 'Stilübungen',
  es: 'Ejercicios de estilo'
};

// A nod to Raymond Queneau's book of the same name — 99 retellings of one
// trivial story, the literary equivalent of this page's musical variations.
// No Spanish Wikipedia article exists, so the Spanish subtitle links to the
// English one rather than the loosely-related Catalan edition.
const ALERTE_SUBTITLE_LINK_BY_LANG = {
  en: 'https://en.wikipedia.org/wiki/Exercises_in_Style',
  fr: 'https://fr.wikipedia.org/wiki/Exercices_de_style',
  it: 'https://it.wikipedia.org/wiki/Esercizi_di_stile',
  de: 'https://de.wikipedia.org/wiki/Stil%C3%BCbungen_(Queneau)',
  es: 'https://en.wikipedia.org/wiki/Exercises_in_Style'
};

// Sober, pun-free: just how many variations are on the page. Update by hand
// whenever a numbered variant is added or removed (not the Original track,
// and not any of the non-Alerte bonus tracks like Guess What or Matsubaba).
const ALERTE_SUBTITLE_COUNT_BY_LANG = {
  en: 'Thirty Variations on Alerte',
  fr: "Trente variations d'Alerte",
  it: 'Trenta variazioni di Alerte',
  de: 'Dreißig Variationen von Alerte',
  es: 'Treinta variaciones de Alerte'
};

const ALERTE_AUTHOR_BY_LANG = {
  en: {
    heading: 'Authors',
    mugnier: 'Éric Mugnier: lyrics 100%, music 98%.',
    thiebaud: 'Christophe Thiebaud: music 2%, production 100%.'
  },
  fr: {
    heading: 'Auteurs',
    mugnier: 'Éric Mugnier : paroles 100 %, musique 98 %.',
    thiebaud: 'Christophe Thiebaud : musique 2 %, production 100 %.'
  },
  it: {
    heading: 'Autori',
    mugnier: 'Éric Mugnier: testo 100%, musica 98%.',
    thiebaud: 'Christophe Thiebaud: musica 2%, produzione 100%.'
  },
  de: {
    heading: 'Autoren',
    mugnier: 'Éric Mugnier: Text 100 %, Musik 98 %.',
    thiebaud: 'Christophe Thiebaud: Musik 2 %, Produktion 100 %.'
  },
  es: {
    heading: 'Autores',
    mugnier: 'Éric Mugnier: letra 100%, música 98%.',
    thiebaud: 'Christophe Thiebaud: música 2%, producción 100%.'
  }
};

// Update by hand whenever a substantive change is made to the page.
const ALERTE_LAST_UPDATED_BY_LANG = {
  en: 'Last updated: October 10, 2026.',
  fr: 'Dernière mise à jour : 10 octobre 2026.',
  it: 'Ultimo aggiornamento: 10 ottobre 2026.',
  de: 'Letzte Aktualisierung: 10. Oktober 2026.',
  es: 'Última actualización: 10 de octubre de 2026.'
};

const ALERTE_ABOUT_LABELS = {
  en: { trigger: 'About', title: 'About "Alerte"', then: '1984', now: 'Now' },
  fr: { trigger: 'À propos', title: '« Alerte », en coulisses', then: '1984', now: "Aujourd'hui" },
  it: { trigger: 'Info', title: 'Dietro le quinte di "Alerte"', then: '1984', now: 'Oggi' },
  de: { trigger: 'Info', title: 'Hinter den Kulissen von „Alerte“', then: '1984', now: 'Heute' },
  es: { trigger: 'Acerca de', title: 'Detrás de "Alerte"', then: '1984', now: 'Ahora' }
};

const ALERTE_NAV_LABELS = {
  music: { en: 'Music', fr: 'Musique', it: 'Musica', de: 'Musik', es: 'Música' },
  lyrics: { en: 'Lyrics', fr: 'Paroles', it: 'Testi', de: 'Texte', es: 'Letras' }
};

const ALERTE_STYLE_SUMMARY_BY_LANG = {
  en: 'Suno style',
  fr: 'Style Suno',
  it: 'Stile Suno',
  de: 'Suno-Stil',
  es: 'Estilo Suno'
};

const ALERTE_RATINGS_INTRO_BY_LANG = {
  en: 'My ratings for Alerte:',
  fr: 'Mes notes pour Alerte :',
  it: 'Le mie valutazioni per Alerte:',
  de: 'Meine Bewertungen für Alerte:',
  es: 'Mis valoraciones para Alerte:'
};

const ALERTE_BUTTON_LABELS_BY_LANG = {
  en: { send: 'Vote via', clear: 'Clear my ratings', shuffle: 'Shuffle', play: 'Play', stop: 'Stop', reveal: 'Click and hold to reveal' },
  fr: { send: 'Votez via', clear: 'Effacer mes votes', shuffle: 'Aléatoire', play: 'Lecture', stop: 'Arrêt', reveal: 'Clic maintenu pour révéler' },
  it: { send: 'Vota via', clear: 'Cancella le mie valutazioni', shuffle: 'Casuale', play: 'Riproduci', stop: 'Stop', reveal: 'Clic prolungato per rivelare' },
  de: { send: 'Abstimmen via', clear: 'Meine Bewertungen löschen', shuffle: 'Zufällig', play: 'Wiedergabe', stop: 'Stopp', reveal: 'Klicken und halten zum Aufdecken' },
  es: { send: 'Vota por', clear: 'Borrar mis valoraciones', shuffle: 'Aleatoria', play: 'Reproducir', stop: 'Detener', reveal: 'Clic mantenido para revelar' }
};

// Verse/Chorus/Hook/Bridge, localized to the reader's UI language —
// independent of which lyrics language is being shown. Used by
// paroles.html's localizeSectionLabel(). "Hook" (hip-hop) is kept as its
// own loanword rather than folded into "chorus".
const ALERTE_SECTION_WORDS_BY_LANG = {
  en: { verse: 'Verse', chorus: 'Chorus', hook: 'Hook', bridge: 'Bridge' },
  fr: { verse: 'Couplet', chorus: 'Refrain', hook: 'Hook', bridge: 'Pont' },
  it: { verse: 'Strofa', chorus: 'Ritornello', hook: 'Hook', bridge: 'Ponte' },
  de: { verse: 'Strophe', chorus: 'Refrain', hook: 'Hook', bridge: 'Bridge' },
  es: { verse: 'Estrofa', chorus: 'Estribillo', hook: 'Hook', bridge: 'Puente' }
};

// The four footer "note" paragraphs on index.html. Trusted HTML (not user
// input) with hrefs baked in directly, since every link's target is the
// same across all 5 languages — only the surrounding prose and link text
// change. Applied via .innerHTML in setLang().
const ALERTE_NOTES_BY_LANG = {
  intro: {
    en: `A quick word on how this happened: I uploaded the original to <a href="https://suno.com" target="_blank" rel="noopener">Suno</a>'s free tier and asked it to generate the styles you hear above. I did not edit Suno's output in any way: what you hear is exactly what it produced. That said, I often had to generate several versions before getting one I could endorse and share.`,
    fr: `Un mot sur la genèse de ces variations : j'ai uploadé l'original vers la version gratuite de <a href="https://suno.com" target="_blank" rel="noopener">Suno</a> et je lui ai demandé de générer les styles présentés ci-dessus. Je n'ai en aucune façon modifié ce que Suno a produit. Cela dit, il m'a souvent fallu générer plusieurs versions avant d'en obtenir une que je pouvais approuver et partager.`,
    it: `Due parole sulla genesi di queste variazioni: ho caricato l'originale sulla versione gratuita di <a href="https://suno.com" target="_blank" rel="noopener">Suno</a> e gli ho chiesto di generare gli stili qui presentati. Non ho in alcun modo modificato il risultato prodotto da Suno: quello che si ascolta qui è esattamente ciò che ha generato. Detto questo, ho spesso dovuto generare diverse versioni prima di ottenerne una che potessi approvare e condividere.`,
    de: `Ein paar Worte zur Entstehung dieser Variationen: Ich habe das Original in die kostenlose Version von <a href="https://suno.com" target="_blank" rel="noopener">Suno</a> hochgeladen und Suno gebeten, die oben präsentierten Stile zu erzeugen. Das von Suno erzeugte Ergebnis habe ich in keiner Weise bearbeitet: Was man hier hört, ist genau das, was dabei herauskam. Allerdings musste ich oft mehrere Versionen erzeugen, bevor ich eine bekam, die ich guten Gewissens teilen konnte.`,
    es: `Una palabra rápida sobre cómo surgió esto: subí el original al plan gratuito de <a href="https://suno.com" target="_blank" rel="noopener">Suno</a> y le pedí que generara los estilos que escuchas arriba. No edité de ninguna manera lo que produjo Suno: lo que se escucha aquí es exactamente lo que generó. Dicho esto, a menudo tuve que generar varias versiones antes de obtener una que pudiera avalar y compartir.`
  },
  addendumLabel: {
    en: `Addendum:`,
    fr: `Addendum :`,
    it: `Addendum:`,
    de: `Nachtrag:`,
    es: `Adenda:`
  },
  addendumText: {
    en: `after a certain number of variations made with Suno's free tier, I resolved to spend €10.98 on a month of the basic Pro subscription. Can you guess starting from which number?`,
    fr: `après un certain nombre de variantes réalisées avec la version gratuite de Suno, je me suis résolu à investir 10,98 € dans un mois d'abonnement à la version Pro de base. Saurez-vous deviner à partir de quel numéro ?`,
    it: `dopo un certo numero di variazioni realizzate con la versione gratuita di Suno, mi sono risolto a investire 10,98 € in un mese di abbonamento alla versione Pro di base. Saprete indovinare a partire da quale numero?`,
    de: `nach einer gewissen Anzahl von mit der kostenlosen Version von Suno erstellten Variationen habe ich mich entschlossen, 10,98 € in einen Monat des einfachen Pro-Abonnements zu investieren. Erraten Sie, ab welcher Nummer?`,
    es: `después de un cierto número de variaciones hechas con la versión gratuita de Suno, me resolví a invertir 10,98 € en un mes de suscripción a la versión Pro básica. ¿Sabrán adivinar a partir de qué número?`
  },
  translated: {
    en: `The original French text was translated into Egyptian Arabic, English (+ hip-hop and Delta blues versions), German (+ Sprechgesang version), Hebrew, Italian, Japanese, Korean, Latin, Mongolian, Portuguese (+ Brazilian version), Russian, Scottish Gaelic, Spanish (+ Andalusian version) and Ukrainian by <a href="https://claude.ai" target="_blank" rel="noopener">Claude</a>. You can read the lyrics in every language on the <a href="paroles.html">lyrics page</a>.`,
    fr: `Le texte original en français a été traduit en allemand (+ version Sprechgesang), anglais (+ versions hip-hop et Delta blues), arabe (égyptien), coréen, espagnol (+ version andalouse), gaélique écossais, hébreu, italien, japonais, latin, mongol, portugais (+ version brésilienne), russe et ukrainien par <a href="https://claude.ai" target="_blank" rel="noopener">Claude</a>. On peut lire les paroles dans toutes ces langues sur la <a href="paroles.html">page des paroles</a>.`,
    it: `Il testo originale in francese è stato tradotto in arabo egiziano, coreano, ebraico, gaelico scozzese, giapponese, inglese (+ versioni hip-hop e Delta blues), italiano, latino, mongolo, portoghese (+ versione brasiliana), russo, spagnolo (+ versione andalusa), tedesco (+ versione Sprechgesang) e ucraino da <a href="https://claude.ai" target="_blank" rel="noopener">Claude</a>. Il testo può essere letto in tutte queste lingue nella <a href="paroles.html">pagina dei testi</a>.`,
    de: `Der ursprüngliche französische Text wurde von <a href="https://claude.ai" target="_blank" rel="noopener">Claude</a> ins Ägyptisch-Arabische, Deutsche (+ Sprechgesang-Version), Englische (+ Hip-Hop- und Delta-Blues-Version), Hebräische, Italienische, Japanische, Koreanische, Lateinische, Mongolische, Portugiesische (+ brasilianische Version), Russische, Schottisch-Gälische, Spanische (+ andalusische Version) und Ukrainische übersetzt. Die Texte in all diesen Sprachen kann man auf der <a href="paroles.html">Liedtext-Seite</a> finden.`,
    es: `El texto original en francés fue traducido al alemán (+ versión Sprechgesang), árabe egipcio, coreano, español (+ versión andaluza), gaélico escocés, hebreo, inglés (+ versiones hip-hop y Delta blues), italiano, japonés, latín, mongol, portugués (+ versión brasileña), ruso y ucraniano por <a href="https://claude.ai" target="_blank" rel="noopener">Claude</a>. Las letras en todos estos idiomas pueden leerse en la <a href="paroles.html">página de las letras</a>.`
  },
  stage: {
    en: `Curious what <a href="https://www.youtube.com/watch?v=OZuS8QQsQK8&amp;t=540s" target="_blank" rel="noopener">"Alerte" looked like on stage in 1984</a>?`,
    fr: `Envie de voir à quoi ressemblait <a href="https://www.youtube.com/watch?v=OZuS8QQsQK8&amp;t=540s" target="_blank" rel="noopener">«&nbsp;Alerte&nbsp;» sur scène en 1984</a> ?`,
    it: `Curiosi di come fosse <a href="https://www.youtube.com/watch?v=OZuS8QQsQK8&amp;t=540s" target="_blank" rel="noopener">"Alerte" sul palco nel 1984</a>?`,
    de: `Neugierig, wie <a href="https://www.youtube.com/watch?v=OZuS8QQsQK8&amp;t=540s" target="_blank" rel="noopener">„Alerte" 1984 auf der Bühne</a> aussah?`,
    es: `¿Curiosidad por cómo era <a href="https://www.youtube.com/watch?v=OZuS8QQsQK8&amp;t=540s" target="_blank" rel="noopener">"Alerte" en el escenario en 1984</a>?`
  }
};

function detectAlerteLang() {
  const browserLang = (navigator.language || '').slice(0, 2).toLowerCase();
  return ALERTE_AVAILABLE_LANGS.includes(browserLang) ? browserLang : 'en';
}

// Open `url` in the browsing context named `name`, reusing an already-open
// tab without reloading it when it's already showing the right page — a
// plain <a target="name"> would still reload that tab even if it's already
// on that exact URL, which resets in-page state (e.g. playing audio).
function openOrFocusNamed(url, name) {
  const win = window.open('', name);
  if (!win) return; // popup blocked; let the native link fall back

  const target = new URL(url, window.location.href);

  if (!win.location.href || win.location.href === 'about:blank') {
    win.location.href = target.href;
  } else {
    const current = new URL(win.location.href);
    if (current.pathname !== target.pathname) {
      win.location.href = target.href;
    } else if (current.hash !== target.hash) {
      win.location.hash = target.hash || '';
    }
  }

  win.focus();
}
