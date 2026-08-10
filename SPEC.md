# Learna — Product Spec (inferred from UI Raw screenshots)

AI language-tutor app ("Learna"). The user learns a target language (e.g. Spanish) by talking to an AI robot tutor in a video-call-like interface. Lessons follow a Duolingo-style path; progress is tracked with streaks, vocabulary, grammar feedback and call-time stats. App UI language is French (l10n, French first); conversation content mixes the user's native language and the target language.

## Confirmed decisions
- **AI & voice**: Gemini via `firebase_ai` for tutor replies + feedback generation; `speech_to_text` for voice input; **flutter_tts** for the robot's voice (1x pill = TTS speed toggle).
- **Auth**: Firebase **anonymous auth** only, silent at startup. No login/onboarding/paywall screens. Profile defaults editable in Profil.
- **Content**: **Local seed data** — Spanish curriculum bundled in the app (levels → lessons → vocab + grammar points). User progress in Firestore.
- **Analytics**: **Mixpanel** (already in pubspec).
- Home header **people pill: deleted** (not implemented).
- Call history item → **read-only transcript view**.
- Grammar card expanded → **correction + explanation**.

---

## 1. Navigation shell

Bottom nav, 3 tabs: **Accueil** (home icon), **Progression** (bar-chart), **Profil** (person). Active = blue icon+label; inactive grey. White bar.

---

## 2. Accueil (Home) — `home_page.PNG`, `home_page_scrolled.PNG`

**Header (dark-blue gradient, ~1/3 height):** robot tutor image centered with radial glow.
- Top-left translucent pill: target-language flag + code ("🇪🇸 ES") → target-language picker (bottom sheet, same style as profile pickers).
- Top-right pill: 🔥 + streak count → Streak page.
- Bottom-right: blue "Échange" button (video-cam icon) → free-conversation call.

**Lesson path (white, scrolls under header):**
- Level dividers: "Débutant", "Intermédiaire" centered between lines (light blue-grey).
- Winding vertical path (light-grey rounded connector) alternating node positions center/left/right.
- Lesson node: circle ~90px, white icon, label below (dark blue).
  - **Completed**: lesson-colored circle (e.g. Saludos red-orange) + green check badge bottom-right (`already_started_mission.PNG`).
  - **Current**: lesson-colored circle, raised ring (Saludos red when current; Introducciones I teal when current).
  - **Locked**: grey circle + lock badge.
- Each lesson has its own color + icon (Saludos = red/👋-hand, Introducciones I = teal/flag, …).
- Scroll-to-top floating button (white square, blue ↑) bottom-right when scrolled.

**Tap behavior:**
- Current/completed lesson → **Lesson start sheet** (`mission_start_modal.PNG`).
- Locked lesson → **Skip-ahead modal** (`mission_locked.PNG`): white dialog, 🦘, title "Êtes-vous sûr de vouloir passer à cet exercice ?", grey subtitle, blue "Suivre le parcours" (dismiss) + blue text link "Accéder à l'exercice" (opens that lesson's start sheet anyway).

---

## 3. Lesson start sheet — `mission_start_modal.PNG`

Bottom sheet, top section in the lesson's color (teal for Introducciones I), white drag handle:
- Lesson title (white, bold), English/native description below, two translucent chips: "{n} Mots", "{n} Grammaire".
- White body:
  - "EXERCICES" (teal uppercase label): outlined pill buttons "Leçon" (green Aa badge) and "Exercice" (purple theater-masks badge) — start the call at lesson phase or practice phase.
  - "MOTS À PRATIQUER": horizontally scrollable 2-row grid of word cards (speaker button in grey circle, word bold dark-blue, translation grey).
  - Blue button "Bien compris" (dismiss).
- If the lesson has a saved in-progress session → **Resume sheet** (`already_started_mission.PNG`): "Prêt à reprendre là où vous vous êtes arrêté ?", blue "Reprenons !", text link "Recommencer depuis le début".

---

## 4. Call screen (lesson & free conversation) — `speaking_page_part2.PNG`, `inspiration_button.PNG`, `translation_button.PNG`, `mission_keyboard.PNG`

Immersive "video call" with the robot.

**Header (dark blue, robot image, ~40%):**
- Top-left X in translucent circle → quit confirmation (`quit_mission_pop-up.PNG`): 🤔, "Êtes-vous sûr(e) ?", "Vous ne recevrez pas de rapport d'évaluation si vous ne terminez pas cette session.", blue "Reprendre l'appel", link "Quitter l'appel".
- Top-right "1x" pill → cycles TTS speed.
- Bottom-left (lesson mode): vertical 2-step progress "Leçon" → "Entraînement" (dot + line; active step white bold, other grey).
- Bottom-right: expand icon (fullscreen avatar).

**Chat area (white):**
- AI bubble: light-grey, left; beside it translate (文A) and play (▶) circular grey buttons.
  - Translate tapped → icon turns blue, bubble expands: divider line + greyed translation below original (`translation_button.PNG`).
  - Play → TTS replay of that message.
- User bubble: light-blue, right; feedback icon button on its left (opens that message's feedback: grammar/alternatives).
- Inspiration bubble: cream/yellow, right side, bold title "Quelques exemples de phrases :" + example sentences in target language; translate button beside (`inspiration_button.PNG`).
- Phase banners full-width rounded: orange "Cours" (Aa icon), orange "🏁 Cours terminé ! / À vous de jouer !", purple "Entraînement" (masks icon).
- Floating blue ↓ scroll-to-bottom button when scrolled up.

**Bottom controls:** "Type" (keyboard icon) | big blue mic (push-to-talk STT) | "Inspiration" (lightbulb).
- Type mode (`mission_keyboard.PNG`): rounded text field "Répondre ici" + blue circular mic button right of it, system keyboard; sending returns to normal controls.

**Lesson flow:** greeting → "Cours" banner → teach words/grammar one at a time (short instruction bubbles like `Say "gracias".`) → "Cours terminé" banner → "Entraînement" banner → practice conversation using learned material → end screen. Free conversation ("Échange") = same screen, no stepper/banners, open-ended chat.

---

## 5. Lesson end screen — `practice_end.PNG`

Blurred robot background fading to white. X top-left.
- 🏁 crossed flags, big blue "Cours terminé !", grey subtitle "Bravo, tu assures ! La maîtrise est à portée de main !".
- 3 stat cards (colored header band + white value area): "Nouveaux Mots" (blue, 💬 count), "Leçons Terminées" (green, flag count), "Durée leçon" (orange, 🕐 mm:ss).
- Blue "Passer à la leçon suivante", link "Revenir sur la page d'accueil".
- First completed lesson of the day → **Streak win** screen after. App-review sheet (`ask_review.PNG`) may show after lesson end.

## 6. Streak win — `streak_win.PNG`

White with warm glow: big 🔥, huge orange count, "jours de série", grey helper "Suivez une leçon chaque jour pour maintenir votre série !", week card lun.→dim. (orange fire = practiced, today label orange), blue "Compris !".

## 7. Streak page (Série) — `streak_page.PNG`

Cream header: back button, "Série" title, 🔥 + count + "jours de série".
White body: month header "août 2026" + chevrons; stats card (🔥 "Série la plus longue" | ✅ "Entraînement du mois"); calendar card (lun.→dim., practiced day = orange circle + dot). Blue bottom button "Continuer l'apprentissage".

## 8. Progression tab — `progression_page.PNG`, `progression_page_scrolled2.PNG`

Grey background, sections:
1. **Centre de feedback**: teal "Grammaire" card (📚, count + "fois") and green "Alternatives" card (🧐, count + "fois"), white chevron circle → respective pages.
2. **Exercice de vocabulaire**: card with thin blue progress bar (learned/total), "Nouveaux mots" 🔖 + count, "Mots à venir" 🔖 + count, blue chevron → Vocabulary page.
3. **Votre série**: card with "Série quotidienne" (orange pill) + "Série la plus longue" (red pill) counts, week fire row.
4. **Temps passé en appel**: card with "Temps passé", "Moyenne", "Objectif" (⏳ icons) + 7-day bar chart (blue-purple bars, value label above, today last).
5. **Historique des appels** + "Tout afficher" link: last 3 call cards (colored lesson icon or blue video-cam for "Conversation Libre", title, "10 août 2026, 2:53 PM", chevron).

## 9. Historique des appels — `practices_history.PNG`

Back button, blue title, full call list (same cards). Tap → read-only transcript page (call-screen bubble style, no input).

## 10. Vocabulary page — `vocabulaire_page_tab1/2.PNG`

Back, blue title "Exercice de vocabulaire". Tabs "Appris"/"À venir" with count badges (active: dark-blue text + filled badge + underline). One white card list, dividers; row = grey circle speaker button (TTS) + word (bold dark blue) + translation (grey).

## 11. Grammaire page — `grammaire_page.PNG`, `grammaire_unfoldeditem.PNG`

Back, blue title, filter chips ("Tout" selected blue-filled; "Excellent", "Peut Mieux Faire", "Des améliorations…" outlined).
Feedback card (collapsed): score pill "Score: 50 | Des améliorations sont nécessaires !" (color by band: red ≤ threshold, etc.), sentence with error words highlighted (red bg + underline), chevron.
Expanded: white section with bullet list — ~~Eo~~ → green pill "Buenos" + grey explanation (in native language); footer band (light blue-grey) with lesson icon + lesson name linking the feedback to its call/lesson.
Score bands: Excellent / Peut mieux faire / Des améliorations sont nécessaires.

## 12. Alternatives page — `alternatives_page.PNG`

Same header style. List of alternative-phrasing items (analogous cards). Empty state: light-blue circle illustration (feedback icon + 👆 over chat lines) + grey text "Pas d'erreurs ici ! Vous pouvez appuyer sur le bouton de commentaires dans la leçon pour vérifier vos erreurs."

## 13. Profil tab — `profil_page.PNG`, `profil_modal.PNG`

Header: blue avatar circle with initial + small "+" badge, name + chevron (edit), grey email, gear top-right.
- Toggle card "Étudier dans ma langue maternelle" (ON: tutor explains in native language; OFF: full target-language immersion).
- Settings rows (emoji + blue label + grey value + chevron): 🎯 Langue cible / 🇪🇸 Niveau de langue / 👶 Langue maternelle / 🎭 Centres d'intérêt / ⛳ Objectif quotidien / 🔔 Rappel quotidien.
- Row tap → bottom sheet picker (`profil_modal.PNG`): drag handle, emoji + title, wrap of chip options (flag + label; selected = blue filled; "Plus…" chip expands list), blue "Enregistrer".
- Rappel quotidien → time picker + local notification scheduling (flutter_local_notifications).

## 14. Review prompt — `ask_review.PNG`

Bottom sheet over call: cat image in warm circle, 5 orange stars, "Merci d'utiliser Learna !", subtitle, blue "C'est parti !" (→ in_app_review), link "Peut-être plus tard".

---

## Data model

**Local seed (Dart/JSON):** `curriculum`: levels (Débutant, Intermédiaire, …) → lessons {id, title (ES), description (EN/native), icon, color, order, vocab [{word, translation}], grammarPoints[]}. ~900 words total.

**Firestore (per user, anonymous uid):**
- `users/{uid}`: name, email?, nativeLanguage, targetLanguage, level, interests[], dailyGoalMinutes, reminderTime?, studyInNativeLanguage, streak {current, longest, lastPracticeDate}, createdAt.
- `users/{uid}/calls/{id}`: type (lesson|free), lessonId?, title, startedAt, durationSeconds, phase reached, transcript [{role, text, translation?}], newWordsCount, completed.
- `users/{uid}/feedback/{id}`: type (grammar|alternative), callId, lessonId?, originalText, corrections [{wrong, right, explanation}], score, createdAt.
- `users/{uid}/vocab/{word}`: word, translation, learnedAt, lessonId (learned words only; upcoming = curriculum − learned).
- `users/{uid}/practiceDays/{yyyy-MM-dd}`: callSeconds, lessonsCompleted.

## Architecture (per CLAUDE.md)

Feature-first: `core/` (theme, l10n, router, haptics, analytics service, common widgets), `auth/`, `home/`, `call/`, `progression/`, `vocabulary/`, `feedback/`, `streak/`, `profile/`, `history/` — each `service/`, `cubit/`, `screen/`, `widget/`.
Cubit + Equatable everywhere; Firestore streams for reactivity; optimistic updates; single theme file; l10n French (+en); ScreenUtil; haptics on all interactions; Mixpanel events; debugPrint with `[ClassTag]`.

## Assets
- Robot tutor image (cropped from screenshots as placeholder — replace with original asset when available).
- Cat image for review sheet (same approach).
- Emoji used elsewhere (flags, fire, etc.) — rendered as text emoji, no assets needed.
