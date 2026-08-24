// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Tuco';

  @override
  String get tabHome => 'Accueil';

  @override
  String get tabProgress => 'Progression';

  @override
  String get tabProfile => 'Profil';

  @override
  String get exchange => 'Appeler';

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
  String get clearButton => 'Effacer';

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
  String nextMilestone(int days) {
    return 'Prochain badge : $days jours';
  }

  @override
  String get allMilestonesEarned => 'Tous les badges sont débloqués !';

  @override
  String get milestonesTitle => 'Badges de série';

  @override
  String milestonesEarnedCount(int earned, int total) {
    return '$earned / $total badges débloqués';
  }

  @override
  String milestoneDays(int days) {
    return '$days jours';
  }

  @override
  String get badgeRisen => 'Éveil';

  @override
  String get badgeIgnite => 'Étincelle';

  @override
  String get badgeHorizon => 'Horizon';

  @override
  String get badgeAurora => 'Aurore';

  @override
  String get badgeCelestial => 'Céleste';

  @override
  String get badgeNebula => 'Nébuleuse';

  @override
  String get badgeEternal => 'Éternel';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsAccount => 'COMPTE';

  @override
  String get settingsUserType => 'Type d\'utilisateur';

  @override
  String get settingsUserTypeFree => 'Gratuit';

  @override
  String get settingsCopyUserId => 'Copier l\'identifiant utilisateur';

  @override
  String get settingsUserIdCopied => 'Identifiant utilisateur copié';

  @override
  String get settingsAbout => 'À PROPOS';

  @override
  String get settingsPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get settingsTermsOfService => 'Conditions d\'utilisation';

  @override
  String get settingsDangerZone => 'ZONE DE DANGER';

  @override
  String get settingsDeleteAccount => 'Supprimer le compte';

  @override
  String get settingsDeleteAccountTitle => 'Supprimer le compte ?';

  @override
  String get settingsDeleteAccountBody =>
      'Toutes vos données seront définitivement supprimées (progression, vocabulaire, historique d\'appels, séries). Cette action est irréversible.';

  @override
  String get settingsDeleteAccountConfirm => 'Supprimer';

  @override
  String get settingsDeleteAccountCancel => 'Annuler';

  @override
  String get settingsDeleteAccountDone =>
      'Les données de votre compte ont été supprimées';

  @override
  String get settingsDeleteAccountError =>
      'Impossible de supprimer vos données. Veuillez réessayer.';

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
  String get learningLanguage => 'Langue d\'apprentissage';

  @override
  String get teachingLanguage => 'Langue d\'enseignement';

  @override
  String get languageLevel => 'Niveau de langue';

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
  String get reviewTitle => 'Merci d\'utiliser Tuco !';

  @override
  String get reviewBody =>
      'Vous aimez Tuco ? Laissez-nous une note, ça nous aide beaucoup !';

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
  String get errorGeneric => 'Une erreur est survenue. Veuillez réessayer.';

  @override
  String get errorNoInternet =>
      'Pas de connexion Internet. Veuillez vous connecter et réessayer.';

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

  @override
  String get petName => 'Tuco';

  @override
  String get shopComingSoon => 'Bientôt disponible';

  @override
  String get shopCtaBackground => 'Changer le décor';

  @override
  String get shopCtaHat => 'Acheter un chapeau';

  @override
  String get shopCtaGlass => 'Acheter des lunettes';

  @override
  String get shopCtaScarf => 'Acheter une écharpe';

  @override
  String get shopCtaColor => 'Changer la couleur';

  @override
  String get readyToContinue => 'Es-tu prêt(e) à continuer ?';

  @override
  String get continueButton => 'Continuer';

  @override
  String get onboardingContinue => 'Continuer';

  @override
  String get onboardingWelcomeTitle => 'Apprends l\'espagnol en parlant';

  @override
  String get onboardingWelcomeSubtitle =>
      'De vraies conversations avec Tuco, ton compagnon IA.';

  @override
  String get onboardingWelcomeCta => 'Commencer';

  @override
  String get onboardingWelcomeJoin =>
      'Rejoins des milliers d\'apprenants qui parlent avec Tuco';

  @override
  String get onboardingAlreadyAccount => 'Tu as déjà un compte ? ';

  @override
  String get onboardingSignInLink => 'Se connecter';

  @override
  String get onboardingMeetTitle => 'Rencontre Tuco, ton nouveau compagnon';

  @override
  String get onboardingMeetSubtitle =>
      'Tuco t\'appellera chaque jour pour pratiquer de vraies conversations.';

  @override
  String get onboardingLanguageTitle => 'Quelle langue veux-tu apprendre ?';

  @override
  String get onboardingLanguageEs => 'Espagnol';

  @override
  String get onboardingLanguageEn => 'Anglais';

  @override
  String get onboardingLanguageFr => 'Français';

  @override
  String get onboardingLevelTitle => 'Quel est ton niveau d\'espagnol ?';

  @override
  String get onboardingLevelSubtitle =>
      'Nous adapterons l\'expérience à ton profil.';

  @override
  String get onboardingLevelNew => 'Je débute en espagnol';

  @override
  String get onboardingLevelSomeWords => 'Je connais quelques mots courants';

  @override
  String get onboardingLevelBasic => 'Je peux tenir des conversations simples';

  @override
  String get onboardingLevelVarious => 'Je peux parler de sujets variés';

  @override
  String get onboardingLevelDetailed =>
      'Je peux discuter de la plupart des sujets en détail';

  @override
  String get onboardingChallengesTitle => 'Quels sont tes principaux défis ?';

  @override
  String get onboardingMultiSelectHint =>
      'Sélectionne tout ce qui s\'applique.';

  @override
  String get onboardingChallengeSpeaking => 'Je me bloque quand je dois parler';

  @override
  String get onboardingChallengeVocabulary => 'Je manque de vocabulaire';

  @override
  String get onboardingChallengeConsistency =>
      'Je n\'arrive pas à être régulier(ère)';

  @override
  String get onboardingChallengeConfidence => 'Je manque de confiance';

  @override
  String get onboardingChallengeListening =>
      'J\'ai du mal à comprendre les natifs';

  @override
  String get onboardingChallengeOther => 'Autre';

  @override
  String get onboardingEducation1Title => 'Tuco crée des résultats durables';

  @override
  String get onboardingEducation1Subtitle =>
      'Notre méthode s\'appuie sur la science de l\'apprentissage.';

  @override
  String get onboardingChartTitle => 'Ta progression en espagnol';

  @override
  String get onboardingChartTraditional => 'Traditionnel';

  @override
  String get onboardingChartMonth1 => 'Mois 1';

  @override
  String get onboardingChartMonth12 => 'Mois 12';

  @override
  String get onboardingChartCaption =>
      'Parler chaque jour construit des compétences qui restent, même des mois plus tard.';

  @override
  String get onboardingInterestsTitle => 'Quels sont tes centres d\'intérêt ?';

  @override
  String get onboardingInterestTravel => 'Voyages';

  @override
  String get onboardingInterestFood => 'Cuisine';

  @override
  String get onboardingInterestTechnology => 'Technologie';

  @override
  String get onboardingInterestSport => 'Sport';

  @override
  String get onboardingInterestCulture => 'Culture';

  @override
  String get onboardingInterestBusiness => 'Business';

  @override
  String get onboardingFluencyTitle =>
      'Quand veux-tu parler couramment espagnol ?';

  @override
  String get onboardingFluencySubtitle =>
      'Fixe ton objectif. Restons réalistes.';

  @override
  String onboardingFluencyChip(String date) {
    return '🇪🇸 Courant d\'ici $date !';
  }

  @override
  String get onboardingFluencyUnit => 'mois';

  @override
  String get onboardingMinutesTitle =>
      'Combien de temps peux-tu pratiquer par jour ?';

  @override
  String get onboardingMinutesSubtitle =>
      'La régularité compte. Même 5 minutes par jour donnent des résultats.';

  @override
  String onboardingMinutesChip(int words) {
    return '🦜 Apprends ~$words mots chaque mois';
  }

  @override
  String onboardingMinutesValue(int minutes) {
    return '$minutes minutes';
  }

  @override
  String get onboardingRecommended => 'Recommandé';

  @override
  String get onboardingEducation2Title =>
      'Progresse deux fois plus vite avec Tuco';

  @override
  String get onboardingEducation2Subtitle =>
      'Apprends les langues 2,7x plus vite grâce à de vraies conversations.';

  @override
  String get onboardingCompareOthers => 'Autres apps';

  @override
  String get onboardingCompareTuco => 'Avec Tuco';

  @override
  String get onboardingTimeTitle => 'Quand veux-tu pratiquer ?';

  @override
  String get onboardingTimeSubtitle => 'Tuco t\'appellera au moment parfait.';

  @override
  String get onboardingNotifTitle => 'Ne rate plus jamais ta leçon d\'espagnol';

  @override
  String get onboardingNotifSubtitle =>
      '86 % des utilisateurs atteignent leurs objectifs grâce aux rappels quotidiens.';

  @override
  String get onboardingNotifAllow => 'Autoriser les notifications';

  @override
  String get onboardingNotifLater => 'Pas maintenant';

  @override
  String get onboardingRatingTitle => 'Donne-nous une note';

  @override
  String get onboardingRatingCount => 'notes sur l\'App Store';

  @override
  String get onboardingRatingMadeForYou =>
      'Tuco a été créé pour des gens comme toi';

  @override
  String get onboardingRatingUsers =>
      'Des milliers d\'apprenants pratiquent avec Tuco';

  @override
  String get onboardingReview1Name => 'Rita Y.';

  @override
  String get onboardingReview1Text =>
      'Je connaissais plein de vocabulaire mais je me bloquais dès que je devais parler. Parler avec Tuco chaque jour m\'a donné confiance pour discuter avec des natifs.';

  @override
  String get onboardingReview2Name => 'Marc D.';

  @override
  String get onboardingReview2Text =>
      '5 minutes par jour sur le trajet du travail. Après 3 mois, je tenais une vraie conversation lors de mon voyage à Madrid.';

  @override
  String get onboardingLoadingTitle => 'Création de ton plan...';

  @override
  String get onboardingLoadingStep1 => 'Analyse de ton niveau...';

  @override
  String get onboardingLoadingStep2 => 'Sélection de tes sujets...';

  @override
  String get onboardingLoadingStep3 => 'Construction de ton plan quotidien...';

  @override
  String get onboardingPlanTitle =>
      'Félicitations !\nTon plan personnalisé est prêt';

  @override
  String get onboardingPlanDailyRecommendation => 'Recommandation quotidienne';

  @override
  String get onboardingPlanStayConsistent =>
      'Reste régulier(ère) pour atteindre tes objectifs';

  @override
  String get onboardingPlanStatSpeaking => 'Expression orale';

  @override
  String get onboardingPlanStatWords => 'Nouveaux mots';

  @override
  String get onboardingPlanStatCall => 'Appel avec Tuco';

  @override
  String onboardingPlanTileLessons(int lessons) {
    return '$lessons leçons chargées';
  }

  @override
  String onboardingPlanTileFluent(String date) {
    return 'Courant d\'ici $date';
  }

  @override
  String get onboardingPlanTilePath => 'Parcours optimisé pour toi';

  @override
  String onboardingPlanTileMinutes(int minutes) {
    return '$minutes min/jour';
  }

  @override
  String get onboardingTrialTitle =>
      'On veut te faire essayer Tuco gratuitement';

  @override
  String get onboardingTrialSubtitle =>
      'Débloque ton plan complet avec un essai gratuit.';

  @override
  String get onboardingTrialPoint1 =>
      'Accès complet à toutes les leçons et appels';

  @override
  String get onboardingTrialPoint2 =>
      'On te préviendra avant la fin de l\'essai';

  @override
  String get onboardingTrialPoint3 => 'Annulable à tout moment en deux clics';

  @override
  String get onboardingSignInTitle => 'Finalisons ta configuration';

  @override
  String get onboardingSignInSubtitle =>
      'Sauvegarde ta progression et synchronise ton plan.';

  @override
  String get onboardingSignInApple => 'Se connecter avec Apple';

  @override
  String get onboardingSignInGoogle => 'Continuer avec Google';

  @override
  String get onboardingSignInSkip => 'Passer pour l\'instant';

  @override
  String get onboardingSignInFailed => 'Échec de la connexion. Réessaie.';
}
