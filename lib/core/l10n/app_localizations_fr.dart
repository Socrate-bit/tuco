// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Learna';

  @override
  String get tabHome => 'Accueil';

  @override
  String get tabProgress => 'Progression';

  @override
  String get tabProfile => 'Profil';

  @override
  String get exchange => 'Échange';

  @override
  String get levelBeginner => 'Débutant';

  @override
  String get levelIntermediate => 'Intermédiaire';

  @override
  String get levelAdvanced => 'Avancé';

  @override
  String get stepLesson => 'Leçon';

  @override
  String get stepPractice => 'Entraînement';

  @override
  String get courseBanner => 'Cours';

  @override
  String get practiceBanner => 'Entraînement';

  @override
  String get courseDoneBanner => 'Cours terminé !';

  @override
  String get yourTurn => 'À vous de jouer !';

  @override
  String get typeButton => 'Type';

  @override
  String get inspirationButton => 'Inspiration';

  @override
  String get replyHere => 'Répondre ici';

  @override
  String get inspirationTitle => 'Quelques exemples de phrases :';

  @override
  String get quitCallTitle => 'Êtes-vous sûr(e) ?';

  @override
  String get quitCallBody =>
      'Vous ne recevrez pas de rapport d\'évaluation si vous ne terminez pas cette session.';

  @override
  String get resumeCall => 'Reprendre l\'appel';

  @override
  String get quitCall => 'Quitter l\'appel';

  @override
  String get endSubtitle =>
      'Bravo, tu assures ! La maîtrise est à portée de main !';

  @override
  String get newWordsCard => 'Nouveaux Mots';

  @override
  String get lessonsDoneCard => 'Leçons Terminées';

  @override
  String get lessonDurationCard => 'Durée leçon';

  @override
  String get nextLessonButton => 'Passer à la leçon suivante';

  @override
  String get backHomeButton => 'Revenir sur la page d\'accueil';

  @override
  String get streakDays => 'jours de série';

  @override
  String get streakHelper =>
      'Suivez une leçon chaque jour pour maintenir votre série !';

  @override
  String get understood => 'Compris !';

  @override
  String get streakTitle => 'Série';

  @override
  String get longestStreak => 'Série la plus longue';

  @override
  String get monthTraining => 'Entraînement du mois';

  @override
  String get continueLearning => 'Continuer l\'apprentissage';

  @override
  String get feedbackCenter => 'Centre de feedback';

  @override
  String get grammar => 'Grammaire';

  @override
  String get alternatives => 'Alternatives';

  @override
  String get times => 'fois';

  @override
  String get vocabExercise => 'Exercice de vocabulaire';

  @override
  String get newWordsLabel => 'Nouveaux mots';

  @override
  String get upcomingWordsLabel => 'Mots à venir';

  @override
  String get yourStreak => 'Votre série';

  @override
  String get dailyStreak => 'Série quotidienne';

  @override
  String get callTimeTitle => 'Temps passé en appel';

  @override
  String get timeSpent => 'Temps passé';

  @override
  String get average => 'Moyenne';

  @override
  String get goal => 'Objectif';

  @override
  String get callHistory => 'Historique des appels';

  @override
  String get showAll => 'Tout afficher';

  @override
  String get freeConversation => 'Conversation Libre';

  @override
  String get learnedTab => 'Appris';

  @override
  String get upcomingTab => 'À venir';

  @override
  String get filterAll => 'Tout';

  @override
  String get scoreExcellent => 'Excellent';

  @override
  String get scoreCanDoBetter => 'Peut Mieux Faire';

  @override
  String get scoreNeedsImprovement => 'Des améliorations sont nécessaires !';

  @override
  String scoreLabel(int score, String label) {
    return 'Score: $score | $label';
  }

  @override
  String get noErrorsHere =>
      'Pas d\'erreurs ici ! Vous pouvez appuyer sur le bouton de commentaires dans la leçon pour vérifier vos erreurs.';

  @override
  String get studyInNative => 'Étudier dans ma langue maternelle';

  @override
  String get targetLanguage => 'Langue cible';

  @override
  String get languageLevel => 'Niveau de langue';

  @override
  String get nativeLanguage => 'Langue maternelle';

  @override
  String get interests => 'Centres d\'intérêt';

  @override
  String get dailyGoal => 'Objectif quotidien';

  @override
  String get dailyReminder => 'Rappel quotidien';

  @override
  String get disabled => 'Désactivé';

  @override
  String minPerDay(int minutes) {
    return '$minutes min/jour';
  }

  @override
  String get save => 'Enregistrer';

  @override
  String get more => 'Plus...';

  @override
  String get reviewTitle => 'Merci d\'utiliser Learna !';

  @override
  String get reviewBody =>
      'Vous aimez Learna ? Laissez-nous une note, ça nous aide beaucoup !';

  @override
  String get letsGo => 'C\'est parti !';

  @override
  String get maybeLater => 'Peut-être plus tard';

  @override
  String get skipLessonTitle =>
      'Êtes-vous sûr de vouloir passer à cet exercice ?';

  @override
  String skipLessonBody(String language) {
    return 'Suivre votre parcours personnalisé boostera votre $language, mais vous pouvez choisir de passer directement à cet exercice si vous le souhaitez.';
  }

  @override
  String get followPath => 'Suivre le parcours';

  @override
  String get goToExercise => 'Accéder à l\'exercice';

  @override
  String get resumeLessonTitle =>
      'Prêt à reprendre là où vous vous êtes arrêté ?';

  @override
  String get resumeLessonButton => 'Reprenons !';

  @override
  String get restartLessonButton => 'Recommencer depuis le début';

  @override
  String get exercisesSection => 'EXERCICES';

  @override
  String get wordsToPracticeSection => 'MOTS À PRATIQUER';

  @override
  String get lessonExercise => 'Leçon';

  @override
  String get practiceExercise => 'Exercice';

  @override
  String get wellUnderstood => 'Bien compris';

  @override
  String wordsChip(int count) {
    return '$count Mots';
  }

  @override
  String grammarChip(int count) {
    return '$count Grammaire';
  }

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageSpanishName => 'Espagnol';

  @override
  String get languageEnglishName => 'English';

  @override
  String get errorGeneric => 'Une erreur est survenue. Veuillez réessayer.';

  @override
  String get interestTechnology => 'Technologie';

  @override
  String get interestTravel => 'Voyages';

  @override
  String get interestCooking => 'Cuisine';

  @override
  String get interestSports => 'Sport';

  @override
  String get interestMusic => 'Musique';

  @override
  String get interestMovies => 'Cinéma';

  @override
  String get interestArt => 'Art';

  @override
  String get interestBusiness => 'Business';
}
