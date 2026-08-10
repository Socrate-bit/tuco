# Learna — Product Spec (inferred from UI Raw screenshots)

AI language-tutor app ("Learna"). The user learns a target language (e.g. Spanish) by talking to an AI robot tutor in a video-call-like interface. Lessons follow a Duolingo-style path; progress is tracked with streaks, vocabulary, grammar feedback and call-time stats. App UI language is the user's native/app language (screenshots are in French), conversation content is in the target language.

---

## 1. Navigation shell

Bottom navigation bar with 3 tabs (labels localized):
- **Accueil** (home icon) — lesson path
- **Progression** (bar-chart icon) — stats & feedback hub
- **Profil** (person icon) — profile & settings

Active tab = blue icon + blue label; inactive = grey. Bar is white, slight top border.

---

## 2. Accueil (Home) — `home_page.PNG`, `home_page_scrolled.PNG`

**Header (dark-blue gradient, ~1/3 screen height):**
- Robot tutor image centered (static image), radial glow behind head.
- Top-left pill (translucent white): target-language flag emoji + code ("🇪🇸 ES") → opens target-language selection.
- Top-right pill: 🔥 + current streak count → opens Streak page (Série).
- Bottom-left pill: people icon + chevron → (community/characters selector — see open questions).
- Bottom-right: blue rounded "Échange" button with video-camera icon → starts a **free conversation** call (no lesson).

**Lesson path (white background, scrolls under header):**
- Section dividers: level name centered between two horizontal lines, light blue-grey ("Débutant", "Intermédiaire", …).
- Lessons laid out on a vertical winding path (alternating center/left/right positions connected by a light-grey rounded path line).
- Each lesson node: big circle (~90px) with white icon; label below (dark blue, 2 lines max).
  - **Current/next lesson**: orange/red filled circle with white ring + outer orange ring.
  - **Locked lesson**: grey circle + small lock badge bottom-right.
  - **Completed lesson**: (assumed: colored, no lock — not visible in screenshots).
- Débutant lessons visible: Saludos (👋), Introducciones I (flag), Introducciones II (notebook), Pedir En Un Café (food dome), … Buenos amigos, Celebraciones y festivales, Expresando opiniones.
- Intermédiaire: Actividades infantiles, Tecnología Digital, Los regalos, …
- Floating "scroll to top" button (white rounded square, blue ↑) appears when scrolled down, bottom-right above nav bar.

Tapping the current lesson starts a **lesson call**.

---

## 3. Call screen (lesson & free conversation) — `IMG_5131.PNG`, `speaking_page_part2.PNG`

Full-screen immersive "video call" with the robot tutor.

**Top (dark-blue header with robot image, ~40% height):**
- Top-left: X (close) in translucent circle → end call (confirm?).
- Top-right: "1x" pill → toggles TTS playback speed (e.g. 1x / 0.75x / slower).
- Bottom-left overlay (lesson mode only): vertical 2-step progress — "Leçon" → "Entraînement", dot + connecting line; current step white/bold, done/inactive grey.
- Bottom-right: expand icon (fullscreen avatar view).

**Chat area (white, scrolls under header):**
- AI messages: light-grey bubble left; to its right two small circular buttons: translate (文A) and play (▶) for TTS replay.
- Short AI instruction bubbles (e.g. `Say "gracias".`) same style.
- User messages: light-blue bubble right; to its left a small feedback icon button (message-with-dot) → opens feedback for that sentence (grammar correction / alternatives).
- Phase banners (full-width rounded cards):
  - Orange "Cours" banner with Aa icon — start of lesson phase.
  - Orange "🏁 Cours terminé ! / À vous de jouer !" — end of lesson phase.
  - Purple "Entraînement" banner with theater-masks icon — start of practice phase.
- Scroll-to-bottom floating blue ↓ button when scrolled up.

**Bottom controls:**
- Left: "Type" (keyboard icon, light-blue circle + label) → text input mode.
- Center: big blue mic button (~90px) → push/tap to talk (speech-to-text).
- Right: "Inspiration" (lightbulb icon + label) → suggested replies.

**Flow (lesson):** AI greets in English/native + target language, teaches words one by one ("Say \"gracias\""), user repeats/answers by voice or text; after lesson phase → practice phase (conversation using learned material); after practice → end screen.

---

## 4. Lesson end screen — `practice_end.PNG`

Full-screen, blurred robot background fading to white.
- X top-left.
- Centered: 🏁 crossed checkered flags image, big blue title "Cours terminé !", grey subtitle ("Bravo, tu assures ! La maîtrise est à portée de main !").
- 3 stat cards in a row (colored border + colored header band, white value area):
  - "Nouveaux Mots" (blue) — 💬 count
  - "Leçons Terminées" (green) — ▶ count
  - "Durée leçon" (orange) — 🕐 mm:ss
- Primary blue button "Passer à la leçon suivante".
- Text link "Revenir sur la page d'accueil" (dark blue, underlined-ish).

After this (first lesson of the day) → **Streak win** screen; App Store review prompt may show after a completed lesson (`ask_review.PNG`).

---

## 5. Streak win screen — `streak_win.PNG`

Full-screen white with soft orange glow top.
- Big 🔥 image centered, huge orange count ("1"), orange subtitle "jours de série".
- Grey helper text: "Suivez une leçon chaque jour pour maintenir votre série !"
- Week row card: lun.→dim. labels, fire icon per day (orange = done, grey = not), today's label orange.
- Blue button "Compris !".

---

## 6. Streak page (Série) — `streak_page.PNG`, `IMG_5130.PNG`

- Cream/light-yellow header: back button (white circle), centered title "Série", big 🔥 + count + "jours de série".
- White body:
  - Month header "août 2026" + prev/next chevrons (greyed when unavailable).
  - Stats card: 🔥 "Série la plus longue" + count | ✅ "Entraînement du mois" + count.
  - Calendar card: lun.→dim. columns, day numbers; practiced day = orange circle highlight + small orange dot under; today marked with dot.
- Bottom blue button "Continuer l'apprentissage".

---

## 7. Progression tab — `progression_page.PNG`, `progression_page_scrolled2.PNG`

Scrollable list of sections (grey background, white cards, section titles bold dark):

1. **Centre de feedback** — two cards side by side:
   - Teal card "Grammaire": 📚 emoji, white circle chevron top-right, count + "fois" → Grammaire page.
   - Green card "Alternatives": 🧐 emoji, count + "fois" → Alternatives page.
   - Counts = number of feedback items (see open questions).
2. **Exercice de vocabulaire** — card: thin progress bar (learned/total), "Nouveaux mots" 🔖 count and "Mots à venir" 🔖 count, blue chevron → Vocabulary page.
3. **Votre série** — card: two stat pills ("Série quotidienne" orange, "Série la plus longue" red/orange) with counts; week row lun.→dim. with fire icons (like streak win).
4. **Temps passé en appel** — card: three stats ("Temps passé" 12 m 8 s, "Moyenne" 1 m 44 s, "Objectif" 10 m — hourglass icons) + bar chart of last 7 days (blue-purple bars, value label above bar, grey day labels, today last).
5. **Historique des appels** — section title + "Tout afficher" link → full history page. Shows last 3 calls as cards: colored circle icon (lesson icon+color, or blue video-cam for free conversation), title (lesson name / "Conversation Libre"), date "10 août 2026, 2:53 PM", chevron.

---

## 8. Historique des appels page — `practices_history.PNG`

- White header: back button, centered blue title "Historique des appels".
- Grey body: full list of call cards (same style as above).
- Tapping a call → call transcript/detail (see open questions).

---

## 9. Vocabulary page — `vocabulaire_page_tab1.PNG`, `vocabulaire_page_tab2.PNG`

- Header: back button, blue title "Exercice de vocabulaire".
- Two tabs: "Appris" + count badge, "À venir" + count badge (active tab dark-blue text, dark-blue badge with white text, underline; inactive grey).
- Word list (one white card, divider lines): each row = grey circle with blue speaker icon (plays TTS of word) + word (bold dark blue) + translation below (grey).
- "Appris" = learned words (7); "À venir" = upcoming curriculum words (898).

---

## 10. Grammaire page — `grammaire_page.PNG`

- Header: back button, blue title "Grammaire".
- Horizontal filter chips: "Tout" (selected = blue filled), "Excellent", "Peut Mieux Faire", "Des améliorations…" (outlined).
- Feedback cards: red outlined pill "Score: 50 | Des améliorations sont nécessaires !" (color varies by score band), the user's sentence with erroneous words highlighted (red background + underline), chevron ▼ to expand (expanded view shows correction/explanation — not in screenshots, see open questions).

Score bands (inferred): Excellent / Peut mieux faire / Des améliorations sont nécessaires.

---

## 11. Alternatives page — `alternatives_page.PNG`

- Header: back button, blue title "Alternatives".
- List of alternative-phrasing feedback items (better/more natural ways to say what the user said).
- Empty state: big light-blue circle illustration (feedback icon + 👆 pointing hand over chat lines) + grey text "Pas d'erreurs ici ! Vous pouvez appuyer sur le bouton de commentaires dans la leçon pour vérifier vos erreurs."

---

## 12. Profil tab — `profil_page.PNG`

- White header area: avatar circle (blue, initial letter, small + badge to add photo), name "Lucas" + chevron (edit name), email below (grey, truncated). Gear icon top-right → settings (account/legal/logout — see open questions).
- Toggle card: "Étudier dans ma langue maternelle" + blue switch.
- Settings list (white card, dividers, each row: emoji + blue label + grey value + chevron):
  - 🎯 Langue cible → Espagnol (flag)
  - 🇪🇸 Niveau de langue → Débutant (flag emoji matches target language)
  - 👶 Langue maternelle → English
  - 🎭 Centres d'intérêt → Technologie… (multi-select)
  - ⛳ Objectif quotidien → 10 min/jour
  - 🔔 Rappel quotidien → Désactivé / time
- Each row opens a picker (bottom sheet or page).

---

## 13. Review prompt — `ask_review.PNG`

Bottom sheet over call screen: cute cat image in warm circle, 5 orange stars, title "Merci d'utiliser Learna !", subtitle "Vous aimez Learna ? Laissez-nous une note, ça nous aide beaucoup !", blue button "C'est parti !" (→ in_app_review), text link "Peut-être plus tard".

---

## Data model (Firestore, per user)

- `users/{uid}`: name, email, photo, nativeLanguage, targetLanguage, level, interests[], dailyGoalMinutes, reminderTime?, studyInNativeLanguage, streak {current, longest, lastPracticeDate}, createdAt.
- `users/{uid}/calls/{id}`: type (lesson|free), lessonId?, title, startedAt, durationSeconds, transcript [{role, text, translation?}], newWordsCount.
- `users/{uid}/feedback/{id}`: type (grammar|alternative), callId, originalText, correctedText?, errorRanges[], score, explanation, createdAt.
- `users/{uid}/vocab/{word}`: word, translation, status (learned|upcoming), learnedAt, lessonId.
- `users/{uid}/practiceDays/{yyyy-MM-dd}`: callSeconds, lessonsCompleted.
- Curriculum (static or `curriculum/{lang}`): levels → lessons {id, title (target language), icon, order, vocab[{word, translation}], grammarPoints[]}.

## Architecture (per CLAUDE.md)

- Feature-first folders: `auth/`, `home/`, `call/`, `progression/`, `vocabulary/`, `feedback/` (grammar+alternatives), `streak/`, `profile/`, `history/` — each with `service/`, `cubit/`, `screen/`, `widget/`; shared `core/` (theme, l10n, router, common widgets).
- Cubit everywhere, Equatable states, Firebase streams for reactivity, optimistic updates.
- Single theme file; l10n (French first, en base); ScreenUtil sizing; haptics on all taps; analytics events; debugPrint logging with class tags.
- AI conversation: firebase_ai (Gemini) for tutor replies + grammar/alternative feedback; speech_to_text for voice input; TTS for robot voice (see open questions).
