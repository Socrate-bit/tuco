import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appName.
  ///
  /// In fr, this message translates to:
  /// **'Tuco'**
  String get appName;

  /// No description provided for @tabHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get tabHome;

  /// No description provided for @tabProgress.
  ///
  /// In fr, this message translates to:
  /// **'Progression'**
  String get tabProgress;

  /// No description provided for @tabProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get tabProfile;

  /// No description provided for @exchange.
  ///
  /// In fr, this message translates to:
  /// **'Appeler'**
  String get exchange;

  /// No description provided for @levelBeginner.
  ///
  /// In fr, this message translates to:
  /// **'Débutant'**
  String get levelBeginner;

  /// No description provided for @levelIntermediate.
  ///
  /// In fr, this message translates to:
  /// **'Intermédiaire'**
  String get levelIntermediate;

  /// No description provided for @levelAdvanced.
  ///
  /// In fr, this message translates to:
  /// **'Avancé'**
  String get levelAdvanced;

  /// No description provided for @stepLesson.
  ///
  /// In fr, this message translates to:
  /// **'Leçon'**
  String get stepLesson;

  /// No description provided for @stepPractice.
  ///
  /// In fr, this message translates to:
  /// **'Entraînement'**
  String get stepPractice;

  /// No description provided for @courseBanner.
  ///
  /// In fr, this message translates to:
  /// **'Cours'**
  String get courseBanner;

  /// No description provided for @practiceBanner.
  ///
  /// In fr, this message translates to:
  /// **'Entraînement'**
  String get practiceBanner;

  /// No description provided for @courseDoneBanner.
  ///
  /// In fr, this message translates to:
  /// **'Cours terminé !'**
  String get courseDoneBanner;

  /// No description provided for @yourTurn.
  ///
  /// In fr, this message translates to:
  /// **'À vous de jouer !'**
  String get yourTurn;

  /// No description provided for @typeButton.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get typeButton;

  /// No description provided for @inspirationButton.
  ///
  /// In fr, this message translates to:
  /// **'Inspiration'**
  String get inspirationButton;

  /// No description provided for @replyHere.
  ///
  /// In fr, this message translates to:
  /// **'Répondre ici'**
  String get replyHere;

  /// No description provided for @inspirationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quelques exemples de phrases :'**
  String get inspirationTitle;

  /// No description provided for @quitCallTitle.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr(e) ?'**
  String get quitCallTitle;

  /// No description provided for @quitCallBody.
  ///
  /// In fr, this message translates to:
  /// **'Vous ne recevrez pas de rapport d\'évaluation si vous ne terminez pas cette session.'**
  String get quitCallBody;

  /// No description provided for @resumeCall.
  ///
  /// In fr, this message translates to:
  /// **'Reprendre l\'appel'**
  String get resumeCall;

  /// No description provided for @quitCall.
  ///
  /// In fr, this message translates to:
  /// **'Quitter l\'appel'**
  String get quitCall;

  /// No description provided for @endSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Bravo, tu assures ! La maîtrise est à portée de main !'**
  String get endSubtitle;

  /// No description provided for @newWordsCard.
  ///
  /// In fr, this message translates to:
  /// **'Nouveaux Mots'**
  String get newWordsCard;

  /// No description provided for @lessonsDoneCard.
  ///
  /// In fr, this message translates to:
  /// **'Leçons Terminées'**
  String get lessonsDoneCard;

  /// No description provided for @lessonDurationCard.
  ///
  /// In fr, this message translates to:
  /// **'Durée leçon'**
  String get lessonDurationCard;

  /// No description provided for @nextLessonButton.
  ///
  /// In fr, this message translates to:
  /// **'Passer à la leçon suivante'**
  String get nextLessonButton;

  /// No description provided for @backHomeButton.
  ///
  /// In fr, this message translates to:
  /// **'Revenir sur la page d\'accueil'**
  String get backHomeButton;

  /// No description provided for @streakDays.
  ///
  /// In fr, this message translates to:
  /// **'jours de série'**
  String get streakDays;

  /// No description provided for @streakHelper.
  ///
  /// In fr, this message translates to:
  /// **'Suivez une leçon chaque jour pour maintenir votre série !'**
  String get streakHelper;

  /// No description provided for @understood.
  ///
  /// In fr, this message translates to:
  /// **'Compris !'**
  String get understood;

  /// No description provided for @streakTitle.
  ///
  /// In fr, this message translates to:
  /// **'Série'**
  String get streakTitle;

  /// No description provided for @longestStreak.
  ///
  /// In fr, this message translates to:
  /// **'Série la plus longue'**
  String get longestStreak;

  /// No description provided for @monthTraining.
  ///
  /// In fr, this message translates to:
  /// **'Entraînement du mois'**
  String get monthTraining;

  /// No description provided for @continueLearning.
  ///
  /// In fr, this message translates to:
  /// **'Continuer l\'apprentissage'**
  String get continueLearning;

  /// No description provided for @feedbackCenter.
  ///
  /// In fr, this message translates to:
  /// **'Centre de feedback'**
  String get feedbackCenter;

  /// No description provided for @grammar.
  ///
  /// In fr, this message translates to:
  /// **'Grammaire'**
  String get grammar;

  /// No description provided for @alternatives.
  ///
  /// In fr, this message translates to:
  /// **'Alternatives'**
  String get alternatives;

  /// No description provided for @times.
  ///
  /// In fr, this message translates to:
  /// **'fois'**
  String get times;

  /// No description provided for @vocabExercise.
  ///
  /// In fr, this message translates to:
  /// **'Exercice de vocabulaire'**
  String get vocabExercise;

  /// No description provided for @newWordsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nouveaux mots'**
  String get newWordsLabel;

  /// No description provided for @upcomingWordsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mots à venir'**
  String get upcomingWordsLabel;

  /// No description provided for @yourStreak.
  ///
  /// In fr, this message translates to:
  /// **'Votre série'**
  String get yourStreak;

  /// No description provided for @dailyStreak.
  ///
  /// In fr, this message translates to:
  /// **'Série quotidienne'**
  String get dailyStreak;

  /// No description provided for @nextMilestone.
  ///
  /// In fr, this message translates to:
  /// **'Prochain badge : {days} jours'**
  String nextMilestone(int days);

  /// No description provided for @allMilestonesEarned.
  ///
  /// In fr, this message translates to:
  /// **'Tous les badges sont débloqués !'**
  String get allMilestonesEarned;

  /// No description provided for @milestonesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Badges de série'**
  String get milestonesTitle;

  /// No description provided for @milestonesEarnedCount.
  ///
  /// In fr, this message translates to:
  /// **'{earned} / {total} badges débloqués'**
  String milestonesEarnedCount(int earned, int total);

  /// No description provided for @milestoneDays.
  ///
  /// In fr, this message translates to:
  /// **'{days} jours'**
  String milestoneDays(int days);

  /// No description provided for @badgeRisen.
  ///
  /// In fr, this message translates to:
  /// **'Éveil'**
  String get badgeRisen;

  /// No description provided for @badgeIgnite.
  ///
  /// In fr, this message translates to:
  /// **'Étincelle'**
  String get badgeIgnite;

  /// No description provided for @badgeHorizon.
  ///
  /// In fr, this message translates to:
  /// **'Horizon'**
  String get badgeHorizon;

  /// No description provided for @badgeAurora.
  ///
  /// In fr, this message translates to:
  /// **'Aurore'**
  String get badgeAurora;

  /// No description provided for @badgeCelestial.
  ///
  /// In fr, this message translates to:
  /// **'Céleste'**
  String get badgeCelestial;

  /// No description provided for @badgeNebula.
  ///
  /// In fr, this message translates to:
  /// **'Nébuleuse'**
  String get badgeNebula;

  /// No description provided for @badgeEternal.
  ///
  /// In fr, this message translates to:
  /// **'Éternel'**
  String get badgeEternal;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get settingsTitle;

  /// No description provided for @settingsAccount.
  ///
  /// In fr, this message translates to:
  /// **'COMPTE'**
  String get settingsAccount;

  /// No description provided for @settingsUserType.
  ///
  /// In fr, this message translates to:
  /// **'Type d\'utilisateur'**
  String get settingsUserType;

  /// No description provided for @settingsUserTypeFree.
  ///
  /// In fr, this message translates to:
  /// **'Gratuit'**
  String get settingsUserTypeFree;

  /// No description provided for @settingsCopyUserId.
  ///
  /// In fr, this message translates to:
  /// **'Copier l\'identifiant utilisateur'**
  String get settingsCopyUserId;

  /// No description provided for @settingsUserIdCopied.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant utilisateur copié'**
  String get settingsUserIdCopied;

  /// No description provided for @settingsAbout.
  ///
  /// In fr, this message translates to:
  /// **'À PROPOS'**
  String get settingsAbout;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsTermsOfService.
  ///
  /// In fr, this message translates to:
  /// **'Conditions d\'utilisation'**
  String get settingsTermsOfService;

  /// No description provided for @settingsDangerZone.
  ///
  /// In fr, this message translates to:
  /// **'ZONE DE DANGER'**
  String get settingsDangerZone;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le compte'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsDeleteAccountTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le compte ?'**
  String get settingsDeleteAccountTitle;

  /// No description provided for @settingsDeleteAccountBody.
  ///
  /// In fr, this message translates to:
  /// **'Toutes vos données seront définitivement supprimées (progression, vocabulaire, historique d\'appels, séries). Cette action est irréversible.'**
  String get settingsDeleteAccountBody;

  /// No description provided for @settingsDeleteAccountConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get settingsDeleteAccountConfirm;

  /// No description provided for @settingsDeleteAccountCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get settingsDeleteAccountCancel;

  /// No description provided for @settingsDeleteAccountDone.
  ///
  /// In fr, this message translates to:
  /// **'Les données de votre compte ont été supprimées'**
  String get settingsDeleteAccountDone;

  /// No description provided for @settingsDeleteAccountError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de supprimer vos données. Veuillez réessayer.'**
  String get settingsDeleteAccountError;

  /// No description provided for @callTimeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Temps passé en appel'**
  String get callTimeTitle;

  /// No description provided for @timeSpent.
  ///
  /// In fr, this message translates to:
  /// **'Temps passé'**
  String get timeSpent;

  /// No description provided for @average.
  ///
  /// In fr, this message translates to:
  /// **'Moyenne'**
  String get average;

  /// No description provided for @goal.
  ///
  /// In fr, this message translates to:
  /// **'Objectif'**
  String get goal;

  /// No description provided for @callHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique des appels'**
  String get callHistory;

  /// No description provided for @showAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout afficher'**
  String get showAll;

  /// No description provided for @freeConversation.
  ///
  /// In fr, this message translates to:
  /// **'Conversation Libre'**
  String get freeConversation;

  /// No description provided for @learnedTab.
  ///
  /// In fr, this message translates to:
  /// **'Appris'**
  String get learnedTab;

  /// No description provided for @upcomingTab.
  ///
  /// In fr, this message translates to:
  /// **'À venir'**
  String get upcomingTab;

  /// No description provided for @filterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout'**
  String get filterAll;

  /// No description provided for @scoreExcellent.
  ///
  /// In fr, this message translates to:
  /// **'Excellent'**
  String get scoreExcellent;

  /// No description provided for @scoreCanDoBetter.
  ///
  /// In fr, this message translates to:
  /// **'Peut Mieux Faire'**
  String get scoreCanDoBetter;

  /// No description provided for @scoreNeedsImprovement.
  ///
  /// In fr, this message translates to:
  /// **'Des améliorations sont nécessaires !'**
  String get scoreNeedsImprovement;

  /// No description provided for @scoreLabel.
  ///
  /// In fr, this message translates to:
  /// **'Score: {score} | {label}'**
  String scoreLabel(int score, String label);

  /// No description provided for @noErrorsHere.
  ///
  /// In fr, this message translates to:
  /// **'Pas d\'erreurs ici ! Vous pouvez appuyer sur le bouton de commentaires dans la leçon pour vérifier vos erreurs.'**
  String get noErrorsHere;

  /// No description provided for @learningLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue d\'apprentissage'**
  String get learningLanguage;

  /// No description provided for @teachingLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue d\'enseignement'**
  String get teachingLanguage;

  /// No description provided for @languageLevel.
  ///
  /// In fr, this message translates to:
  /// **'Niveau de langue'**
  String get languageLevel;

  /// No description provided for @interests.
  ///
  /// In fr, this message translates to:
  /// **'Centres d\'intérêt'**
  String get interests;

  /// No description provided for @dailyGoal.
  ///
  /// In fr, this message translates to:
  /// **'Objectif quotidien'**
  String get dailyGoal;

  /// No description provided for @dailyReminder.
  ///
  /// In fr, this message translates to:
  /// **'Rappel quotidien'**
  String get dailyReminder;

  /// No description provided for @disabled.
  ///
  /// In fr, this message translates to:
  /// **'Désactivé'**
  String get disabled;

  /// No description provided for @minPerDay.
  ///
  /// In fr, this message translates to:
  /// **'{minutes} min/jour'**
  String minPerDay(int minutes);

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @more.
  ///
  /// In fr, this message translates to:
  /// **'Plus...'**
  String get more;

  /// No description provided for @reviewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Merci d\'utiliser Tuco !'**
  String get reviewTitle;

  /// No description provided for @reviewBody.
  ///
  /// In fr, this message translates to:
  /// **'Vous aimez Tuco ? Laissez-nous une note, ça nous aide beaucoup !'**
  String get reviewBody;

  /// No description provided for @letsGo.
  ///
  /// In fr, this message translates to:
  /// **'C\'est parti !'**
  String get letsGo;

  /// No description provided for @maybeLater.
  ///
  /// In fr, this message translates to:
  /// **'Peut-être plus tard'**
  String get maybeLater;

  /// No description provided for @skipLessonTitle.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir passer à cet exercice ?'**
  String get skipLessonTitle;

  /// No description provided for @skipLessonBody.
  ///
  /// In fr, this message translates to:
  /// **'Suivre votre parcours personnalisé boostera votre {language}, mais vous pouvez choisir de passer directement à cet exercice si vous le souhaitez.'**
  String skipLessonBody(String language);

  /// No description provided for @followPath.
  ///
  /// In fr, this message translates to:
  /// **'Suivre le parcours'**
  String get followPath;

  /// No description provided for @goToExercise.
  ///
  /// In fr, this message translates to:
  /// **'Accéder à l\'exercice'**
  String get goToExercise;

  /// No description provided for @resumeLessonTitle.
  ///
  /// In fr, this message translates to:
  /// **'Prêt à reprendre là où vous vous êtes arrêté ?'**
  String get resumeLessonTitle;

  /// No description provided for @resumeLessonButton.
  ///
  /// In fr, this message translates to:
  /// **'Reprenons !'**
  String get resumeLessonButton;

  /// No description provided for @restartLessonButton.
  ///
  /// In fr, this message translates to:
  /// **'Recommencer depuis le début'**
  String get restartLessonButton;

  /// No description provided for @exercisesSection.
  ///
  /// In fr, this message translates to:
  /// **'EXERCICES'**
  String get exercisesSection;

  /// No description provided for @wordsToPracticeSection.
  ///
  /// In fr, this message translates to:
  /// **'MOTS À PRATIQUER'**
  String get wordsToPracticeSection;

  /// No description provided for @lessonExercise.
  ///
  /// In fr, this message translates to:
  /// **'Leçon'**
  String get lessonExercise;

  /// No description provided for @practiceExercise.
  ///
  /// In fr, this message translates to:
  /// **'Exercice'**
  String get practiceExercise;

  /// No description provided for @wellUnderstood.
  ///
  /// In fr, this message translates to:
  /// **'Bien compris'**
  String get wellUnderstood;

  /// No description provided for @wordsChip.
  ///
  /// In fr, this message translates to:
  /// **'{count} Mots'**
  String wordsChip(int count);

  /// No description provided for @grammarChip.
  ///
  /// In fr, this message translates to:
  /// **'{count} Grammaire'**
  String grammarChip(int count);

  /// No description provided for @languageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageEnglish.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In fr, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languageArabic.
  ///
  /// In fr, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageTurkish.
  ///
  /// In fr, this message translates to:
  /// **'Türkçe'**
  String get languageTurkish;

  /// No description provided for @languageSpanishName.
  ///
  /// In fr, this message translates to:
  /// **'Espagnol'**
  String get languageSpanishName;

  /// No description provided for @languageEnglishName.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get languageEnglishName;

  /// No description provided for @errorGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue. Veuillez réessayer.'**
  String get errorGeneric;

  /// No description provided for @errorNoInternet.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion Internet. Veuillez vous connecter et réessayer.'**
  String get errorNoInternet;

  /// No description provided for @interestTechnology.
  ///
  /// In fr, this message translates to:
  /// **'Technologie'**
  String get interestTechnology;

  /// No description provided for @interestTravel.
  ///
  /// In fr, this message translates to:
  /// **'Voyages'**
  String get interestTravel;

  /// No description provided for @interestCooking.
  ///
  /// In fr, this message translates to:
  /// **'Cuisine'**
  String get interestCooking;

  /// No description provided for @interestSports.
  ///
  /// In fr, this message translates to:
  /// **'Sport'**
  String get interestSports;

  /// No description provided for @interestMusic.
  ///
  /// In fr, this message translates to:
  /// **'Musique'**
  String get interestMusic;

  /// No description provided for @interestMovies.
  ///
  /// In fr, this message translates to:
  /// **'Cinéma'**
  String get interestMovies;

  /// No description provided for @interestArt.
  ///
  /// In fr, this message translates to:
  /// **'Art'**
  String get interestArt;

  /// No description provided for @interestBusiness.
  ///
  /// In fr, this message translates to:
  /// **'Business'**
  String get interestBusiness;

  /// No description provided for @petName.
  ///
  /// In fr, this message translates to:
  /// **'Tuco'**
  String get petName;

  /// No description provided for @shopComingSoon.
  ///
  /// In fr, this message translates to:
  /// **'Bientôt disponible'**
  String get shopComingSoon;

  /// No description provided for @shopCtaBackground.
  ///
  /// In fr, this message translates to:
  /// **'Changer le décor'**
  String get shopCtaBackground;

  /// No description provided for @shopCtaHat.
  ///
  /// In fr, this message translates to:
  /// **'Acheter un chapeau'**
  String get shopCtaHat;

  /// No description provided for @shopCtaGlass.
  ///
  /// In fr, this message translates to:
  /// **'Acheter des lunettes'**
  String get shopCtaGlass;

  /// No description provided for @shopCtaScarf.
  ///
  /// In fr, this message translates to:
  /// **'Acheter une écharpe'**
  String get shopCtaScarf;

  /// No description provided for @shopCtaColor.
  ///
  /// In fr, this message translates to:
  /// **'Changer la couleur'**
  String get shopCtaColor;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
